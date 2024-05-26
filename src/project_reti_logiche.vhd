library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity project_reti_logiche is
    port (
         i_clk   : in std_logic;
         i_rst   : in std_logic;
         i_start : in std_logic;
         i_add   : in std_logic_vector(15 downto 0);
         i_k     : in std_logic_vector(9 downto 0);
         
         o_done : out std_logic;
         
         o_mem_addr : out std_logic_vector(15 downto 0);
         i_mem_data : in std_logic_vector(7 downto 0);
         o_mem_data : out std_logic_vector(7 downto 0);
         o_mem_we   : out std_logic;
         o_mem_en   : out std_logic
     );       
end project_reti_logiche;

architecture project_reti_logiche_arch of project_reti_logiche is

   ---- SEGNALI ----

   -- Controllo della macchina a stati finiti
   type state_type is (RESET, SETUP, WAIT_WORD, READ_WORD, WRITE_WORD, WAIT_CREDIBILITY, WRITE_CREDIBILITY, COMPLETED);
   signal curr_state, next_state : state_type;
   
   -- Gestione del caso particolare dato dalla specifica
   signal first_data_is_zero : std_logic := '1';

   -- Memorizza l'indirizzo corrente al quale leggere/scrivere i dati in memoria
   signal curr_addr : std_logic_vector(15 downto 0) := (others => '0');

   -- Valore di credibilit  corrente
   signal credibility : std_logic_vector(4 downto 0) := (others => '1');

   -- Numero di parole lette dalla memoria
   signal word_count : std_logic_vector(9 downto 0) := (others => '0');
   
   -- Abilitano i contatori
   signal en_addr_count : std_logic := '0';
   signal en_word_count : std_logic := '0';
   signal en_cred_count : std_logic := '0';

   -- Reinizializzano separatamente i componenti dell'entit 
   signal init_addr : std_logic := '0';
   signal init_word : std_logic := '0';
   signal init_cred : std_logic := '0';
   signal init_reg  : std_logic := '0';


   -- Indica quale registro collegare all'uscita
   signal sel : std_logic_vector(1 downto 0) := "00";

   -- Mantiene l'ultimo valore valido letto dalla memoria
   signal last_valid_data : std_logic_vector(7 downto 0) := (others => '0');
   signal current_data : std_logic_vector(7 downto 0) := (others => '0');

   -- Indica che un nuovo valore valido   stato letto dalla memoria
   signal new_data: std_logic := '0';

   -- Indica il termine della computazione
   signal done_processing : std_logic := '0';
   
begin

    ---- COMPONENTI ----

    -- Conta a ritroso a partire dal valore di credibilit 
    credibility_counter: process(i_rst, i_clk)
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

    -- Calcola l'indirizzo della cella di memoria del dato da leggere/scrivere
    address_counter: process(i_rst, i_clk)
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

    -- Conta fino al numero di parole K
    word_counter: process(i_rst, i_clk)
    begin
        if (i_rst = '1') then
            word_count <= (others => '0');
            done_processing <= '0';
        elsif (rising_edge(i_clk)) then
            if (init_word = '1') then
                word_count <= (others => '0');
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

    -- Mantiene l'ultimo valore valido letto da memoria
    last_valid_data_reg: process(i_rst, i_clk)
    begin
        if (i_rst = '1') then
            current_data <= (others => '0');
            last_valid_data <= (others => '0');
            first_data_is_zero <= '1';
        elsif (rising_edge(i_clk)) then
            if (init_reg = '1') then
                current_data <= (others => '0');
                last_valid_data <= (others => '0');
                first_data_is_zero <= '1';
            else
                current_data <= i_mem_data;
                if (new_data = '1') then
                    last_valid_data <= i_mem_data;
                    first_data_is_zero <= '0';
                end if;
            end if;
        end if;
    end process;

    -- Registro della macchina a stati
    fsm_state_reg: process(i_rst, i_clk)
    begin
        if (i_rst = '1') then
            curr_state <= RESET;
        elsif (rising_edge(i_clk)) then
            curr_state <= next_state;
        end if;
    end process;

    -- Funzione stato prossimo della macchina a stati
    fsm_lambda: process(i_rst, i_start, done_processing, curr_state)
    begin
        case curr_state is
            when RESET =>
                if (i_rst = '0') then
                    next_state <= SETUP;
                else
                    next_state <= RESET;
                end if;
            when SETUP =>
                if (i_start = '1') then
                    next_state <= WAIT_WORD;
                else
                    next_state <= SETUP;
                end if;
            when WAIT_WORD =>
                if (done_processing = '1') then
                    next_state <= COMPLETED;
                else
                    next_state <= READ_WORD;
                end if;
            when READ_WORD =>
                next_state <= WRITE_WORD;
            when WRITE_WORD =>
                next_state <= WAIT_CREDIBILITY;
            when WAIT_CREDIBILITY =>
                next_state <= WRITE_CREDIBILITY;
            when WRITE_CREDIBILITY =>
                next_state <= WAIT_WORD;
            when COMPLETED =>
                if (i_start = '0') then
                    next_state <= SETUP;
                else
                    next_state <= COMPLETED;
                end if;
        end case;   
    end process;

    -- Funzione di uscita della macchina a stati
    fsm_delta: process(curr_state, current_data, first_data_is_zero)
    begin
        -- Inizializzazioni di default
        init_addr <= '0';
        init_word <= '0';
        init_cred <= '0';
        init_reg <= '0';
        en_word_count <= '0';
        en_addr_count <= '0';
        en_cred_count <= '0';
        new_data <= '0';
        o_mem_en <= '1';
        o_mem_we <= '0';
        sel <= "00";

        case curr_state is
            when RESET =>
                o_mem_en <= '0';
            when SETUP =>
                init_addr <= '1';
                init_word <= '1';
                init_cred <= '1';
                init_reg <= '1';
            when WRITE_WORD =>
                if (unsigned(current_data) = 0) then
                    if (first_data_is_zero = '1') then
                        sel <= "00";
                    else
                        en_cred_count <= '1';
                        sel <= "01";
                    end if;
                else
                    new_data <= '1';
                    init_cred <= '1';
                    sel <= "10";
                end if;
                o_mem_we <= '1';
                en_addr_count <= '1';
            when WRITE_CREDIBILITY =>
                if (first_data_is_zero = '1') then
                    sel <= "00";
                else
                    sel <= "11";
                end if;
                o_mem_we <= '1';
                en_addr_count <= '1';
                en_word_count <= '1';
            when COMPLETED =>
                o_mem_en <= '0';
            when others =>
                null;
            end case;
    end process;

    -- Collegamento dei segnali interni con le uscite fisiche del componente
    multiplexer: process(sel)
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
    o_done <= done_processing;

end project_reti_logiche_arch;
