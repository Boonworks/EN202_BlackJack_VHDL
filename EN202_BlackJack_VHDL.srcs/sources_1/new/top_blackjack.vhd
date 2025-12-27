library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_blackjack is
    Port (
        clk           : in  std_logic;
        rst_n         : in  std_logic;
        btn_init      : in  std_logic;
        btn_hit       : in  std_logic;
        btn_stand     : in  std_logic;
        sept_seg      : out std_logic_vector(6 downto 0);
        AN            : out std_logic_vector(7 downto 0);
        dp            : out std_logic;
        LED16_R       : out std_logic;
        LED16_G       : out std_logic;
        LED16_B       : out std_logic
    );
end top_blackjack;

architecture Behavioral of top_blackjack is
    -- Signaux de controle
    signal rst_global    : std_logic;
    signal ce_p, ce_j     : std_logic;
    signal card_val      : std_logic_vector(3 downto 0);
    signal game_started  : std_logic := '0';
    signal any_load      : std_logic;

    -- Scores
    signal load_p, load_p_delayed : std_logic;
    signal score_player           : std_logic_vector(7 downto 0);
    signal load_d, load_d_delayed : std_logic;
    signal score_dealer         : std_logic_vector(7 downto 0);

    -- Signaux FSM et Victoire
    signal standing      : std_logic;
    signal final_sig     : std_logic;
    signal is_idle       : std_logic; -- Signal pour l'ecran d'accueil
    signal rst_game  : std_logic;
    signal win_p, win_d, draw_sig : std_logic;

    -- Affichage
    signal cmd_mux       : std_logic_vector(2 downto 0);
    signal chosen_digit  : std_logic_vector(6 downto 0);
    type bcd_array is array (0 to 7) of std_logic_vector(6 downto 0);
    signal digits : bcd_array;

    -- PWM et Clignotement
    signal pwm_cnt       : unsigned(7 downto 0) := (others => '0');
    signal pwm_on        : std_logic;
    signal blink_sig     : std_logic;

begin
    rst_global <= not rst_n;
    any_load   <= load_p or load_d;

    -- Generateurs d'horloges et PWM
    freq : entity work.gestion_freq port map (
            clk => clk,
            rst => rst_global,
            CE_perception => ce_p,
            CE_jeu => ce_j );

    process(clk)
        variable blink_cnt : unsigned(23 downto 0) := (others => '0');
    begin
        if rising_edge(clk) then
            pwm_cnt <= pwm_cnt + 1;
            blink_cnt := blink_cnt + 1;
            blink_sig <= blink_cnt(23);
            load_p_delayed <= load_p;
            load_d_delayed <= load_d;
        end if;
    end process;
    pwm_on <= '1' when pwm_cnt < 25 else '0';

    -- Hasard
    rand_hit : entity work.random_hit port map (
            clk => clk,
            rst => rst_global,
            hit => any_load,
            enable_in => '1',
            card_value => card_val );

    -- FSM
    fsm : entity work.fsm_bj port map (
            clk => clk,
            rst => rst_global,
            btn_init => btn_init,
            btn_hit => btn_hit,
            btn_stand => btn_stand,
            CE_jeu => ce_j,
            score_player => score_player,
            score_dealer => score_dealer,
            load_player => load_p,
            load_dealer => load_d,
            reset_game => rst_game,
            is_standing => standing,
            is_final => final_sig,
            is_idle => is_idle
        );

    -- Gestionnaires de scores
    score_p : entity work.score_manager port map (
            clk => clk,
            rst => rst_game,
            load_score => load_p_delayed,
            card_value => card_val,
            score_out => score_player );

    score_d : entity work.score_manager port map (
            clk => clk,
            rst => rst_game,
            load_score => load_d_delayed,
            card_value => card_val,
            score_out => score_dealer );

    -- win manager
    win : entity work.win_manager port map (
            score_player => score_player,
            score_dealer => score_dealer,
            is_final => final_sig,
            win_p => win_p,
            win_d => win_d,
            draw => draw_sig );

    -- LED (LD16)
    process(win_p, win_d, draw_sig, final_sig, pwm_on)
    begin
        LED16_R <= '0';
        LED16_G <= '0';
        LED16_B <= '0';
        if final_sig = '1' then
            if win_p = '1' then
                LED16_G <= pwm_on; -- victoire joueur
            elsif win_d = '1' then
                LED16_R <= pwm_on;  -- defaite joueur
            elsif draw_sig = '1' then
                LED16_R <= pwm_on;  --draw
                LED16_G <= pwm_on;
                LED16_B <= pwm_on;
            end if;
        end if;
    end process;

    -- AFFICHAGE
    process(clk)
        variable s_p, s_d, c_val : integer;
    begin
        if rising_edge(clk) then
            if rst_global = '1' or is_idle = '1' then
                game_started <= '0';
                -- Affichage du message BLAC J
                digits(0) <= "000" & x"8"; -- B (8)
                digits(1) <= "000" & x"C"; -- L
                digits(2) <= "000" & x"A"; -- A
                digits(3) <= "000" & x"D"; -- C
                digits(4) <= "000" & x"F"; -- Vide
                digits(5) <= "000" & x"E"; -- J
                digits(6) <= "000" & x"F"; -- vide
                digits(7) <= "000" & x"F"; -- vide
            else
                if load_p = '1' then game_started <= '1'; end if;
                s_p := to_integer(unsigned(score_player));
                s_d := to_integer(unsigned(score_dealer));
                c_val := to_integer(unsigned(card_val));

                -- JOUEUR
                if final_sig = '1' and win_d = '1' and blink_sig = '1' then
                    digits(3) <= "000" & x"F"; digits(2) <= "000" & x"F";
                else
                    digits(2) <= "000" & std_logic_vector(to_unsigned(s_p / 10, 4));
                    digits(3) <= "000" & std_logic_vector(to_unsigned(s_p rem 10, 4));
                end if;

                if standing = '0' and game_started = '1' then
                    digits(0) <= "000" & std_logic_vector(to_unsigned(c_val / 10, 4));
                    digits(1) <= "000" & std_logic_vector(to_unsigned(c_val rem 10, 4));
                else
                    digits(1) <= "000" & x"F"; digits(0) <= "000" & x"F";
                end if;

                -- CROUPIER
                if final_sig = '1' and win_p = '1' and blink_sig = '1' then
                    digits(7) <= "000" & x"F"; digits(6) <= "000" & x"F";
                else
                    digits(6) <= "000" & std_logic_vector(to_unsigned(s_d / 10, 4));
                    digits(7) <= "000" & std_logic_vector(to_unsigned(s_d rem 10, 4));
                end if;

                if standing = '1' and load_d_delayed = '1' then
                     digits(4) <= "000" & std_logic_vector(to_unsigned(c_val / 10, 4));
                     digits(5) <= "000" & std_logic_vector(to_unsigned(c_val rem 10, 4));
                else
                    digits(5) <= "000" & x"F"; digits(4) <= "000" & x"F";
                end if;
            end if;
        end if;
    end process;

    multiplex8 : entity work.mux8 port map (
        commande => cmd_mux,
        val_0 => digits(0),
        val_1 => digits(1),
        val_2 => digits(2),
        val_3 => digits(3),
        val_4 => digits(4),
        val_5 => digits(5),
        val_6 => digits(6),
        val_7 => digits(7),
        sept_seg => chosen_digit,
        dp => dp );

    trans : entity work.transcodeur port map (
        bin_in => chosen_digit(3 downto 0),
        segments => sept_seg );

    modul8 : entity work.mod8 port map (
        clk => clk,
        rst => rst_global,
        CE_perception => ce_p,
        AN => AN,
        commande => cmd_mux );

end Behavioral;
