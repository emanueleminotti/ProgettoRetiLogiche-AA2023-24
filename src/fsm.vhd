-- Macchina a stati finiti che gestisce l'evolvere del processo

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm is
    port(
        -- Segnali collegati all'interfaccia del modulo principale
        clk   : in std_logic;
        rst   : in std_logic;
        start : in std_logic;
        done  : in std_logic;
                
        i_mem_data : in std_logic_vector(7 downto 0);
        o_mem_we   : out std_logic;
        o_mem_en   : out std_logic;
        
        -- Segnali ausiliari utilizzati per gestire gli altri componenti del modulo
        en_cred_count : out std_logic;
        en_word_count : out std_logic;
        en_add_count  : out std_logic;
        init_word_add : out std_logic; -- Reinizializza il contatore di parole e di indirizzi
        init_cred     : out std_logic; -- Reinizializza il contatore di credibilità
        sel           : out std_logic; -- Seleziona l'uscita del multiplexer ('0' per il valore di credibilità, '1' per l'ultimo dato valido)
        new_data      : out std_logic  -- Notifica il mux che è stato letto un nuovo dato valido dalla memoria, da sovrascrivere a quello precedentemente memorizzato
    );
end fsm;

architecture fsm_arch of fsm is
-- ilde: reset della fsm, partenza della prima esecuzione del processo, successive esecuzioni non richiedono di tornare in questo stato; scatta allo stato successivo quando vine abbassato il segnale di reset
-- waiting for start: aspetta che il test bench fornisca il segnale che richiede l'inizio della computazione, stato di partenza del processo per esecuzioni successive alla prima
-- begin processing: stato di preparazione e sincronizzazione dei componenti ausiliari, attivazione della comunicazione con la memoria
-- first zero: se il primo dato letto da memoria è pari a zero,  il suo valore rimane tale e il valore di credibilità deve essere posto a 0 (zero). Lo stesso succede fino al raggiungimento del primo dato della sequenza con valore diverso da zero.
-- read word: legge il dato corrente; se questo è un valore valido, avanza di una cella e passa allo stato "write credibility", altrimenti resta nella cella di memoria corrente e passa a "write word"
-- write word: scrive nella stessa cella di memoria dove è stato letto un valore non valido (zero) l'ultimo valore valido conservato nel registro del mux, poi avanza di una cella
-- write crdedibility: scrive in memoria il valore di credibilità corrente, succesivamente avanza di una cella di memoria; se riceva il segnale done dal contatore di parole passa allo stato di terminazione del processo, altrimenti torna a read word
-- done processing: aspetta che venga abbassato il segnale di start dal test bench, abbassa di conseguenza il segnale done e ritorna ad attendere un nuovo segnale di inizio
type state_type is (idle, waiting_for_start, begin_processing, first_zero, read_word, write_credibility, write_word, done_processing);
signal curr_state, next_state : state_type;
signal first_data_is_zero : std_logic := '0';

begin
    state_reg: process(clk, rst) -- Registri della macchina a stati
    begin
        if rst = '1' then
            curr_state <= idle;
        elsif rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process;
    
    lambda: process(rst, start, done, curr_state) -- Funzione stato prossimo
    variable zero : std_logic_vector(7 downto 0) := (others => '0');
    begin
        case curr_state is
            when idle =>
                if rst = '0' then
                    next_state <= waiting_for_start;
                end if;
            when waiting_for_start =>
                if start = '1' then
                    next_state <= begin_processing;
                end if;
            when begin_processing =>
                if first_data_is_zero = '1' then
                    next_state <= first_zero;
                else
                    next_state <= read_word;
                end if;
            when first_zero =>
                if first_data_is_zero = '1' then
                    next_state <= first_zero; -- non cambio stato fino a quando non viene letto un valore valido
                else
                    next_state <= read_word;
                end if;
            when read_word =>
                if i_mem_data = zero then
                    next_state <= write_word;
                else
                    next_state <= write_credibility;
                end if;
            when write_credibility =>
                if done = '1' then
                    next_state <= done_processing;
                else
                    if first_data_is_zero = '1' then
                        next_state <= first_zero;
                    else
                        next_state <= read_word;
                    end if;
                end if;
            when write_word =>
                next_state <= write_credibility;
            when done_processing =>
                if start = '0' then
                    next_state <= waiting_for_start;
                end if;
        end case;
    end process;
        
    delta: process(clk, curr_state) -- Funzione di uscita
    variable zero : std_logic_vector(7 downto 0) := (others => '0');
    begin
        en_cred_count <= '0';
        en_word_count <= '0';
        en_add_count <= '0';
        init_cred <= '0';
        init_word_add <= '0';
        case curr_state is
            when begin_processing =>
                o_mem_we <= '0';
                o_mem_en <= '1';
                if i_mem_data = zero then
                    first_data_is_zero <= '1';
                end if;
                en_word_count <= '1';
            when first_zero =>
                if i_mem_data = zero then
                    o_mem_we <= '0';
                else
                    first_data_is_zero <= '0';
                end if;
            when read_word =>
                en_word_count <= '1';
                en_add_count <= '1';
                if i_mem_data = zero then
                    new_data <= '0';
                    init_cred <= '0';
                    en_cred_count <= '1';
                    sel <= '1';
                else
                    new_data <= '1';
                    en_cred_count <= '0';
                    init_cred <= '1';
                    sel <= '0';
                end if;
                o_mem_we <= '1';
            when write_word =>
                en_word_count <= '0';
                en_add_count <= '1';
                o_mem_we <= '0';
            when write_credibility =>
                en_word_count <= '1';
                en_add_count <= '1';
                o_mem_we <= '0';
            when done_processing =>
                o_mem_we <= '0';
                o_mem_en <= '0';
                init_cred <= '1';
                init_word_add <= '1';
            when others =>
                null;
        end case;
    end process;
end fsm_arch;
