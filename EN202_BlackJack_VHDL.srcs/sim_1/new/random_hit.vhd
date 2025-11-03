library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity random_hit is
    port (
        clk   : in  std_logic;
        rst_n : in  std_logic;
        hit   : in  std_logic;

        suit  : out std_logic_vector(1 downto 0); -- 0..3
        rank  : out std_logic_vector(3 downto 0)  -- 0..12
    );
end random_hit;

architecture Behavioral of random_hit is
    signal counter : unsigned(15 downto 0) := (others => '0');
    signal suit_q  : std_logic_vector(1 downto 0) := (others => '0');
    signal rank_q  : std_logic_vector(3 downto 0) := (others => '0');
begin
    suit <= suit_q;
    rank <= rank_q;

    process(clk)
        variable r_bits : unsigned(3 downto 0);
    begin
        if rising_edge(clk) then
            if rst_n = '1' then
                counter <= (others => '0');
                suit_q  <= (others => '0');
                rank_q  <= (others => '0');
            else
                counter <= counter + 1;
                if hit = '1' then
                    suit_q <= std_logic_vector(counter(1 downto 0));
                    r_bits := counter(3 downto 0) xor counter(7 downto 4) xor counter(11 downto 8);
                    if r_bits > to_unsigned(12,4) then
                        rank_q <= std_logic_vector(r_bits - to_unsigned(13,4));
                    else
                        rank_q <= std_logic_vector(r_bits);
                    end if;
                end if;
            end if;
        end if;
    end process;
end Behavioral;
