library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity random_hit is
    port (
        clk        : in  std_logic;
        rst        : in  std_logic;
        hit        : in  std_logic;
        enable_in  : in  std_logic;
        card_value : out std_logic_vector(3 downto 0)
    );
end random_hit;

architecture Behavioral of random_hit is
    signal cnt_rank : unsigned(3 downto 0) := (others => '0');
    signal card_reg : std_logic_vector(3 downto 0) := (others => '0');
begin

    card_value <= card_reg;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                -- RESET
                card_reg <= (others => '0');
                cnt_rank <= (others => '0');
            else
                -- Le compteur tourne
                if enable_in = '1' then
                    if cnt_rank = 12 then
                        cnt_rank <= (others => '0');
                    else
                        cnt_rank <= cnt_rank + 1;
                    end if;
                end if;

                -- Capture de la carte hit= 1
                if hit = '1' then
                    if cnt_rank = 0 then
                        card_reg <= "1011"; -- AS = 11
                    elsif cnt_rank >= 9 then
                        card_reg <= "1010"; -- 10, Valet, Dame, Roi = 10
                    else
                        card_reg <= std_logic_vector(cnt_rank + 1); -- 2 to 9
                    end if;
                end if;
            end if;
        end if;
    end process;

end Behavioral;
