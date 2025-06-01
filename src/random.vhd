library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity random is 
    generic(SEED : std_logic_vector(15 downto 0) := x"ABCD");
    port (
        clk, reset, enable, clear : IN  std_logic;
        sequence                  : OUT std_logic_vector(15 downto 0));
end random;

architecture Behavioral of random is    
    signal aux_seq   : std_logic_vector(15 downto 0) := SEED;
    signal new_seq_0 : std_logic := '0';
begin
    new_seq_0 <= aux_seq(15) XOR aux_seq(13) XOR aux_seq(12) XOR aux_seq(10);

    process(reset, clk)
    begin
        if reset = '1' then
            aux_seq <= SEED;
        elsif rising_edge(clk) then
            if clear = '1' then
                aux_seq <= SEED;
            elsif enable = '1' then
                aux_seq <= aux_seq(14 downto 0) & new_seq_0;
            end if;
        end if;
    end process;

    sequence <= aux_seq;
end Behavioral;

