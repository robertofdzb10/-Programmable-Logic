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

signal num_a: std_logic_vector (3 downto 0);
signal num_b: std_logic_vector (3 downto 0);
signal suma: std_logic_vector (4 downto 0); -- En 4 bits no entra el resultado de la suma si es 15 + 15, se necesitan 5 bits
signal suma_t: std_logic_vector (4 downto 0); -- En 4 bits no entra
signal num_a_t: std_logic_vector (4 downto 0); 
signal num_b_t: std_logic_vector (4 downto 0);
signal cout: std_logic;

begin

num_a<=v_sw(3 downto 0);
num_b<=v_sw(7 downto 4);
g_led(0)<=cout;

process(num_a, num_b)
begin
    num_a_t <= '0'&num_a; -- Hemos de convertir num_a a un número de 5 bits, el operador & representa la concatenaciónd de bits, por lo que estaríamos introduciendo un 0 a la izquierda, obteniendo así un número de 5 bits
    num_b_t <= '0'&num_b; -- Los números en binario van entre ''
    suma_t <= (num_a_t + num_b_t);
end process;

process(suma_t)
begin

if (suma_t >= 30) then
    suma <= (suma_t - 30);
    cout <= '1';
elsif (suma_t >= 20) then
    suma <= (suma_t - 20);
    cout <= '1';
elsif (suma_t >= 10) then
    suma <= (suma_t - 10);
    cout <= '1';
else
    suma <= suma_t;
    cout <= '0';
end if;

case suma is
    when "00000" => g_hex0<="0000001";
    when "00001" => g_hex0<="1001111";
    when "00010" => g_hex0<="0010010";
    when "00011" => g_hex0<="0000110";
    when "00100" => g_hex0<="1001100";
    when "00101" => g_hex0<="0100100";
    when "00110" => g_hex0<="1100000";
    when "00111" => g_hex0<="0001111";
    when "01000" => g_hex0<="0000000";
    when "01001" => g_hex0<="0001100";
    when others => g_hex0<="0110000";
end case;

end process;

end Behavioral;