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
signal mayor: std_logic;
signal igual: std_logic;
signal menor: std_logic;


begin

num_a<=v_sw(3 downto 0);
num_b<=v_sw(7 downto 4);
g_led(0)<=mayor;
g_led(1)<=igual;
g_led(2)<=menor;


process(num_a, num_b)
begin
if (num_a <= 5 and num_a >= -5 and num_b <= 5 and num_b >= -5) then
    if (num_a > num_b) then
        mayor <= '1';
        igual <= '0';
        menor <= '0';
    elsif (num_b > num_a) then
        mayor <= '0';
        igual <= '0';
        menor <= '1';
    else
        mayor <= '0';
        igual <= '1';
        menor <= '0';
    end if;
else 
    mayor <= '0';
    igual <= '0';
    menor <= '0';
end if;
end process;

end Behavioral;