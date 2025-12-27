library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_score_manager is
end tb_score_manager;

architecture Behavioral of tb_score_manager is

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal load_score : std_logic := '0';
    signal card_value : std_logic_vector(3 downto 0) := (others => '0');
    signal score_out  : std_logic_vector(7 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    uut : entity work.score_manager
        port map (
            clk        => clk,
            rst        => rst,
            load_score => load_score,
            card_value => card_value,
            score_out  => score_out
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimulus : process
    begin

        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        card_value <= "0101";  -- 5
        load_score <= '1';
        wait for 10 ns;
        load_score <= '0';
        wait for 30 ns;

        card_value <= "1010";  -- 10
        load_score <= '1';
        wait for 10 ns;
        load_score <= '0';
        wait for 30 ns;

        card_value <= "1011";  -- AS = 1 ici
        load_score <= '1';
        wait for 10 ns;
        load_score <= '0';
        wait for 30 ns;

        rst <= '1';             --rst
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns;

        card_value <= "1010";  -- 10
        load_score <= '1';
        wait for 10 ns;
        load_score <= '0';
        wait for 30 ns;

        card_value <= "1011";  -- AS = 11 ici
        load_score <= '1';
        wait for 10 ns;
        load_score <= '0';

        wait;
    end process;

end Behavioral;
