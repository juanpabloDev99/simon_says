library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity print_tb is
end print_tb;

architecture Behavioral of print_tb is
    component print
    generic (
        CLOCK_FREQ       : integer := 50_000_000;
        PRINT_SECONDS    : integer range 0 to 15 := 2;
        WAIT_FRACTION    : integer range 0 to 15 := 1;
        SENTENCE_SECONDS : integer range 0 to 15 := 10;
        KEEP_CYCLES      : integer range 0 to 15 := 2);
	port(
		clk, reset, clear : IN std_logic;
		status            : IN std_logic_vector(2 downto 0);
		buttons           : IN std_logic_vector(3 downto 0);
		round             : IN unsigned(2 downto 0);
		random            : IN std_logic_vector(15 downto 0);
		segments          : OUT std_logic_vector(6 downto 0);
        selector          : OUT std_logic_vector(3 downto 0);
		done              : OUT std_logic);
    end component;

    ----------------------------------------------------------------------------
    -- Señales internas para conectar con el DUT (Device Under Test)
    ----------------------------------------------------------------------------
    signal clk_tb, reset_tb, clear_tb : std_logic := '0';
    signal status_tb                  : std_logic_vector(2 downto 0) := "000";
    signal round_tb                   : unsigned(2 downto 0) := "000";
    signal random_tb                  : std_logic_vector(15 downto 0);
    signal buttons_tb                 : std_logic_vector(3 downto 0) := "0000";
    signal leds_tb                    : std_logic_vector(7 downto 0) := "00000000";
    signal segments_tb                : std_logic_vector(6 downto 0) := "0000000";
    signal selector_tb                : std_logic_vector(3 downto 0) := "0000";
    signal done_tb                    : std_logic := '0';

    ----------------------------------------------------------------------------
    -- Parámetro del período del reloj (20 ns => ~50 MHz)
    ----------------------------------------------------------------------------
    constant CLK_PERIOD : time := 20 ns;
begin
    ----------------------------------------------------------------------------
    -- Instanciación del módulo "print"
    ----------------------------------------------------------------------------
    uut: print
        generic map(
            CLOCK_FREQ        => 50,
            PRINT_SECONDS    => 1,
            WAIT_FRACTION    => 4,
            SENTENCE_SECONDS => 4,
            KEEP_CYCLES      => 10
        )
        port map(
            clk      => clk_tb,
            reset    => reset_tb,
            clear    => clear_tb,
            status   => status_tb,
            round    => round_tb,
            random   => random_tb,
            buttons  => buttons_tb,
            segments => segments_tb,
            selector => selector_tb,
            done     => done_tb);

    ----------------------------------------------------------------------------
    -- Generación del reloj
    ----------------------------------------------------------------------------
    clk_process: process
    begin
        while true loop
            clk_tb <= '0';
            wait for CLK_PERIOD/2;
            clk_tb <= '1';
            wait for CLK_PERIOD/2;
        end loop;
    end process;

    ----------------------------------------------------------------------------
    -- Proceso de estimulación (test)
    ----------------------------------------------------------------------------
    stim_process: process
    begin
        ------------------------------------------------------------------------
        -- Reset inicial
        ------------------------------------------------------------------------
        reset_tb <= '1';
        wait for 20 ns;
        reset_tb <= '0';
        wait for 100 ns;
        
        ------------------------------------------------------------------------
        -- Estado inicial:
        ------------------------------------------------------------------------
        random_tb <= b"00_11_00_11_00_11_00_11";
        round_tb <= "001";
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 100 ns;

        ------------------------------------------------------------------------
        -- 1) Caso: status = "001" (imprimir secuencia)
        ------------------------------------------------------------------------
        status_tb <= "001";
        wait for 5000 ns;
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 100 ns;

        ------------------------------------------------------------------------
        -- 2) Caso: status = "011" (ganar)
        ------------------------------------------------------------------------
        status_tb <= "011";
        clear_tb <= '1';
        wait for 20 ns;
        clear_tb <= '0';
        wait for 2000 ns;

        wait;
    end process;
end Behavioral;
