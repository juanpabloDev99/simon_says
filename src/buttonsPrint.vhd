library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity buttonsPrint is
    generic(KEEP_CYCLES : integer range 0 to 15 := 15);
    port(
        clk, reset, clear : IN std_logic;
        buttons           : IN std_logic_vector(3 downto 0);
        output            : OUT std_logic_vector(3 downto 0);
        finished          : OUT std_logic);
end buttonsPrint;

architecture Behavioral of buttonsPrint is
    component keepCycles
        generic (KEEP_CYCLES : integer range 0 to 15);
        port ( 
            clk, reset, clear, d : IN  std_logic;
            q                    : OUT  std_logic);
    end component;

    signal last_value, actual_value : std_logic_vector(3 downto 0) := "0000";
begin
    keep_0: keepCycles
        generic map (KEEP_CYCLES => KEEP_CYCLES)
        port map(
            clk   => clk,
            reset => reset,
            clear => clear,
            d     => buttons(0),
            q     => actual_value(0));
    keep_1: keepCycles
        generic map (KEEP_CYCLES => KEEP_CYCLES)
        port map(
            clk   => clk,
            reset => reset,
            clear => clear,
            d     => buttons(1),
            q     => actual_value(1));
    keep_2: keepCycles
        generic map (KEEP_CYCLES => KEEP_CYCLES)
        port map(
            clk   => clk,
            reset => reset,
            clear => clear,
            d     => buttons(2),
            q     => actual_value(2));
    keep_3: keepCycles
        generic map (KEEP_CYCLES => KEEP_CYCLES)
        port map(
            clk   => clk,
            reset => reset,
            clear => clear,
            d     => buttons(3),
            q     => actual_value(3));

    process(reset, clk)
    begin
        if reset = '1' then
            last_value <= "0000";
            finished <= '0';
        elsif rising_edge(clk) then
            if clear = '1' then
                last_value <= "0000";
                finished <= '0';
            elsif last_value /= "0000" and actual_value = "0000" then
                finished <= '1';
            else
                last_value <= actual_value;
            end if;
        end if;
    end process;

    output <= actual_value;
end Behavioral;
