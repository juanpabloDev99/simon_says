library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity decoder is
    port (
        control  : IN std_logic_vector(1 downto 0);
        segments : OUT std_logic_vector(6 downto 0)
    );
end decoder;

architecture Behavioral of decoder is
begin
    segments <= "0000000" when control = "01" else  -- 8 // print
                "0000110" when control = "10" else  -- E // win
                "0000001" when control = "11" else  -- 0 // loose
                "1111111";                          -- (void)
end Behavioral;
