library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity win_manager is
    Port (
        score_player   : in  std_logic_vector(7 downto 0);
        score_dealer   : in  std_logic_vector(7 downto 0);
        is_final       : in  std_logic;
        win_p          : out std_logic; -- Joueur gagne
        win_d          : out std_logic; -- Croupier gagne
        draw           : out std_logic  -- egalite
    );
end win_manager;

architecture Behavioral of win_manager is
begin
    process(score_player, score_dealer, is_final)
        variable s_p, s_d : integer;
    begin
        win_p   <= '0';
        win_d   <= '0';
        draw    <= '0';
        s_p     := to_integer(unsigned(score_player));
        s_d     := to_integer(unsigned(score_dealer));

        if is_final = '1' then
            if      s_p > 21  then       win_d  <= '1'; -- Joueur Bust
            elsif   s_d > 21  then       win_p  <= '1'; -- Croupier Bust
            elsif   s_p > s_d then       win_p  <= '1'; -- Joueur plus fort
            elsif   s_d > s_p then       win_d  <= '1'; -- Croupier plus fort
            else                         draw   <= '1'; -- egalite
            end if;
        end if;
    end process;
end Behavioral;
