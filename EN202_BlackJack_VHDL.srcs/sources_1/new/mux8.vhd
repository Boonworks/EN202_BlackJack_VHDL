library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mux8 is
    Port (
        commande : in  STD_LOGIC_VECTOR(2 downto 0);
        val_0    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN0
        val_1    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN1
        val_2    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN2
        val_3    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN3
        val_4    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN4
        val_5    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN5
        val_6    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN6
        val_7    : in  STD_LOGIC_VECTOR(6 downto 0); -- AN7
        dp       : out std_logic;
        sept_seg : out STD_LOGIC_VECTOR(6 downto 0)
    );
end mux8;

architecture Behavioral of mux8 is
begin
    process(commande, val_0, val_1, val_2, val_3, val_4, val_5, val_6, val_7)
    begin
        case commande is
            when "000" => sept_seg <= val_0; dp <= '1';
            when "001" => sept_seg <= val_1; dp <= '1';
            when "010" => sept_seg <= val_2; dp <= '1';
            when "011" => sept_seg <= val_3; dp <= '1';
            when "100" => sept_seg <= val_4; dp <= '1';
            when "101" => sept_seg <= val_5; dp <= '1';
            when "110" => sept_seg <= val_6; dp <= '1';
            when others => sept_seg <= val_7; dp <= '1';
        end case;
    end process;
end Behavioral;
