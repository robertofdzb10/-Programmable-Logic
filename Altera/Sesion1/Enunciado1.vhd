-- No tocar
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;

entity main is
    port (
    g_clock_50: in std_logic;
    v_sw  : in std_logic_vector (9 downto 0); 
    v_bt  : in std_logic_vector (3 downto 0); 
    g_led : out std_logic_vector(9 downto 0); 
    g_hex0 : out std_logic_vector(0 to 6); -- Importante, dar la vuelta para que el siete segmentos lo lea bien
    g_hex1 : out std_logic_vector(0 to 6);
    g_hex2 : out std_logic_vector(0 to 6);
    g_hex3 : out std_logic_vector(0 to 6);
    g_hex4 : out std_logic_vector(0 to 6);
    g_hex5 : out std_logic_vector(0 to 6) 
    );
end main;

architecture Behavioral of main is

-- Empezamos a poder tocar

signal num_a: std_logic_vector (3 downto 0);

begin

num_a<=v_sw(3 downto 0);


process(num_a)
begin
case num_a is
    when "0000" => g_hex0<="0000001";
    when "0001" => g_hex0<="1001111";
    when "0010" => g_hex0<="0010010";
    when "0011" => g_hex0<="0000110";
    when "0100" => g_hex0<="1001100";
    when "0101" => g_hex0<="0100100";
    when "0110" => g_hex0<="1100000";
    when "0111" => g_hex0<="0001111";
    when "1000" => g_hex0<="0000000";
    when "1001" => g_hex0<="0001100";
    when "1010" => g_hex0<="0001000";
    when "1011" => g_hex0<="1100000";--
    when "1100" => g_hex0<="0110001";
    when "1101" => g_hex0<="0000001";
    when "1110" => g_hex0<="0110000";
    when "1111" => g_hex0<="0111000";
    when others => g_hex0<="0110000";
end case;
end process;

end Behavioral;