-- Calcola l'indirizzo della cella di memoria del dato da leggere/scrivere 

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity address_counter is
    port(
        clk   : in std_logic;
        rst   : in std_logic;
        init  : in std_logic;
        en    : in std_logic;
        i_add : in std_logic_vector(15 downto 0); -- Indirizzo della prima parola della sequenza corrente
        
        o_add : out std_logic_vector(15 downto 0) -- Indirizzo della parola che deve essere letta/scritta     
    );
end address_counter;

architecture address_counter_arch of address_counter is
    signal temp_add : unsigned(15 downto 0); -- Segnale temporaneo per memorizzare l'indirizzo sommato

begin
    process(clk, rst, init)
    begin
        if (rst = '1' or init = '1') then
            temp_add <= unsigned(i_add);
        elsif rising_edge(clk) and en = '1' then
            temp_add <= temp_add + 8;
        end if;
    end process;
    
    o_add <= std_logic_vector(temp_add);
    
end address_counter_arch;
