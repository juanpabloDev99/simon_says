library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity singleButton_tb is
end singleButton_tb;

architecture Behavioral of singleButton_tb is
    component singleButtonGame is
        port(
            clk, reset, clear, timer : in  std_logic;
            buttons, word             : in  std_logic_vector(3 downto 0);
            done, error              : out std_logic);
    end component;

    signal clk_tb, reset_tb, clear_tb, timer_tb : std_logic := '0';
    signal button_tb                            : std_logic_vector(3 downto 0) := (others => '0');
    signal word_tb                              : std_logic_vector(3 downto 0) := (others => '0');
    signal done_tb                              : std_logic;
    signal error_tb                             : std_logic;

    constant CLK_PERIOD : time := 20 ns;
begin
    uut: singleButtonGame
        port map (
            clk     => clk_tb,
            reset   => reset_tb,
            clear   => clear_tb,
            timer   => timer_tb,
            buttons => button_tb,
            word    => word_tb,
            done    => done_tb,
            error   => error_tb);

    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD / 2;
            clk_tb <= '1';
            wait for CLK_PERIOD / 2;
        end loop;
    end process;

    stim_process: process
    begin
        -- initial setting
        reset_tb <= '1';
        word_tb <= "0010";
        wait for 20 ns;
        reset_tb <= '0';
        wait for 200 ns;

        -- timer expires
        timer_tb <= '1';
        wait for 20 ns;
        timer_tb <= '0';
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 200 ns;

        -- incorrect button input
        button_tb <= "1010";
        wait for 100 ns;
        button_tb <= "0000";
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 200 ns;
        
        -- correct button input
        button_tb <= "0010";
        wait for 100 ns;
        button_tb <= "0000";
        wait for 100 ns;
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 200 ns;

        -- incorrect word
        word_tb <= "0000";

        wait;
    end process;
end Behavioral;