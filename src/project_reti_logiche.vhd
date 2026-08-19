-- =============================================================================
--  project_reti_logiche
--
--  Sequence "gap filler" with credibility tagging.
--
--  Given a start address i_add and a sequence length i_k, the component walks a
--  RAM region laid out as interleaved (value, credibility) byte pairs:
--
--      i_add + 2*n     -> value      n
--      i_add + 2*n + 1 -> credibility n
--
--  Only the value cells are populated by the producer; the component fills in
--  the missing information in place:
--
--    * a non-zero value is left untouched and tagged with credibility 31;
--    * a zero value is overwritten with the last non-zero value seen and tagged
--      with the previous credibility minus one, saturating at 0;
--    * zeros occurring before the first non-zero value stay zero and are tagged
--      with credibility 0.
--
--  Handshake: raise i_start, wait for o_done, then lower i_start. o_done falls
--  again and the component is ready for the next run. i_rst is asynchronous.
--
--  Timing: one clock cycle per read/write, 4 cycles per (value, credibility)
--  pair. Verified at a 20 ns clock period on Artix-7 xc7a200tfbg484-1.
-- =============================================================================

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity project_reti_logiche is
    port (
        i_clk   : in std_logic;
        i_rst   : in std_logic;                      -- asynchronous reset
        i_start : in std_logic;                      -- run request
        i_add   : in std_logic_vector(15 downto 0);  -- base address of the sequence
        i_k     : in std_logic_vector(9 downto 0);   -- number of values to process

        o_done : out std_logic;                      -- run completed

        -- Single-port synchronous RAM interface
        o_mem_addr : out std_logic_vector(15 downto 0);
        i_mem_data : in  std_logic_vector(7 downto 0);
        o_mem_data : out std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic
    );
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

    type state_type is (S0, S1, S2, S3, S4, S5, S6, S7);
    signal curr_state, next_state : state_type;

    -- High until the first non-zero value of the sequence has been read.
    signal first_data_is_zero : std_logic := '1';

    -- Datapath registers
    signal curr_addr   : std_logic_vector(15 downto 0) := (others => '0');
    signal credibility : std_logic_vector(4 downto 0)  := (others => '1');
    signal word_count  : std_logic_vector(9 downto 0)  := (others => '0');

    -- Counter enables driven by the FSM
    signal en_addr_count : std_logic := '0';
    signal en_word_count : std_logic := '0';
    signal en_cred_count : std_logic := '0';

    -- Counter / register re-initialisation driven by the FSM
    signal init_addr : std_logic := '0';
    signal init_word : std_logic := '0';
    signal init_cred : std_logic := '0';
    signal init_reg  : std_logic := '0';

    -- Output multiplexer selector
    signal sel : std_logic_vector(1 downto 0) := "00";

    -- Data registers
    signal last_valid_data : std_logic_vector(7 downto 0) := (others => '0');
    signal current_data    : std_logic_vector(7 downto 0) := (others => '0');
    signal new_data        : std_logic                    := '0';

    signal done_processing : std_logic := '0';

begin

    -- Credibility counter: reloaded to 31 on every valid value, decremented once
    -- per zero value and saturated at 0.
    credibility_counter : process (i_rst, i_clk)
    begin
        if (i_rst = '1') then
            credibility <= (others => '1');
        elsif (rising_edge(i_clk)) then
            if (init_cred = '1') then
                credibility <= (others => '1');
            elsif (en_cred_count = '1' and unsigned(credibility) > 0) then
                credibility <= std_logic_vector(unsigned(credibility) - 1);
            end if;
        end if;
    end process;

    -- Address counter: loaded with i_add at the start of a run, then incremented
    -- once per memory access.
    address_counter : process (i_rst, i_clk)
    begin
        if (i_rst = '1') then
            curr_addr <= (others => '0');
        elsif (rising_edge(i_clk)) then
            if (init_addr = '1') then
                curr_addr <= i_add;
            elsif (en_addr_count = '1') then
                curr_addr <= std_logic_vector(unsigned(curr_addr) + 1);
            end if;
        end if;
    end process;

    -- Word counter: counts processed values and raises done_processing once i_k
    -- of them have been handled.
    word_counter : process (i_rst, i_clk)
    begin
        if (i_rst = '1') then
            word_count      <= (others => '0');
            done_processing <= '0';
        elsif (rising_edge(i_clk)) then
            if (init_word = '1') then
                word_count      <= (others => '0');
                done_processing <= '0';
            elsif (en_word_count = '1') then
                word_count <= std_logic_vector(unsigned(word_count) + 1);
                if (unsigned(word_count) = unsigned(i_k)) then
                    done_processing <= '1';
                else
                    done_processing <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Data register: samples the RAM output every cycle and latches it as the
    -- last valid value whenever the FSM flags it as non-zero.
    data_reg : process (i_rst, i_clk)
    begin
        if (i_rst = '1') then
            current_data       <= (others => '0');
            last_valid_data    <= (others => '0');
            first_data_is_zero <= '1';
        elsif (rising_edge(i_clk)) then
            if (init_reg = '1') then
                current_data       <= (others => '0');
                last_valid_data    <= (others => '0');
                first_data_is_zero <= '1';
            else
                current_data <= i_mem_data;
                if (new_data = '1') then
                    last_valid_data    <= i_mem_data;
                    first_data_is_zero <= '0';
                end if;
            end if;
        end if;
    end process;

    -- FSM state register
    fsm_state_reg : process (i_rst, i_clk)
    begin
        if (i_rst = '1') then
            curr_state <= S0;
        elsif (rising_edge(i_clk)) then
            curr_state <= next_state;
        end if;
    end process;

    -- FSM next-state logic.
    -- S0 : reset state
    -- S1 : setup, waits for i_start
    -- S2 : loop head, exits to S7 once the whole sequence has been processed
    -- S3 : wait state, covers the RAM read latency
    -- S4 : classifies the value just read and writes the value cell
    -- S5 : wait state
    -- S6 : writes the credibility cell and advances the word counter
    -- S7 : done, waits for i_start to be released
    fsm_lambda : process (i_rst, i_start, done_processing, curr_state)
    begin
        case curr_state is
            when S0 =>
                if (i_rst = '0') then
                    next_state <= S1;
                else
                    next_state <= S0;
                end if;
            when S1 =>
                if (i_start = '1') then
                    next_state <= S2;
                else
                    next_state <= S1;
                end if;
            when S2 =>
                if (done_processing = '1') then
                    next_state <= S7;
                else
                    next_state <= S3;
                end if;
            when S3 =>
                next_state <= S4;
            when S4 =>
                next_state <= S5;
            when S5 =>
                next_state <= S6;
            when S6 =>
                next_state <= S2;
            when S7 =>
                if (i_start = '0') then
                    next_state <= S1;
                else
                    next_state <= S7;
                end if;
        end case;
    end process;

    -- FSM output logic. All controls default to inactive so that only the
    -- states that need them have to drive them.
    fsm_delta : process (curr_state, current_data, first_data_is_zero)
    begin
        init_addr     <= '0';
        init_word     <= '0';
        init_cred     <= '0';
        init_reg      <= '0';
        en_word_count <= '0';
        en_addr_count <= '0';
        en_cred_count <= '0';
        new_data      <= '0';
        o_mem_en      <= '1';
        o_mem_we      <= '0';
        sel           <= "00";

        case curr_state is
            when S0 =>
                o_mem_en <= '0';

            when S1 =>
                init_addr <= '1';
                init_word <= '1';
                init_cred <= '1';
                init_reg  <= '1';

            when S4 =>
                if (unsigned(current_data) = 0) then
                    if (first_data_is_zero = '1') then
                        -- Still before the first valid value: write back zero.
                        sel <= "00";
                    else
                        -- Gap inside the sequence: repeat the last valid value
                        -- and lower its credibility.
                        en_cred_count <= '1';
                        sel           <= "01";
                    end if;
                else
                    -- Valid value: keep it and reset the credibility to 31.
                    new_data  <= '1';
                    init_cred <= '1';
                    sel       <= "10";
                end if;
                o_mem_we      <= '1';
                en_addr_count <= '1';

            when S6 =>
                if (first_data_is_zero = '1') then
                    sel <= "00";
                else
                    sel <= "11";
                end if;
                o_mem_we      <= '1';
                en_addr_count <= '1';
                en_word_count <= '1';

            when S7 =>
                o_mem_en <= '0';

            when others =>
                null;
        end case;
    end process;

    -- Output multiplexer: selects what gets written into the current RAM cell.
    multiplexer : process (sel, current_data, last_valid_data, credibility)
    begin
        case sel is
            when "00" =>
                o_mem_data <= (others => '0');
            when "10" =>
                o_mem_data <= current_data;
            when "01" =>
                o_mem_data <= last_valid_data;
            when "11" =>
                o_mem_data <= ("000" & credibility);
            when others =>
                o_mem_data <= (others => '0');
        end case;
    end process;

    o_mem_addr <= curr_addr;
    o_done     <= done_processing;

end project_reti_logiche_arch;
