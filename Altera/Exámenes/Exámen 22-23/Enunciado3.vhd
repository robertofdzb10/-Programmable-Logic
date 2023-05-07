-- Roberto Fernández Barrios

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
signal estado: std_logic_vector (2 downto 0);
signal cont: integer range 0 to 50000;
signal puls_sal: std_logic;
signal estado_contador: std_logic_vector (2 downto 0);
signal seg: integer range 0 to 500000000;
signal contador: std_logic_vector (3 downto 0);
signal inicio: std_logic;
signal pulsador: std_logic;
signal frito: std_logic;
signal ledfrito: std_logic;

begin

inicio<=v_bt(0);
pulsador<=v_bt(1);
g_led(0)<=ledfrito;

process(inicio, g_clock_50, pulsador)
begin
if inicio='0' then
    estado<="000";
    frito <= '0';
    ledfrito<='0';
elsif rising_edge(g_clock_50) then
    case estado is
    when "000" =>
        cont<=0;
        seg<=0;
        if pulsador='0' then
            estado<="001";
        end if;           
    when "001" =>
        cont<=cont+1;
        seg<=0;
        if pulsador = '1' then
            estado<="000";
        else
            if pulsador='0' and cont = 50000 then --Error número uno, tiene que ser IGUAL a 50 000 para pasar, de manera que se eviten los rebotes
                estado<="010";
            end if;
        end if;
    when "010" =>
        cont<=0; 
        seg<=0;
        if pulsador='1' then 
            estado<="011";
        end if;
    when "011" => --Error número dos, estado entero
        cont<=0; 
        seg<=seg+1;
        if pulsador='0' and seg >= 20000000 and seg <= 30000000 then 
            frito <= '1';
            estado <= "111"; 
        elsif pulsador='0' and seg < 20000000 then 
            estado<="000";
        elsif seg > 30000000 then
            estado <= "100"; 
        end if;
    when "100" => --Error número dos, estado entero
        cont<=0; 
        seg<=seg+1;
        if pulsador='0' and seg >= 50000000 then 
            estado<="101";
        elsif pulsador='0' and seg < 50000000 then 
            estado<="000";
        end if;
    when "101" =>
        cont<=0; 
        seg<=0;
        if pulsador='1' then 
            estado<="110";
        end if;
    when "110" =>
        cont<=0; 
        seg<=0;
        estado<="000";
    when "111" =>
        ledfrito<='1';
        cont<=0; 
        seg<=0;
    when others =>
        estado<="000";
    end case;
end if;
end process; 

process(estado)
begin
case estado is
when "000" => puls_sal<='0';
when "001" => puls_sal<='0';
when "010" => puls_sal<='0'; -- Error 
when "011" => puls_sal<='0';
when "100" => puls_sal<='0';
when "101" => puls_sal<='0';
when "110" => puls_sal<='1';
when "111" => puls_sal<='1';
when others => puls_sal<='0';
end case;
end process;


process(g_clock_50, inicio)
begin
if inicio='0' then
    contador<="0000";
elsif rising_edge(g_clock_50) then
    if puls_sal='1' and frito = '0' then
        if contador="1001" then
            contador<="0000";
        else
            contador<=contador+1;
        end if;
    end if;
end if;
end process;
               
process(contador)
begin
case contador is
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
end process;
            

end Behavioral;

