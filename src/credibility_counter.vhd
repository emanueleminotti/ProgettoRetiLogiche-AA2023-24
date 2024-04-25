-- Conta a ritroso a partire dal valore di credibilità

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity credibility_counter is
    port(
        clk      : in std_logic;
        rst      : in std_logic;
        init     : in std_logic;
        en       : in std_logic;

        cred : out std_logic_vector(4 downto 0) -- Valore di credibilità corrente
    );
end credibility_counter;

architecture credibility_counter_arch of credibility_counter is
    signal count : unsigned(4 downto 0) := (others => '1'); 

begin
    process(clk, rst)
    begin
        if (rst = '1' or init = '1') then
            count <= (others => '1'); -- Reset del contatore al valore di credibilità massimo
        elsif (rising_edge(clk) and en = '1') then
            count <= count - 1;
        end if;
    end process;

    cred <= std_logic_vector(count);
    
end credibility_counter_arch;
