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

signal inicio: std_logic;
signal bt: std_logic;
signal salida: std_logic;
signal estado: std_logic_vector (2 downto 0);
signal contador: std_logic_vector (3 downto 0);
signal contador_rebotes: integer range 0 to 50000;
signal segundero: integer range 0 to 50000000;

begin

g_led(0)<=salida;
inicio<=v_bt(0);
bt<=v_bt(1);

process(inicio, g_clock_50)
begin
if (inicio='0') then 
   estado<="000";
elsif ( (g_clock_50 = '1') and (g_clock_50'event) ) then -- (Flanco de subida) Esta condición se evalúa como verdadera si la señal g_clock_50 es igual a '1' y ha ocurrido un evento en la señal g_clock_50. Un evento se produce en la señal g_clock_50 cuando cambia de valor, ya sea de '0' a '1' o de '1' a '0'. 
    case estado is
        when "000" => -- Estamos en Inicio
            if (bt = '1') then
                estado <= "001";
            else
                estado <= "000";
            end if;
        when "001" => -- Estamos en Inicio
            if ( (bt = '1') and (contador_rebotes < 500000) ) then
                estado <= "001";
            elsif (bt = '0') then 
                estado <= "000";
            else
                estado <= "010";
            end if;
        when "010" => -- Estamos en Inicio
            if (bt = '1') then
                estado <= "010";
            elsif (bt = '0') then 
                estado <= "011";
            else
                estado <= "010";
            end if;
        when "011" => -- Estamos en Inicio
            if ( (bt = '1') and (contador_rebotes < 500000) ) then
                estado <= "011";
            elsif (bt = '0') then 
                estado <= "000";
            else
                estado <= "101";
            end if;
        when "101" => -- Estamos en Inicio
            if (bt = '1') then
                estado <= "101";
            elsif ( (bt = '0') and (segundero < 50000000) ) then 
                estado <= "110";
            else
                estado <= "000";
            end if;
        when "110" => -- Estamos en Inicio
           estado <= "000"; 
        when others =>
            estado <= "000";
    end case;
end if;
end process;

process(estado)
begin
case estado is
    when "000" => 
        contador_rebotes <= 0;
        segundero <= 0;
        salida <= '0';
    when "001" | "011"  =>
        contador_rebotes <= contador_rebotes + 1;
        segundero <= segundero + 1;
        salida <= '0';
    when "010" | "101" =>
        contador_rebotes <= 0;
        segundero <= segundero + 1;
        salida <= '0';
    when "110" =>
        contador_rebotes <= 0;
        segundero <= 0;
        salida <= '1';
    when others => 
        contador_rebotes <= 0;
        segundero <= 0;
        salida <= '0';
end case;

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

end process;

end Behavioral;