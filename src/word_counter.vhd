-- Conta fino al numero di parole K

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity word_counter is
    port(
        clk  : in std_logic;
        rst  : in std_logic;
        init : in std_logic;
        en   : in std_logic;
        k  : in std_logic_vector(9 downto 0); -- Numero di parole da leggere
        
        done : out std_logic -- Segnala che sono state lette tutte le parole della sequenza
    );
end word_counter;

architecture word_counter_arch of word_counter is
    signal count : unsigned(9 downto 0) := (others => '0');

begin
    process(clk, rst, en)
    begin
        if (rst = '1' or init = '1') then
            count <= (others => '0');
            done <= '0';
        elsif en = '0' then
            done <= '0';
        elsif (rising_edge(clk) and (en = '1')) then
            if count < unsigned(k) then
                count <= count + 1;
            else
                done <= '1';
            end if;            
        end if;
    end process;
    
end word_counter_arch;
