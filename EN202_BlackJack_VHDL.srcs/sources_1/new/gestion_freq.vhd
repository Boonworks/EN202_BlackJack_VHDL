library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity gestion_freq is
    Port (  clk           : in  std_logic;
            rst           : in  std_logic;
            CE_affichage  : out std_logic;
            CE_perception : out std_logic;
            CE_jeu        : out std_logic
    );
end gestion_freq;

architecture Behavioral of gestion_freq is
    signal count_perc : unsigned(15 downto 0) := (others => '0');
    signal count_aff  : unsigned(23 downto 0) := (others => '0');
    signal count_jeu  : unsigned(26 downto 0) := (others => '0');

begin
    upd_perc : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_perc <= (others => '0');
                CE_perception <= '0';
            elsif count_perc = x"C34F" then -- 50 000 cycles
                count_perc <= (others => '0');
                CE_perception <= '1';
            else
                count_perc <= count_perc + 1;
                CE_perception <= '0';
            end if;
        end if;
    end process;

    upd_aff : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_aff <= (others => '0');
                CE_affichage <= '0';
            elsif count_aff = x"98967F" then -- 9 999 999 cycles
                count_aff <= (others => '0');
                CE_affichage <= '1';
            else
                count_aff <= count_aff + 1;
                CE_affichage <= '0';
            end if;
        end if;
    end process;

    upd_jeu : process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                count_jeu <= (others => '0');
                CE_jeu <= '0';
            -- 100 000 000 cycles = 1 seconde
            elsif count_jeu = 99999999 then
                count_jeu <= (others => '0');
                CE_jeu <= '1';
            else
                count_jeu <= count_jeu + 1;
                CE_jeu <= '0';
            end if;
        end if;
    end process;

end Behavioral;
