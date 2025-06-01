library IEEE;
use IEEE.STD_LOGIC_1164.ALL; 
use IEEE.NUMERIC_STD.ALL;

entity word2button is
	port(
		sequence: IN std_logic_vector(1 downto 0);
		word: OUT std_logic_vector(3 downto 0)
	);
end word2button;

architecture Behavioral of word2button is
begin
    word <= "1000" when sequence = "00" else
            "0100" when sequence = "01" else
            "0010" when sequence = "10" else
            "0001" when sequence = "11" else
            "0000";
end;