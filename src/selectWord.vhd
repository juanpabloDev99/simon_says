library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity selectWord is
    port (
        counter  : IN unsigned(2 downto 0);
        sequence : IN std_logic_vector(15 downto 0);
        word     : OUT std_logic_vector(3 downto 0)
    );
end selectWord;

architecture Behavioral of selectWord is
    signal segment  : std_logic_vector(1 downto 0) := "00";
    signal selected : integer := 0;
begin
    selected <= to_integer(counter);
    segment <=  sequence(selected * 2 + 1 downto selected * 2);

    word <= "1000" when segment = "00" else
            "0100" when segment = "01" else
            "0010" when segment = "10" else
            "0001" when segment = "11" else
            "0000";
end Behavioral;