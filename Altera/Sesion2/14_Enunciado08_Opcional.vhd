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

signal contador_segundos: std_logic_vector (3 downto 0);
signal contador_segundos_decenas: std_logic_vector (3 downto 0);
signal contador_base: integer range 0 to 50000000;
signal boton_reinicio: std_logic;
signal bajar: std_logic; -- := Sirve para la declaración de variables, asignanado el valor inmediatamente

begin

boton_reinicio<=v_bt(0);
g_led(0)<=bajar;


process(boton_reinicio, g_clock_50)
begin
   if (boton_reinicio = '0') then -- ¡Botones activos por nivél bajo! --> 0 es pulsado
        contador_base <= 0; -- Si pulsamos inicio reiniciamos el contador base
   elsif rising_edge(g_clock_50) then -- El reloj trabaja a 50MHz (Cada 0,0000002s)
      if (contador_base = 50000000) then -- De esta manera estamos dividiendo 50Mhz entre 50M, por lo que el resultado es 1hz o lo que es lo mismo, 1s
        contador_base <= 0;
      else
        contador_base <= contador_base + 1;
      end if;
   end if;
end process;

process(boton_reinicio)
begin
    if (boton_reinicio = '0') then
      contador_segundos <= "0000"; -- Si pulsamos inicio reiniciamos todos los contadores
      contador_segundos_decenas <= "0000";
      bajar <= '0';
    else
    end if;
end process;

process(g_clock_50, contador_base, bajar)
begin
    if rising_edge(g_clock_50) then -- Se comprueba cada ciclo de reloj, para evitar que se este comprobando constantemente
        if (bajar = '0') then 
            if (contador_base = 50000000) then
                if (contador_segundos = "1001") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
                    contador_segundos <= "0000";
                    if (contador_segundos_decenas = "0101" ) then
                        contador_segundos_decenas<= contador_segundos_decenas + 1;
                        bajar <= '1'; -- Cuando llegue a un minuto se para yempieza a bajar
                    else
                        contador_segundos_decenas<= contador_segundos_decenas + 1;
                    end if;
                else
                    contador_segundos<=contador_segundos+1; 
                end if;
            end if;
        else
            if (contador_base = 50000000) then
                if (contador_segundos = "0000") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
                    contador_segundos <= "1001";
                    if (contador_segundos_decenas = "0000" ) then
                        bajar <= '0'; -- Cuando llegue a un minuto se para y empieza a subir
                    else
                        contador_segundos_decenas<= contador_segundos_decenas - 1;
                    end if;
                else
                    contador_segundos<=contador_segundos - 1; 
                end if;
            end if;
        end if;
    end if;
end process;


process(contador_segundos)
begin
   case contador_segundos is
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

process(contador_segundos_decenas)
begin
   case contador_segundos_decenas is
      when "0000" => g_hex1 <="0000001";
      when "0001" => g_hex1 <="1001111";
      when "0010" => g_hex1 <="0010010";
      when "0011" => g_hex1 <="0000110";
      when "0100" => g_hex1 <="1001100";
      when "0101" => g_hex1 <="0100100";
      when "0110" => g_hex1 <="1100000";
      when "0111" => g_hex1 <="0001111";
      when "1000" => g_hex1 <="0000000";
      when "1001" => g_hex1 <="0001100";
      when others => g_hex1 <="1111111";
   end case;
end process;

end Behavioral;