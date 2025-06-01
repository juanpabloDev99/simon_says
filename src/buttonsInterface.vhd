library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity buttonsInterface is
    generic(DEBOUNCE_CONTROL : integer range 0 to 15 := 10);
    port (
        clk, reset : IN std_logic;
        buttons    : IN std_logic_vector(3 downto 0);
        outputs    : OUT std_logic_vector(3 downto 0));
end buttonsInterface;

architecture Behavioral of buttonsInterface is
    component debounceFilter
        generic(DEBOUNCE_CONTROL : integer range 0 to 15 := 10);
        port(
            clk, reset, pul : IN  std_logic;
            q               : OUT  std_logic);
    end component;
    component onePulseControl
        port(
            clk, reset, d : IN  std_logic;
            q             : OUT  std_logic);
    end component;
    
    signal middle : std_logic_vector(3 downto 0);
begin
    debounce_0: debounceFilter
        generic map(DEBOUNCE_CONTROL => DEBOUNCE_CONTROL)
        port map(
            clk   => clk,
            reset => reset,
            pul   => buttons(0),
            q     => middle(0));
    debounce_1: debounceFilter
        generic map(DEBOUNCE_CONTROL => DEBOUNCE_CONTROL)
        port map(
            clk   => clk,
            reset => reset,
            pul   => buttons(1),
            q     => middle(1));
    debounce_2: debounceFilter
        generic map(DEBOUNCE_CONTROL => DEBOUNCE_CONTROL)
        port map(
            clk   => clk,
            reset => reset,
            pul   => buttons(2),
            q     => middle(2));
    debounce_3: debounceFilter
        generic map(DEBOUNCE_CONTROL => DEBOUNCE_CONTROL)
        port map(
            clk   => clk,
            reset => reset,
            pul   => buttons(3),
            q     => middle(3));

     pulse_0: onePulseControl
        port map(
            clk   => clk,
            reset => reset,
            d     => middle(0),
            q     => outputs(0));
    pulse_1: onePulseControl
        port map(
            clk   => clk,
            reset => reset,
            d     => middle(1),
            q     => outputs(1));
    pulse_2: onePulseControl
        port map(
            clk   => clk,
            reset => reset,
            d     => middle(2),
            q     => outputs(2));
    pulse_3: onePulseControl
        port map(
            clk   => clk,
            reset => reset,
            d     => middle(3),
            q     => outputs(3));
end Behavioral;
