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
signal contador_rebotes: integer range 0 to 50000; -- Para que duren mínimo 1MS las pulsaciones, de manera que no sean rebotes
signal segundero: integer range 0 to 500000000; -- Hay que poner un rango algo superior al deseado, de manera que pueda sobrepasar el límite, sino siempre se va a quedar en el límite y pasará el if

begin

g_led(3)<=salida;
inicio<=v_bt(0);
bt<=v_bt(1);
g_led(2 downto 0)<= estado;

process(inicio, g_clock_50, bt)
begin
if (inicio='0') then 
    estado<="000";
    contador_rebotes <= 0;
    segundero <= 0;
    salida <= '0';
    contador <= "0000"; 
elsif ( rising_edge(g_clock_50) ) then 
    case estado is
        when "000" => 
            contador_rebotes <= 0;
            segundero <= 0;
            salida <= '0';
            if (bt = '0') then
                estado <= "001";
            elsif (bt = '1') then
                estado <= "000";
            end if;
        when "001" =>
            contador_rebotes <= contador_rebotes + 1;
            segundero <= segundero + 1;
            salida <= '0'; 
            if ( (bt = '0') and (contador_rebotes < 50000) ) then
                estado <= "001";
            elsif ( (bt = '0') and (contador_rebotes = 50000) ) then
                estado <= "010";
            elsif (bt = '1') then
                estado <= "000";
            end if;
        when "010" => 
            contador_rebotes <= 0;
            segundero <= segundero + 1;
            salida <= '0';
            if (bt = '0') then
                estado <= "010";
            elsif (bt = '1') then
                estado <= "011";
            end if;
        when "011" => 
            contador_rebotes <= 0;
            segundero <= segundero + 1;
            salida <= '0';
            if (bt = '1') then
                estado <= "011";
            elsif (bt = '0') then
                estado <= "100";
            end if;
        when "100" => 
            contador_rebotes <= contador_rebotes + 1;
            segundero <= segundero + 1;
            salida <= '0';
            if ( (bt = '0') and (contador_rebotes < 50000) ) then
                estado <= "100";
            elsif ( (bt = '0') and (contador_rebotes = 50000) ) then
                estado <= "101";
            elsif (bt  = '1') then
                estado <= "000";
            end if;
        when "101" => 
            contador_rebotes <= 0;
            segundero <= segundero + 1;
            salida <= '0';
            if (bt = '0') then
                estado <= "101";
            elsif ( (bt = '1') and (segundero < 50000000) ) then 
                estado <= "110";
            elsif (segundero >= 50000000) then
                estado <= "000";
            end if;
        when "110" => 
            if (contador < "1001") then 
                contador <= contador + 1;
            else
                contador <= contador;
            end if;
            contador_rebotes <= 0;
            segundero <= 0;
            salida <= '1';
            estado <= "000"; 
        when others =>
            salida <= '0';
            estado <= "000";
    end case;
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

end process;

end Behavioral;