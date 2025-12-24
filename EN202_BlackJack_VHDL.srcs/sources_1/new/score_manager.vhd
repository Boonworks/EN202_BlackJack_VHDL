library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity score_manager is
    Port (
        clk           : in  std_logic;
        rst           : in  std_logic;
        load_score    : in  std_logic;
        card_value    : in  std_logic_vector(3 downto 0);
        score_out     : out std_logic_vector(7 downto 0)
    );
end score_manager;

architecture Behavioral of score_manager is
    signal current_score : integer range 0 to 31 := 0;
    signal ace_count     : integer range 0 to 4  := 0; -- Nombre d'As
begin

    process(clk)
        variable temp_score : integer;
        variable temp_aces  : integer;
    begin
        if rising_edge(clk) then
            if rst = '1' then
                current_score <= 0;
                ace_count <= 0;
            elsif load_score = '1' then
                temp_score := current_score;
                temp_aces  := ace_count;

                -- Ajouter la nouvelle carte
                if card_value = "1011" then
                    temp_score := temp_score + 11;
                    temp_aces  := temp_aces + 1;
                else
                    temp_score := temp_score + to_integer(unsigned(card_value));
                end if;


                for i in 0 to 3 loop
                    if temp_score > 21 and temp_aces > 0 then
                        temp_score := temp_score - 10;
                        temp_aces  := temp_aces - 1;
                    end if;
                end loop;

                current_score <= temp_score;
                ace_count     <= temp_aces;
            end if;
        end if;
    end process;

    score_out <= std_logic_vector(to_unsigned(current_score, 8));

end Behavioral;
