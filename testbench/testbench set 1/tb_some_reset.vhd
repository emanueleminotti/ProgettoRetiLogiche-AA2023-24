library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use std.textio.all;

entity tb_some_reset is
end tb_some_reset;

architecture tb_some_reset_arch of tb_some_reset is
    constant CLOCK_PERIOD : time := 20 ns;
    signal tb_clk : std_logic := '0';
    signal tb_rst, tb_start, tb_done : std_logic;
    signal tb_add : std_logic_vector(15 downto 0);
    signal tb_k   : std_logic_vector(9 downto 0);

    signal tb_o_mem_addr, exc_o_mem_addr, init_o_mem_addr : std_logic_vector(15 downto 0);
    signal tb_o_mem_data, exc_o_mem_data, init_o_mem_data : std_logic_vector(7 downto 0);
    signal tb_i_mem_data : std_logic_vector(7 downto 0);
    signal tb_o_mem_we, tb_o_mem_en, exc_o_mem_we, exc_o_mem_en, init_o_mem_we, init_o_mem_en : std_logic;

    type ram_type is array (65535 downto 0) of std_logic_vector(7 downto 0);
    signal RAM : ram_type := (OTHERS => "00000000");

    constant SCENARIO_LENGTH_1 : integer := 16#00A#;
    type scenario_type_1 is array (0 to SCENARIO_LENGTH_1*2-1) of integer;

    signal scenario_input_1 : scenario_type_1 := (16#33#, 16#00#, 16#00#, 16#00#, 16#39#, 16#00#, 16#18#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#7E#, 16#00#, 16#00#, 16#00#, 16#C0#, 16#00#, 16#00#, 16#00#);
    signal scenario_full_1  : scenario_type_1 := (16#33#, 16#1F#, 16#33#, 16#1E#, 16#39#, 16#1F#, 16#18#, 16#1F#, 16#18#, 16#1E#, 16#18#, 16#1D#, 16#7E#, 16#1F#, 16#7E#, 16#1E#, 16#C0#, 16#1F#, 16#C0#, 16#1E#);

    signal memory_control : std_logic := '0';
    
    constant SCENARIO_ADDRESS_1 : integer := 16#0064#;

    constant SCENARIO_LENGTH_2 : integer := 16#023#;
    type scenario_type_2 is array (0 to SCENARIO_LENGTH_2*2-1) of integer;

    signal scenario_input_2 : scenario_type_2 := (16#33#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#);
    signal scenario_full_2  : scenario_type_2 := (16#33#, 16#1F#, 16#33#, 16#1E#, 16#33#, 16#1D#, 16#33#, 16#1C#, 16#33#, 16#1B#, 16#33#, 16#1A#, 16#33#, 16#19#, 16#33#, 16#18#, 16#33#, 16#17#, 16#33#, 16#16#, 16#33#, 16#15#, 16#33#, 16#14#, 16#33#, 16#13#, 16#33#, 16#12#, 16#33#, 16#11#, 16#33#, 16#10#, 16#33#, 16#0F#, 16#33#, 16#0E#, 16#33#, 16#0D#, 16#33#, 16#0C#, 16#33#, 16#0B#, 16#33#, 16#0A#, 16#33#, 16#09#, 16#33#, 16#08#, 16#33#, 16#07#, 16#33#, 16#06#, 16#33#, 16#05#, 16#33#, 16#04#, 16#33#, 16#03#, 16#33#, 16#02#, 16#33#, 16#01#, 16#33#, 16#00#, 16#33#, 16#00#, 16#33#, 16#00#, 16#33#, 16#00#);

    constant SCENARIO_ADDRESS_2 : integer := 16#0064#;
    
    constant SCENARIO_LENGTH_3 : integer := 16#021#;
    type scenario_type_3 is array (0 to SCENARIO_LENGTH_3*2-1) of integer;

    signal scenario_input_3 : scenario_type_3 := (16#00#, 16#00#, 16#FF#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#89#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#6F#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#B5#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#F6#, 16#00#, 16#7C#, 16#00#, 16#00#, 16#00#, 16#5D#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#, 16#00#);
    signal scenario_full_3  : scenario_type_3 := (16#00#, 16#00#, 16#FF#, 16#1F#, 16#FF#, 16#1E#, 16#FF#, 16#1D#, 16#89#, 16#1F#, 16#89#, 16#1E#, 16#89#, 16#1D#, 16#89#, 16#1C#, 16#89#, 16#1B#, 16#89#, 16#1A#, 16#89#, 16#19#, 16#89#, 16#18#, 16#89#, 16#17#, 16#6F#, 16#1F#, 16#6F#, 16#1E#, 16#6F#, 16#1D#, 16#6F#, 16#1C#, 16#B5#, 16#1F#, 16#B5#, 16#1E#, 16#B5#, 16#1D#, 16#B5#, 16#1C#, 16#B5#, 16#1B#, 16#B5#, 16#1A#, 16#F6#, 16#1F#, 16#7C#, 16#1F#, 16#7C#, 16#1E#, 16#5D#, 16#1F#, 16#5D#, 16#1E#, 16#5D#, 16#1D#, 16#5D#, 16#1C#, 16#5D#, 16#1B#, 16#5D#, 16#1A#, 16#5D#, 16#19#);

    constant SCENARIO_ADDRESS_3 : integer := 16#0214#;
    
    component project_reti_logiche is
        port (
                i_clk : in std_logic;
                i_rst : in std_logic;
                i_start : in std_logic;
                i_add : in std_logic_vector(15 downto 0);
                i_k   : in std_logic_vector(9 downto 0);
                
                o_done : out std_logic;
                
                o_mem_addr : out std_logic_vector(15 downto 0);
                i_mem_data : in  std_logic_vector(7 downto 0);
                o_mem_data : out std_logic_vector(7 downto 0);
                o_mem_we   : out std_logic;
                o_mem_en   : out std_logic
        );
    end component project_reti_logiche;

begin
    UUT : project_reti_logiche
    port map(
                i_clk   => tb_clk,
                i_rst   => tb_rst,
                i_start => tb_start,
                i_add   => tb_add,
                i_k     => tb_k,
                
                o_done => tb_done,
                
                o_mem_addr => exc_o_mem_addr,
                i_mem_data => tb_i_mem_data,
                o_mem_data => exc_o_mem_data,
                o_mem_we   => exc_o_mem_we,
                o_mem_en   => exc_o_mem_en
    );

    -- Clock generation
    tb_clk <= not tb_clk after CLOCK_PERIOD/2;

    -- Process related to the memory
    MEM : process (tb_clk)
    begin
        if tb_clk'event and tb_clk = '1' then
            if tb_o_mem_en = '1' then
                if tb_o_mem_we = '1' then
                    RAM(to_integer(unsigned(tb_o_mem_addr))) <= tb_o_mem_data after 1 ns;
                    tb_i_mem_data <= tb_o_mem_data after 1 ns;
                else
                    tb_i_mem_data <= RAM(to_integer(unsigned(tb_o_mem_addr))) after 1 ns;
                end if;
            end if;
        end if;
    end process;
    
    memory_signal_swapper : process(memory_control, init_o_mem_addr, init_o_mem_data,
                                    init_o_mem_en,  init_o_mem_we,   exc_o_mem_addr,
                                    exc_o_mem_data, exc_o_mem_en, exc_o_mem_we)
    begin
        -- This is necessary for the testbench to work: we swap the memory
        -- signals from the component to the testbench when needed.
    
        tb_o_mem_addr <= init_o_mem_addr;
        tb_o_mem_data <= init_o_mem_data;
        tb_o_mem_en   <= init_o_mem_en;
        tb_o_mem_we   <= init_o_mem_we;

        if memory_control = '1' then
            tb_o_mem_addr <= exc_o_mem_addr;
            tb_o_mem_data <= exc_o_mem_data;
            tb_o_mem_en   <= exc_o_mem_en;
            tb_o_mem_we   <= exc_o_mem_we;
        end if;
    end process;
    
    -- This process provides the correct scenario on the signal controlled by the TB
    create_scenario : process
    begin
        wait for 50 ns;

        -- Signal initialization and reset of the component
        tb_start <= '0';
        tb_add <= (others=>'0');
        tb_k   <= (others=>'0');
        tb_rst <= '1';
        
        -- Wait some time for the component to reset...
        wait for 50 ns;
        
        -- Here, I set start to 1
        tb_start <= '1';
        wait for 500 ns;       
        
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        for i in 0 to SCENARIO_LENGTH_1*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_1+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_1(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_1, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_1, 10));
        
        tb_rst <= '0'; -- Now the component can start

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        wait for 5 ns;
        
        tb_start <= '0';

        -- Second read starting from the same address of the first read: prepare memory
        tb_rst <= '0';
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_2(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_2, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_2, 10));
        
        tb_start <= '1';

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;

        wait for 5 ns;
        
        tb_start <= '0';
        
        -- Third read, starting with '0' value from another address, not equals to the previous two
        -- and I give the reset signal during the process.

        tb_rst <= '0';
        memory_control <= '0';  -- Memory controlled by the testbench
        
        wait until falling_edge(tb_clk); -- Skew the testbench transitions with respect to the clock

        -- Configure the memory        
        for i in 0 to SCENARIO_LENGTH_3*2-1 loop
            init_o_mem_addr<= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3+i, 16));
            init_o_mem_data<= std_logic_vector(to_unsigned(scenario_input_3(i),8));
            init_o_mem_en  <= '1';
            init_o_mem_we  <= '1';
            wait until rising_edge(tb_clk);   
        end loop;
        
        wait until falling_edge(tb_clk);

        memory_control <= '1';  -- Memory controlled by the component
        
        tb_add <= std_logic_vector(to_unsigned(SCENARIO_ADDRESS_3, 16));
        tb_k   <= std_logic_vector(to_unsigned(SCENARIO_LENGTH_3, 10));
        
        tb_start <= '1';

        wait for 300 ns;
        
        tb_rst <= '1';

        wait for 5 ns;
        
        tb_start <= '0';
        
        wait;
        
    end process;

    -- Process without sensitivity list designed to test the actual component.
    test_routine : process
    begin

        wait until tb_rst = '1';
        wait for 25 ns;
        assert tb_done = '0' report "TEST FALLITO o_done !=0 during reset" severity failure;
       

        wait until falling_edge(tb_clk);
        assert tb_done = '0' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        
        --wait until rising_edge(tb_start);
        wait until tb_rst = '0';

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        
        assert tb_done = '1' report "TEST FALLITO o_done != 1 when the whole sequence has just been read" severity failure;

        -- Done <= 1: First sequence read

        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_1*2-1 loop
            assert RAM(SCENARIO_ADDRESS_1+i) = std_logic_vector(to_unsigned(scenario_full_1(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_1(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_1+i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=0 after reset before start" severity failure;
        wait until falling_edge(tb_done);

        wait until rising_edge(tb_start);
        -- Second read starts here

        while tb_done /= '1' loop                
            wait until rising_edge(tb_clk);
        end loop;
        
        assert tb_done = '1' report "TEST FALLITO: o_done = 1 when the component is still working" severity failure;

        -- Done <= 1: Second sequence read
        assert tb_o_mem_en = '0' or tb_o_mem_we = '0' report "TEST FALLITO o_mem_en !=0 memory should not be written after done." severity failure;

        for i in 0 to SCENARIO_LENGTH_2*2-1 loop
            assert RAM(SCENARIO_ADDRESS_2+i) = std_logic_vector(to_unsigned(scenario_full_2(i),8)) report "TEST FALLITO @ OFFSET=" & integer'image(i) & " expected= " & integer'image(scenario_full_2(i)) & " actual=" & integer'image(to_integer(unsigned(RAM(SCENARIO_ADDRESS_2+i)))) severity failure;
        end loop;

        wait until falling_edge(tb_start);
        assert tb_done = '1' report "TEST FALLITO o_done !=1 before setting it to 0" severity failure;
        wait until falling_edge(tb_done);
        
        wait until tb_rst = '1';
        assert tb_done = '0' report "TEST FALLITO: o_done != 0 when no read process completed. ";
        
        assert false report "Simulation Ended! TEST PASSATO (EXAMPLE)" severity failure;
    end process;

end architecture;