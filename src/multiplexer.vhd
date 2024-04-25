-- Invia il dato da inserire in memoria, selezionando tra valore di credibilità e ultimo dato letto valido

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity multiplexer is
    port (
        sel      : in std_logic;
        cred     : in std_logic_vector(4 downto 0);
        data     : in std_logic_vector(7 downto 0); 
        new_data : in std_logic; -- è stato letto un nuovo valore valido da sovrascrivere al precedente nel registro
                
        output : out std_logic_vector(7 downto 0)
    );
end multiplexer;

architecture multiplexer_arch of multiplexer is
    signal last_valid_data : std_logic_vector(7 downto 0) := (others => '0');
begin
    process(sel)
    begin
        if sel = '1' then
            output <= std_logic_vector(resize(unsigned(cred), output'length));
        elsif sel = '0' then
            output <= last_valid_data;
        end if;
    end process;
    
    process(new_data)
    begin
        if new_data = '1' then
            last_valid_data <= data;
        end if;
    end process;
end architecture multiplexer_arch;
