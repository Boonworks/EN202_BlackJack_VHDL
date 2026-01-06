library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_random_hit is
end tb_random_hit;

architecture Behavioral of tb_random_hit is

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal hit        : std_logic := '0';
    signal enable_in  : std_logic := '1';  -- toujours actif
    signal card_value : std_logic_vector(3 downto 0);

    constant CLK_PERIOD : time := 10 ns;

begin
    uut : entity work.random_hit
        port map (
            clk        => clk,
            rst        => rst,
            hit        => hit,
            enable_in  => enable_in,
            card_value => card_value
        );

    clk <= not clk after CLK_PERIOD / 2;

    stimulus : process
    begin
        wait for 30 ns;

        -- hit 1
        hit <= '1';
        wait for 10 ns;
        hit <= '0';
        wait for 40 ns;

        -- hit 2
        hit <= '1';
        wait for 10 ns;
        hit <= '0';
        wait for 35 ns;

        -- hit 3
        hit <= '1';
        wait for 10 ns;
        hit <= '0';
        wait;
    end process;

end Behavioral;
