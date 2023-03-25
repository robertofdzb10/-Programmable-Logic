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
signal contador_minutos: std_logic_vector (3 downto 0);
signal contador_minutos_decenas: std_logic_vector (3 downto 0);
signal contador_horas: std_logic_vector (3 downto 0);
signal contador_horas_decenas: std_logic_vector (3 downto 0);
signal dia_semana: std_logic_vector (2 downto 0);
signal contador_base: integer range 0 to 50000000;
signal boton_reinicio: std_logic;
signal led_contador: std_logic_vector(3 downto 0);

begin

boton_reinicio<=v_bt(0);


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

process(boton_reinicio, contador_base, g_clock_50)
begin
   if (boton_reinicio = '0') then
      contador_segundos <= "0000"; -- Si pulsamos inicio reiniciamos todos los contadores
      contador_segundos_decenas <= "0000";
      contador_minutos <= "0000";
      contador_minutos_decenas <= "0000";
   elsif rising_edge(g_clock_50) then -- Se comprueba cada ciclo de reloj, para evitar que se este comprobando constantemente
      if (contador_base = 50000000) then
         if (contador_segundos = "1001") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
            contador_segundos <= "0000";
            if (contador_segundos_decenas = "0101" ) then
               contador_segundos_decenas<="0000";
                if (contador_minutos = "1001") then 
                    contador_minutos <= "0000";
                    if (contador_minutos_decenas = "0101") then 
                        contador_minutos_decenas <= "0000";
                        if (contador_horas = "1001") then 
                            contador_horas <= "0000";
                            if (contador_horas_decenas = "0101") then 
                                contador_horas_decenas<= "0000";
                            else
                                contador_horas_decenas <= contador_horas_decenas + 1;
                            end if;
                        else
                            contador_horas <= contador_horas + 1;
                        end if;
                    else
                        contador_minutos_decenas <= contador_minutos_decenas + 1;
                    end if;
                else
                    contador_minutos <= contador_minutos + 1;
                end if;
            else
               contador_segundos_decenas<= contador_segundos_decenas + 1;
            end if;
         else
            contador_segundos<=contador_segundos+1; 
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

process(contador_minutos)
begin
   case contador_minutos is
      when "0000" => g_hex2 <="0000001";
      when "0001" => g_hex2 <="1001111";
      when "0010" => g_hex2 <="0010010";
      when "0011" => g_hex2 <="0000110";
      when "0100" => g_hex2 <="1001100";
      when "0101" => g_hex2 <="0100100";
      when "0110" => g_hex2 <="1100000";
      when "0111" => g_hex2 <="0001111";
      when "1000" => g_hex2 <="0000000";
      when "1001" => g_hex2 <="0001100";
      when others => g_hex2 <="1111111";
   end case;
end process;

process(contador_minutos_decenas)
begin
   case contador_minutos_decenas is
      when "0000" => g_hex3 <="0000001";
      when "0001" => g_hex3 <="1001111";
      when "0010" => g_hex3 <="0010010";
      when "0011" => g_hex3 <="0000110";
      when "0100" => g_hex3 <="1001100";
      when "0101" => g_hex3 <="0100100";
      when "0110" => g_hex3 <="1100000";
      when "0111" => g_hex3 <="0001111";
      when "1000" => g_hex3 <="0000000";
      when "1001" => g_hex3 <="0001100";
      when others => g_hex3 <="1111111";
   end case;
end process;

process(contador_horas)
begin
   case contador_horas is
      when "0000" => g_hex4 <="0000001";
      when "0001" => g_hex4 <="1001111";
      when "0010" => g_hex4 <="0010010";
      when "0011" => g_hex4 <="0000110";
      when "0100" => g_hex4 <="1001100";
      when "0101" => g_hex4 <="0100100";
      when "0110" => g_hex4 <="1100000";
      when "0111" => g_hex4 <="0001111";
      when "1000" => g_hex4 <="0000000";
      when "1001" => g_hex4 <="0001100";
      when others => g_hex4 <="1111111";
   end case;
end process;

process(contador_horas_decenas)
begin
   case contador_horas_decenas is
      when "0000" => g_hex5 <="0000001";
      when "0001" => g_hex5 <="1001111";
      when "0010" => g_hex5 <="0010010";
      when "0011" => g_hex5 <="0000110";
      when "0100" => g_hex5 <="1001100";
      when "0101" => g_hex5 <="0100100";
      when "0110" => g_hex5 <="1100000";
      when "0111" => g_hex5 <="0001111";
      when "1000" => g_hex5 <="0000000";
      when "1001" => g_hex5 <="0001100";
      when others => g_hex5 <="1111111";
   end case;
end process;

end Behavioral;