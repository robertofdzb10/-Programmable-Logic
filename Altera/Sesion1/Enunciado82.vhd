library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_signed.all; -- Revisar si se ha de cambiar

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
signal num_a_integer: integer range -8 to 7; -- Introducimos una varible integer indicando su rango
signal num_b_integer: integer range -8 to 7;
signal selector: std_logic;
signal resultado: integer range -16 to 14; -- El rango del resultado será la suma máxima y la resta máxima posibles (-8 -8 =-16 / +7 +7 = 14)
signal resultado_sin_signo: std_logic_vector (4 downto 0); -- Hemos de hacerlo de 5 bits, ya que el número 16 no entra en 4 bits
signal led_resultado: std_logic_vector (4 downto 0);
signal led_signo: std_logic;

begin

num_a<=v_sw(3 downto 0);
num_b<=v_sw(7 downto 4);
selector<=v_bt(0);
g_led(4 downto 0)<=led_resultado;
g_led(5)<=led_signo;

num_a_integer<=to_integer(signed(num_a)); -- Convertimos la señal con signo num_a a un integer 
num_b_integer<=to_integer(signed(num_b));  

process(selector,num_a_integer, num_b_integer)
begin
    if (selector <= '0') then 
        if (num_a_integer > num_b_integer) then
            resultado <= num_a_integer - num_b_integer;
        else 
            resultado <= num_b_integer - num_a_integer;
        end if;
    else 
        resultado <= num_a_integer + num_b_integer;
    end if;
end process;

process(resultado)
begin
    resultado_sin_signo<=std_logic_vector(to_unsigned(resultado, 5)); -- Covertimos en std_logic_vector la variable sesultado, haciendola a la vez unsigned, con un tamño de 5 bits.
    case resultado_sin_signo is
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
    led_resultado <= resultado_sin_signo;
    if (resultado >= 0) then
        led_signo <= '0';
    else 
        led_signo <= '1';
    end if;
end process;
end Behavioral;