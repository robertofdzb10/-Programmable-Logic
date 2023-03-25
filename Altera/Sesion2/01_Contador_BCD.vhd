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

signal contador: std_logic_vector (3 downto 0);
signal boton_reinicio: std_logic;
signal led_contador: std_logic_vector(3 downto 0);

begin

boton_reinicio<=v_bt(0);
g_led(3 downto 0)<=led_contador;

process(boton_reinicio, g_clock_50)
begin
   if (boton_reinicio = '0') then
      contador <= "0000"; -- Si pulsamos inicio reiniciamos el contador 
   elsif rising_edge(g_clock_50) then -- El reloj trabaja a 50MHz (Cada 0,0000002s)
     if (contador="1001") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
        contador<="0000";
     else
        contador<=contador+1; 
     end if;
   end if;
end process;

process(contador)
begin
   case contador is
      when "0000" => g_hex0 <="0000001";
      when "0001" => g_hex0 <="1001111";
      when "0010" => g_hex0 <="0010010";
      when "0011" => g_hex0 <="0000110";
      when "0100" => g_hex0 <="1001100";
      when "0101" => g_hex0 <="0100100";
      when "0110" => g_hex0 <="1100000";
      when "0111" => g_hex0 <="0001111";
      when "1000" => g_hex0 <="0000000";
      when "1001" => g_hex0 <="0001100";
      when others => g_hex0 <="1111111";
   end case;
   led_contador<= contador;
end process;


end Behavioral;