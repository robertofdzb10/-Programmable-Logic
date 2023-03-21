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
signal selector: std_logic;
signal resultado: std_logic_vector (3 downto 0); 
signal led_resultado: std_logic_vector (3 downto 0);
signal led_signo: std_logic;
signal led_resta: std_logic;




begin

num_a<=v_sw(3 downto 0);
num_b<=v_sw(7 downto 4);
selector<=v_bt(0);
g_led(3 downto 0)<=led_resultado;
g_led(4)<=led_signo;
g_led(5)<=led_resta;


process(num_a, num_b)
begin
    if (selector <= '0') then 
        led_resta <= '0';
        --if ( (num_a + num_b) >= 10) then
        --    resultado <= num_a + num_b - 10;
        --else 
            resultado <= num_a + num_b;
        --end if;
    else 
        led_resta <= '1';
        if (num_a > num_b) then
            --if ((num_a - num_b) <= -10) then 
            --    resultado <= num_a - num_b + 10;
            --else 
                resultado <= num_a - num_b;
            --end if;
        else 
            --if ((num_b - num_a) <= -10) then 
            --    resultado <= num_b - num_a + 10;
            --else 
                resultado <= num_b - num_a;
            --end if;
        end if;
    end if;
    case resultado is
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
        when others => g_hex0<="0110000";
    end case;
    led_resultado <= resultado;
    if (resultado >= 0) then
        led_signo <= '0';
    else 
        led_signo <= '1';
    end if;
end process;
end Behavioral;