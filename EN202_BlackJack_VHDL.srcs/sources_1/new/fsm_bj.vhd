library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fsm_bj is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        btn_init      : in  std_logic;
        btn_hit       : in  std_logic;
        btn_stand     : in  std_logic;
        CE_jeu        : in  std_logic;
        score_player  : in  std_logic_vector(7 downto 0);
        score_dealer  : in  std_logic_vector(7 downto 0);

        load_player   : out std_logic;
        load_dealer   : out std_logic;
        reset_game    : out std_logic;
        is_standing   : out std_logic; -- '1' qd le joueur a fini
        is_final      : out std_logic; -- '1' quand les jeux sont finis
        is_idle       : out std_logic  -- '1' quand on attend le debut
    );
end fsm_bj;

architecture Behavioral of fsm_bj is
    type state_type is (
        READY,
        START_GAME,
        WAIT_ACTION,
        DRAW_CARD,
        WAIT_1S,
        CHECK_BUST,
        PLAYER_STANDS,
        DEALER_DRAW,
        DEALER_WAIT,
        FINAL_SCORE);
    signal state, next_state : state_type;
    signal hit_d, init_d, stand_d : std_logic;
begin

    -- Registres
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state   <= READY;
                hit_d   <= '0';
                init_d  <= '0';
                stand_d <= '0';
            else
                state   <= next_state;
                hit_d   <= btn_hit;
                init_d  <= btn_init;
                stand_d <= btn_stand;
            end if;
        end if;
    end process;

    -- Logique
    process(state, btn_init, btn_hit, btn_stand, score_player, score_dealer, CE_jeu, init_d, hit_d, stand_d)
    begin
        -- Valeurs par defaut
        next_state   <= state;
        load_player  <= '0';
        load_dealer  <= '0';
        reset_game   <= '0';
        is_standing  <= '0';
        is_final     <= '0';
        is_idle      <= '0';

        case state is
            -- attente => message "8LAC J"
            when READY =>
                reset_game      <= '1';
                is_idle         <= '1';

                if (btn_init = '1' and init_d = '0') then
                    next_state  <= START_GAME;
                end if;

            when START_GAME =>
                next_state <= WAIT_ACTION;

            -- Tour du Joueur
            when WAIT_ACTION =>
                if (btn_hit = '1' and hit_d = '0') then
                    next_state <= DRAW_CARD;

                elsif (btn_stand = '1' and stand_d = '0') then
                    next_state <= PLAYER_STANDS;
                end if;

            when DRAW_CARD =>
                load_player <= '1';
                next_state  <= WAIT_1S;

            when WAIT_1S =>
                if CE_jeu = '1' then
                    next_state <= CHECK_BUST;
                end if;

            when CHECK_BUST =>
                -- bust  (>21) => fin
                if unsigned(score_player) > 21 then
                    next_state <= FINAL_SCORE;
                else
                    next_state <= WAIT_ACTION;
                end if;

            -- Croupier
            when PLAYER_STANDS =>
                is_standing <= '1';
                if CE_jeu = '1' then
                    -- tirer si score < 17
                    if unsigned(score_dealer) < 17 then
                        next_state <= DEALER_DRAW;
                    else
                        next_state <= FINAL_SCORE;
                    end if;
                end if;

            when DEALER_DRAW =>
                is_standing <= '1';
                load_dealer <= '1';
                next_state  <= DEALER_WAIT;

            when DEALER_WAIT =>
                is_standing     <= '1';

                if CE_jeu = '1' then
                    next_state  <= PLAYER_STANDS;
                end if;

            -- comparaison et LED RGB
            when FINAL_SCORE =>
                is_standing     <= '1';
                is_final        <= '1';
                if (btn_init = '1' and init_d = '0') then
                    next_state  <= READY; -- Retour accueil
                end if;

            when others =>
                next_state <= READY;
        end case;
    end process;
end Behavioral;
