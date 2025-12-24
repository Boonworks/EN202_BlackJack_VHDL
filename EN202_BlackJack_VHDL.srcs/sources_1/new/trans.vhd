library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity transcodeur is
    Port (
        bin_in    : in  std_logic_vector(3 downto 0);
        segments  : out std_logic_vector(6 downto 0)
    );
end transcodeur;

architecture Behavioral of transcodeur is
begin
    process(bin_in)
    begin
        case bin_in is          -- (0 = allume, 1 = eteint)
            when "0000" => segments <= "0000001"; -- 0
            when "0001" => segments <= "1001111"; -- 1
            when "0010" => segments <= "0010010"; -- 2
            when "0011" => segments <= "0000110"; -- 3
            when "0100" => segments <= "1001100"; -- 4
            when "0101" => segments <= "0100100"; -- 5
            when "0110" => segments <= "0100000"; -- 6
            when "0111" => segments <= "0001111"; -- 7
            when "1000" => segments <= "0000000"; -- 8
            when "1001" => segments <= "0000100"; -- 9
            when "1010" => segments <= "0001000"; -- A (pour 10)
            when "1011" => segments <= "1100000"; -- b (pour 11)
            when others => segments <= "1111111"; -- eteint
        end case;
    end process;
end Behavioral;
