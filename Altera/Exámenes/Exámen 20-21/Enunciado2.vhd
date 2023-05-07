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

signal inicio: std_logic;
signal boton: std_logic;
signal contador_base: integer range 0 to 5000000;
signal led_0: std_logic;
signal led_1: std_logic;
signal led_2: std_logic;
signal led_3: std_logic;
signal led_4: std_logic;
signal led_5: std_logic;
signal led_6: std_logic;
signal led_7: std_logic;
signal led_8: std_logic;
signal led_9: std_logic;

begin

inicio<= v_bt(0);
g_led(0) <= led_0;
g_led(1) <= led_1;
g_led(2) <= led_2;
g_led(3) <= led_3;
g_led(4) <= led_4;
g_led(5) <= led_5;
g_led(6) <= led_6;
g_led(7) <= led_7;
g_led(8) <= led_8;
g_led(9) <= led_9;

process(g_clock_50, inicio)
begin
    if (inicio = '0') then
        contador_base <= 0;
    elsif (rising_edge(g_clock_50)) then
        if (contador_base < 5000000) then 
            contador_base <= contador_base + 1;
        else 
            contador_base <= 0;
        end if;
    end if;
end process;

process(g_clock_50, inicio)
begin
    g_hex0<="1111111";
    g_hex1<="1111111";    
    g_hex2<="1111111";
    g_hex3<="1111111";    
    g_hex4<="1111111";
    g_hex5<="1111111";
    if (inicio = '0') then
        led_0 <= '0';
        led_1 <= '0';
        led_2 <= '0';
        led_3 <= '0';
        led_4 <= '0';
        led_5 <= '0';
        led_6 <= '0';
        led_7 <= '0';
        led_8 <= '0';
        led_9 <= '0';
    elsif (rising_edge(g_clock_50)) then
        if (contador_base = 5000000) then
            if (led_9 = '1') then
                if (led_8 = '1') then
                    if (led_7 = '1') then
                        if (led_6 = '1') then
                            if (led_5 = '1') then
                                if (led_4 = '1') then
                                    if (led_3 = '1') then
                                        if (led_2 = '1') then
                                            if (led_1 = '1') then
                                                if (led_0 = '1') then
                                                    led_0 <= '0';
                                                    led_1 <= '0';
                                                    led_2 <= '0';
                                                    led_3 <= '0';
                                                    led_4 <= '0';
                                                    led_5 <= '0';
                                                    led_6 <= '0';
                                                    led_7 <= '0';
                                                    led_8 <= '0';
                                                    led_9 <= '0';
                                                else
                                                    led_0 <= '1';
                                                end if;
                                            else
                                                led_1 <= '1';
                                            end if;
                                        else
                                            led_2 <= '1';
                                        end if;
                                    else
                                        led_3 <= '1';
                                    end if;
                                else
                                    led_4 <= '1';
                                end if;
                             else
                                led_5 <= '1';
                            end if;
                        else
                            led_6 <= '1';
                        end if;
                    else
                        led_7 <= '1';
                    end if;
                else
                    led_8 <= '1';
                end if;
            else
                led_9 <= '1';
            end if;
        end if;
    end if;
end process;

end Behavioral;