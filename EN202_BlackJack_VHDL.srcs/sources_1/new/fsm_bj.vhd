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
        score_joueur  : in  std_logic_vector(7 downto 0);

        load_player   : out std_logic;
        reset_jeu     : out std_logic;
        game_over     : out std_logic;
        is_standing   : out std_logic
    );
end fsm_bj;

architecture Behavioral of fsm_bj is
    type state_type is (READY, START_GAME, WAIT_ACTION, DRAW_CARD, WAIT_1S, CHECK_BUST, PLAYER_STANDS, DEALER_TURN);
    signal state, next_state : state_type;

    signal hit_d, init_d, stand_d : std_logic;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                state <= READY;
                hit_d <= '0';
                init_d <= '0';
                stand_d <= '0';
            else
                state <= next_state;
                hit_d   <= btn_hit;
                init_d  <= btn_init;
                stand_d <= btn_stand;
            end if;
        end if;
    end process;

    process(state, btn_init, btn_hit, btn_stand, score_joueur, CE_jeu, init_d, hit_d, stand_d)
    begin
        next_state   <= state;
        load_player  <= '0';
        reset_jeu    <= '0';
        game_over    <= '0';
        is_standing  <= '0';

        case state is
            when READY =>
                reset_jeu <= '1'; -- On maintient le score = 0
                if (btn_init = '1' and init_d = '0') then
                    next_state <= START_GAME;
                end if;

            --  Initialisation
            when START_GAME =>
                next_state <= WAIT_ACTION;

            --  Le joueur choisit HIT ou STAND
            when WAIT_ACTION =>
                if (btn_hit = '1' and hit_d = '0') then
                    next_state <= DRAW_CARD;
                elsif (btn_stand = '1' and stand_d = '0') then
                    next_state <= PLAYER_STANDS;
                end if;

            --  On demande une carte (impulsion load)
            when DRAW_CARD =>
                load_player <= '1';
                next_state <= WAIT_1S;

            --  On attend 1 seconde pour laisser l'addition se faire et l'affichage �tre lisible
            when WAIT_1S =>
                if CE_jeu = '1' then
                    next_state <= CHECK_BUST;
                end if;

            --  Vérification si le joueur a perdu ( > 21 )
            when CHECK_BUST =>
                if unsigned(score_joueur) > 21 then
                    game_over <= '1';
                    next_state <= READY; -- Perdu retour au debut
                else
                    next_state <= WAIT_ACTION;
                end if;

            -- Transition apres appui sur STAND
            when PLAYER_STANDS =>
                is_standing <= '1'; -- Signal pour le TOP
                if CE_jeu = '1' then
                    next_state <= DEALER_TURN;
                end if;

            when DEALER_TURN =>
                is_standing <= '1';
                next_state <= DEALER_TURN;

            when others =>
                next_state <= READY;
        end case;
    end process;

end Behavioral;
