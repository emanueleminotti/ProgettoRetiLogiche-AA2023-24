-- Interfaccia del componente

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

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
component address_counter is
    port(
        clk   : in std_logic;
        rst   : in std_logic;
        init  : in std_logic;
        en    : in std_logic;
        i_add : in std_logic_vector(15 downto 0);
        
        o_add : out std_logic_vector(15 downto 0)     
    );
end component address_counter;

component credibility_counter is
    port(
        clk  : in std_logic;
        rst  : in std_logic;
        init : in std_logic;
        en   : in std_logic;

        cred : out std_logic_vector(4 downto 0)
    );
end component credibility_counter;

component fsm is
    port(
        clk   : in std_logic;
        rst   : in std_logic;
        start : in std_logic;
        done  : in std_logic;
                
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic;
        
        en_cred_count : out std_logic;
        en_word_count        : out std_logic;
        en_add_count     : out std_logic;
        init_word_add        : out std_logic;
        init_cred            : out std_logic;
        sel                  : out std_logic;
        new_data             : out std_logic
    );
end component fsm;

component multiplexer is
    port (
        sel         : in  std_logic;
        cred        : in  std_logic_vector(4 downto 0);
        data        : in  std_logic_vector(7 downto 0);
        new_data    : in std_logic;
        output      : out std_logic_vector(7 downto 0)
    );
end component multiplexer;

component word_counter is
    port(
        clk  : in std_logic;
        rst  : in std_logic;
        init : in std_logic;
        en   : in std_logic;
        k  : in std_logic_vector(9 downto 0);
        
        done : out std_logic
    );
end component word_counter;

signal cred_sig          : std_logic_vector(4 downto 0);
signal init_word_add_sig : std_logic;
signal init_cred_sig     : std_logic;
signal en_cred_sig       : std_logic;
signal en_word_sig       : std_logic;
signal en_add_sig        : std_logic;
signal done_sig          : std_logic;
signal sel_sig           : std_logic;
signal new_data_sig      : std_logic;

begin

    counter_1: credibility_counter port map(
        clk => i_clk,
        rst => i_rst,
        init => init_cred_sig,
        en => en_cred_sig,
        cred => cred_sig
    );
    
    counter_2: word_counter port map(
        clk => i_clk,
        rst => i_rst,
        init => init_word_add_sig,
        en => en_word_sig,
        k => i_k,
        done => done_sig
    );
    
    counter_3: address_counter port map(
            clk => i_clk,
            rst => i_rst,
            init => init_word_add_sig,
            en => en_add_sig,
            i_add => i_add,
            o_add => o_mem_addr
    );
    
    multiplexer_1: multiplexer port map(
        sel => sel_sig,
        cred => cred_sig,
        data => i_mem_data,
        new_data => new_data_sig,
        output => o_mem_data
    );
    
    fsm_1: fsm port map(
        clk => i_clk,
        rst => i_rst,
        start => i_start,
        done => done_sig,
        i_mem_data => i_mem_data,
        o_mem_we => o_mem_we,
        o_mem_en => o_mem_en,
        en_cred_count => en_cred_sig,
        en_word_count => en_word_sig,
        en_add_count => en_add_sig,
        init_word_add => init_word_add_sig,
        init_cred => init_cred_sig,
        sel => sel_sig,
        new_data => new_data_sig
    );
    
    o_done <= done_sig;
end project_reti_logiche_arch;
