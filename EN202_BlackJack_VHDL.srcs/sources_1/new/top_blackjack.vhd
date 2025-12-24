library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity top_test_blackjack is
    Port (
        clk           : in  std_logic;
        rst_n         : in  std_logic;
        btn_init      : in  std_logic;
        btn_hit       : in  std_logic;
        btn_stand     : in  std_logic;
        sept_seg      : out std_logic_vector(6 downto 0);
        AN            : out std_logic_vector(7 downto 0);
        dp            : out std_logic
    );
end top_test_blackjack;

architecture Behavioral of top_test_blackjack is
    signal rst_global    : std_logic;
    signal ce_p, ce_j     : std_logic;
    signal load_p        : std_logic;
    signal load_p_delayed: std_logic;
    signal card_val      : std_logic_vector(3 downto 0);
    signal cmd_mux       : std_logic_vector(2 downto 0);
    signal chosen_digit  : std_logic_vector(6 downto 0);
    signal game_started  : std_logic := '0';

    signal current_score : std_logic_vector(7 downto 0);
    signal reset_du_jeu  : std_logic;
    signal standing      : std_logic;

    type bcd_array is array (0 to 7) of std_logic_vector(6 downto 0);
    signal digits : bcd_array;

begin
    rst_global <= not rst_n;

    -- Synchro pour l'additionneur de score
    process(clk)
    begin
        if rising_edge(clk) then
            load_p_delayed <= load_p;
        end if;
    end process;

    -- Frequences
    inst_freq : entity work.gestion_freq
        port map ( clk => clk, rst => rst_global, CE_perception => ce_p, CE_jeu => ce_j );

    -- tirage
    inst_rand : entity work.random_hit
        port map ( clk => clk, rst => rst_global, hit => load_p, enable_in => '1', card_value => card_val );

    -- FSM
    inst_fsm : entity work.fsm_bj
        port map (
            clk => clk, rst => rst_global, btn_init => btn_init, btn_hit => btn_hit,
            btn_stand => btn_stand, CE_jeu => ce_j, score_joueur => current_score,
            load_player => load_p, reset_jeu => reset_du_jeu,
            is_standing => standing, game_over => open
        );

    -- Score Manager
    inst_score : entity work.score_manager
        port map (
            clk => clk, rst => reset_du_jeu, load_score => load_p_delayed,
            card_value => card_val, score_out => current_score
        );

    -------------------------------------------------------
    -- LOGIQUE D'AFFICHAGE
    -------------------------------------------------------
    process(clk)
        variable score_int : integer;
        variable card_int  : integer;
    begin
        if rising_edge(clk) then
            if rst_global = '1' then
                game_started <= '0';
                digits <= (others => "000" & x"F");
            else
                if load_p = '1' then game_started <= '1'; end if;

                score_int := to_integer(unsigned(current_score));
                card_int  := to_integer(unsigned(card_val));

                -- AN1-AN0 : Carte (Dizaines sur AN0, Unites sur AN1)
                if standing = '1' then
                    digits(1) <= "000" & x"F"; -- eteint si STAND
                    digits(0) <= "000" & x"F";
                elsif game_started = '1' then
                    digits(1) <= "000" & std_logic_vector(to_unsigned(card_int rem 10, 4));
                    digits(0) <= "000" & std_logic_vector(to_unsigned(card_int / 10, 4));
                else
                    digits(0) <= "000" & x"0"; digits(1) <= "000" & x"0";
                end if;

                -- AN3-AN2 : Score (Dizaines sur AN3, Unites sur AN2)
                digits(3) <= "000" & std_logic_vector(to_unsigned(score_int rem 10, 4));
                digits(2) <= "000" & std_logic_vector(to_unsigned(score_int / 10, 4));

                -- eteindre les autres
                for i in 4 to 7 loop digits(i) <= "000" & x"F"; end loop;
            end if;
        end if;
    end process;

    -- Multiplexage Physique
    inst_mux8 : entity work.mux8
        port map (
            commande => cmd_mux,
            val_0 => digits(0), val_1 => digits(1), val_2 => digits(2), val_3 => digits(3),
            val_4 => digits(4), val_5 => digits(5), val_6 => digits(6), val_7 => digits(7),
            sept_seg => chosen_digit, dp => dp
        );

    inst_trans : entity work.transcodeur
        port map ( bin_in => chosen_digit(3 downto 0), segments => sept_seg );

    inst_mod8 : entity work.mod8
        port map ( clk => clk, rst => rst_global, CE_perception => ce_p, AN => AN, commande => cmd_mux );

end Behavioral;
