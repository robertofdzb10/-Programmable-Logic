library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all; -- Revisar si se ha de cambiar

entity main is
    port (
    g_clock_50: in std_logic;
    v_sw  : in std_logic_vector (9 downto 0); 
    v_bt  : in std_logic_vector (3 downto 0); 
    g_led : out std_logic_vector(9 downto 0); 
    g_hex0 : out std_logic_vector(0 to 6); 
    g_hex1 : out std_logic_vector(0 to 6);
    g_hex2 : out std_logic_vector(0 to 6);
    g_hex3 : out std_logic_vector(0 to 6);
    g_hex4 : out std_logic_vector(0 to 6);
    g_hex5 : out std_logic_vector(0 to 6) 
    );
end main;

architecture Behavioral of main is

-- Editable

signal SA: std_logic;
signal SM: std_logic;
signal SB: std_logic;
signal SP: std_logic;
signal entrada: std_logic_vector (3 downto 0);
signal led_salida: std_logic_vector (3 downto 0);

begin

SA<=v_sw(0);
SM<=v_sw(1);
SB<=v_sw(2);
SP<=v_sw(3);
g_led(3 downto 0)<=led_salida;

process(SA,SM,SB,SP)
begin
    entrada<=SP&SB&SM&SA; -- Concatenamos las entradas en una sola variable
end process;

process(entrada)
begin
led_salida<=entrada;
case entrada is
    when "0000" | "0001" | "0011" | "0110" | "1110" =>        -- Rechazados 
        g_hex0<="1111010";
    when "0010"  =>        -- Pequeño
        g_hex0<="0011000";
    when "0111" =>         -- Mediano
        g_hex0<="0001001";
    when "1111" =>         -- Grande
        g_hex0<="0000100";
    when others => g_hex0<="0110000";  
end case;

end process;

end Behavioral;