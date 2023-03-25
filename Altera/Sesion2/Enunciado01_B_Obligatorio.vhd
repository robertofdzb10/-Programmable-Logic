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

signal contador: std_logic_vector (3 downto 0);
signal contador_base: integer range 0 to 50000000;
signal boton_reinicio: std_logic;
signal led_contador: std_logic_vector(3 downto 0);
signal sw_op_1: std_logic;
signal sw_op_2: std_logic;
signal sw_op_3: std_logic;
signal sw_op_4: std_logic;
signal sw_par: std_logic;
signal bt_par_pulsado: std_logic;
signal vuelta_subida: std_logic;
signal contador_iteracion: std_logic_vector(1 downto 0);

begin 

boton_reinicio<=v_bt(0);
-- Por defecto el programa llega hasta 9, y luego se reinicia a cero, no obstante, al activar alguno de los sw, se habilitan los diferentes modos de funcioanmiento
sw_op_1<=v_sw(0); -- Opción 1 --> Mantener el 9 (Combinable con culquiera de los otros modos, en cuyo caso mantendra el número mas alto correspondiente)
sw_op_2<=v_sw(1); -- Opción 2 --> Que suba hasta nueve, y luego baje de nueve a cero, y así sucesivamente
sw_op_3<=v_sw(2); -- Opción 3 --> Muestra la secuencia de números pares o impares, llegando hasta el último y reiniciando a 0, para repetir el proceso indefinidamente
sw_par<=v_sw(3); -- Sw para alterar entre par e impar
sw_op_4<=v_sw(4); -- Opción 4 --> Muestra la secuencia de números primos, llegando hasta el último y reiniciando a 0, para repetir el proceso indefinidamente
g_led(3 downto 0)<=led_contador;


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

process(boton_reinicio,contador_base, g_clock_50, sw_op_1, sw_op_2, sw_op_3, sw_op_4, vuelta_subida, sw_par)
begin
   if (boton_reinicio = '0') then
      contador <= "0000"; -- Si pulsamos inicio reiniciamos el contador 
   elsif rising_edge(g_clock_50) then -- Se comprueba cada ciclo de reloj, para evitar que se este comprobando constantemente
      if (contador_base = 50000000) then

         if (sw_op_2 = '1') then -- Si el sw_op_2 esta pulsado que suba hasta nueve, y luego baje de nueve a cero, y así sucesivamente
            if (contador = "1001") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
               if (sw_op_1 = '1') then -- Si el sw_op_1 esta pulsado, mantenemos el 9
                  contador <= "1001";
               else
                  vuelta_subida <= '0';
                  contador <= contador - 1;
               end if;
            else
               if (contador = "0000") then
                  vuelta_subida <= '1';
                  contador<= contador + 1; 
               elsif (vuelta_subida = '1') then
                  contador<= contador + 1; 
               else
                  contador<= contador - 1; 
               end if;
            end if;

         elsif (sw_op_3 = '1') then -- Si el sw_op_3 esta pulsado lleva a cabo la secuencia de números pares o impares, llegando hasta el último y reiniciando a 0, para repetir el proceso indefinidamente
            contador_iteracion <= "00"; -- Por defecto ponemos el contador de la opción 4 a cero, por si cambiaramos a ese modo
            vuelta_subida <= '1'; -- Por defecto siempre vamos a estar subiendo
            if (sw_par = '1') then -- Si pulsamos el botón de par, altermos entre par e impar
               bt_par_pulsado <= '1';
               contador <= "0000";
            elsif( (sw_par = '0') and (bt_par_pulsado = '1') ) then --Si fue pùslado el botón para que fuera par y luego soltado, entra por esta sentencia
               bt_par_pulsado <= '0';
               contador <= "0001";
            else 
               contador <= contador;
            end if;

            if ( (contador = "1000") or (contador = "1001") ) then -- Si el contador llega a 9 (impares) o a 8(pares)
               if (sw_op_1 = '1') then -- Si el sw_op_1 esta pulsado, mantenemos el 9 o el 8
                  if (sw_par = '1') then
                     contador <= "1000";
                  else
                     contador <= "1001";
                  end if;
               else
                  if (sw_par = '1') then
                     contador <= "0000";
                  else
                     contador <= "0001";
                  end if;
               end if;
            else
               if ( (sw_par = '1') and (contador(0) /= '0') ) then -- Para los casos en los que se cambie de modo, y estemos en modo par pero entremos con un número impar (Comprobamos si el bit menos significativo del número es cero (lo que indica que el número es par), siendo este disitnto del número 0)
                  contador<= contador + 1; 
               elsif( (contador /= "0000") and (sw_par = '0') and (contador(0) = '0')) then -- Para los casos en los que se cambie de modo, y estemos en modo impapar pero entremos con un número par (Comprobamos si el bit menos significativo del número no es cero (lo que indica que el número es impar))
                  contador<= contador + 1; 
               else 
                  contador<= contador + 2; 
               end if;
            end if;--Sumar dos, y si es par empezar por 0 y si es impar por 1

         elsif (sw_op_4 = '1') then -- Si el sw_op_4 esta pulsado lleva a cabo la secuencia de de números primos, llegando hasta el último y reiniciando a 0, para repetir el proceso indefinidamente
            vuelta_subida <= '1'; -- Por defecto siempre vamos a estar subiendo
            if (contador = "0111") then -- Si el contador llega a 7 reiniciamos a 0 
               if (sw_op_1 = '1') then -- Si el sw_op_1 esta pulsado, mantenemos el 9
                  contador_iteracion <= "00";
                  contador <= "0111";
               else
                  contador_iteracion <= "00";
                  contador <= "0010"; -- Pongamos que nos es primo y probar todo
               end if;
            else
               case contador_iteracion is
                  when "00" => contador <= "0011";
                  when "01" => contador <= "0101";
                  when others => contador <= "0111";
               end case;
               contador_iteracion <= contador_iteracion + 1;
            end if;

         else
            vuelta_subida <= '1'; -- Por defecto siempre vamos a estar subiendo
            contador_iteracion <= "00"; -- Por defecto ponemos el contador de la opción 4 a cero, por si cambiaramos a ese modo
            if (contador = "1001") then -- Si el contador llega a 9 reiniciamos a 0 (Característica del contador BCD)
               if (sw_op_1 = '1') then -- Si el sw_op_1 esta pulsado, mantenemos el 9
                  contador <= "1001";
               else
                  contador <= "0000";
               end if;
            else
               contador<= contador + 1; 
            end if;
         end if;

      end if;
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
   led_contador<= contador;
end process;


end Behavioral;