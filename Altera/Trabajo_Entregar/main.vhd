library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;



entity main is
Port (
   clk: in std_logic;
   inicio: in std_logic;
   sw_blq_stepper: in std_logic; -- Switch para permitir el bloqueo o desbloqueo del stepper
   sw_stepper: in std_logic; -- Switch para activar el stepper
   enable_seg: out std_logic_vector(3 downto 0);
   segmentos: out std_logic_vector(6 downto 0);
   modo_funcionamiento: in std_logic_vector(1 downto 0);
   parada: in std_logic;
   
   boton_U: in std_logic;
   boton_D: in std_logic;
   boton_L: in std_logic;
   boton_R: in std_logic;   
   
   motor_DC_On: in std_logic_vector (1 downto 0); -- Enciende el motor DC
   pwm_motor_DC: in std_logic_vector(3 downto 0); 
 
   en_stepper: out std_logic;
   FC2_Tarj: in std_logic;
   FC1_Cale: in std_logic;

   led: out std_logic_vector(15 downto 0);
   sw: in std_logic_vector(3 downto 0);
   DIR: out std_logic;
   STEP: out std_logic;
   ECHO: in std_logic;
   TRIGGER: out std_logic; 

   ds_data_bus: INOUT	STD_LOGIC -- Aparece en apuntes de clase
   );
end main;

architecture Behavioral of main is

------ Signals -------

-- Signals para filtrado del botón
signal modo_btn_U: std_logic_vector (1 downto 0);
signal modo_btn_R: std_logic_vector (1 downto 0);
signal modo_btn_D: std_logic_vector (1 downto 0);
signal modo_btn_L: std_logic_vector (1 downto 0);

-- Signals para el control 
signal distancia_objetivo: integer range 0 to 1023;
signal velocidad_objetivo: integer range 0 to 1023;

-- Signals para pwmDC
signal estado_pwm: std_logic_vector(2 downto 0);
signal tope_motor_DC: integer range 0 to 500000;
signal contador_pwm: integer range 0 to 500000;

-- Signals para hallDC
signal contador_uno_motor_dc: integer range 0 to 100000;
signal revoluciones_por_minuto: integer range 0 to 9999;
signal estado_hall: std_logic_vector (2 downto 0); 
signal aux_revoluciones_por_minuto: integer range 0 to 9999;
signal contador_automata_motor_dc: integer range 0 to 100000;

-- Conexión del sensor de velocidad hall
signal hall: std_logic_vector (1 downto 0); 
signal contador_sensor_hall: integer range 0 to 1000;

-- Signals para stepper
signal tope_frecuencia_stepper: integer range 0 to 1000000000; -- Para controlar la velocidad
signal frecuencia_stepper_entero: integer range 0 to 10000;
signal direccion_aux: std_logic;
signal reloj_stepper: integer range 0 to 10000000; 
signal stepper_aux: std_logic; -- Para generar la salida

-- Signals para distancia
signal contador_echo: integer range 0 to 60000;
signal distancia_entero: integer range 0 to 1023; 
signal contador_micros: integer range 0 to 60000; 
signal contador_base_Distancia: integer range 0 to 100; 

-- Signals para binario a bcd
signal variable_apoyo: std_logic_vector (29 downto 0); 
signal final: std_logic; 
signal contador_reloj_binario_bcd: integer range 0 to 100000000; 
signal estado_binario_bcd: std_logic_vector (1 downto 0); 
signal contador_bits: integer range 0 to 13; 
signal un: std_logic_vector (3 downto 0); 
signal dec: std_logic_vector (3 downto 0); 
signal cen: std_logic_vector (3 downto 0);
signal mil: std_logic_vector (3 downto 0);

-- Signals para Reloj
signal contador_base: integer range 0 to 100000000;
signal contador_enable_aux: integer range 0 to 100000;
signal enable_seg_aux: std_logic_vector (3 downto 0);
signal contador_reloj_seg_unidades: std_logic_vector (3 downto 0);
signal contador_reloj_seg_decenas: std_logic_vector (3 downto 0);
signal contador_reloj_min_unidades: std_logic_vector (3 downto 0);
signal contador_reloj_min_decenas: std_logic_vector (3 downto 0);

-- Más signals
signal salida_pantalla: std_logic_vector (3 downto 0); 
signal rotar_derecha: std_logic;
signal rotar_izquierda: std_logic;
signal disminuir_valor: std_logic; 
signal aumentar_valor: std_logic; 
signal salida_reloj: std_logic_vector(15 downto 0);
signal distancia_actual: std_logic_vector(13 downto 0); 
signal salida_7_seg: std_logic_vector(15 downto 0); 
signal control_Stepper: std_logic_vector(1 downto 0); 
signal multiplexado_Sensores: std_logic_vector(13 downto 0);
signal valor_BCD: std_logic_vector(15 downto 0); 
signal valor_Velocidad: std_logic_vector(13 downto 0); 
signal modo_menu: std_logic_vector(2 downto 0); 


------ Procesos -------

begin


-- Pasos previos
led <= modo_menu & "0000000000000";
hall <= motor_DC_On;


-- Gestión de la lógica de los botones

-- Filtrado de botón U
process(inicio, clk)
begin
if inicio='1' then
    modo_btn_U<="00";
elsif rising_edge(clk) then
    case modo_btn_U is
    when "00" =>
        if boton_U='0' then
            modo_btn_U<="00";
        else
            modo_btn_U<="01";
        end if;           
    when "01" =>
        if boton_U='0' then
            modo_btn_U<="10";
        else
            modo_btn_U<="01";
        end if;
    when "10" =>
        modo_btn_U<="00";
    when others =>
        modo_btn_U<="00";
    end case;
end if;
end process; 

process(modo_btn_U)
begin
case modo_btn_U is
when "00" => aumentar_valor<='0';
when "01" => aumentar_valor<='0';
when "10" => aumentar_valor<='1';
when others => aumentar_valor<='0';
end case;
end process;

---- Filtrado de botón D
process(inicio, clk)
begin
if inicio='1' then
    modo_btn_D<="00";
elsif rising_edge(clk) then
    case modo_btn_D is
    when "00" =>
        if boton_D='0' then
            modo_btn_D<="00";
        else
            modo_btn_D<="01";
        end if;           
    when "01" =>
        if boton_D='0' then
            modo_btn_D<="10";
        else
            modo_btn_D<="01";
        end if;
    when "10" =>
        modo_btn_D<="00";
    when others =>
        modo_btn_D<="00";
    end case;
end if;
end process; 

process(modo_btn_D)
begin
case modo_btn_D is
when "00" => disminuir_valor<='0';
when "01" => disminuir_valor<='0';
when "10" => disminuir_valor<='1';
when others => disminuir_valor<='0';
end case;
end process;

---- Filtrado de botón L
process(inicio, clk)
begin
if inicio='1' then
    modo_btn_L<="00";
elsif rising_edge(clk) then
    case modo_btn_L is
    when "00" =>
        if boton_L='0' then
            modo_btn_L<="00";
        else
            modo_btn_L<="01";
        end if;           
    when "01" =>
        if boton_L='0' then
            modo_btn_L<="10";
        else
            modo_btn_L<="01";
        end if;
    when "10" =>
        modo_btn_L<="00";
    when others =>
        modo_btn_L<="00";
    end case;
end if;
end process; 

process(modo_btn_L)
begin
case modo_btn_L is
when "00" => rotar_izquierda<='0';
when "01" => rotar_izquierda<='0';
when "10" => rotar_izquierda<='1';
when others => rotar_izquierda<='0';
end case;
end process;

---- Filtrado de botón R
process(inicio, clk)
begin
if inicio='1' then
    modo_btn_R<="00";
elsif rising_edge(clk) then
    case modo_btn_R is
    when "00" =>
        if boton_R='0' then
            modo_btn_R<="00";
        else
            modo_btn_R<="01";
        end if;           
    when "01" =>
        if boton_R='0' then
            modo_btn_R<="10";
        else
            modo_btn_R<="01";
        end if;
    when "10" =>
        modo_btn_R<="00";
    when others =>
        modo_btn_R<="00";
    end case;
end if;
end process; 

process(modo_btn_R)
begin
case modo_btn_R is
when "00" => rotar_derecha<='0';
when "01" => rotar_derecha<='0';
when "10" => rotar_derecha<='1';
when others => rotar_derecha<='0';
end case;
end process;


----------- CONTROL -----------

-- Process para los modos de control
process(inicio, clk, modo_funcionamiento)
begin
if inicio = '1'then
    control_Stepper <= "00";
elsif rising_edge(clk) then
case modo_funcionamiento is
    when "00"=> -- Modo Uno,  Ida y vuelta continuo del stepper
        control_Stepper <= "11"; 
    when "10" =>    -- Modo Dos, poner stepper a distancia especificada
        if(distancia_objetivo > distancia_actual)then
            control_Stepper <= "01"; -- Movemos el stepper hacia atras
        elsif (distancia_objetivo < distancia_actual) then
            control_Stepper <= "10"; -- Movemos el stepper hacia adelante
        else control_Stepper <= "00";
        end if;
    when "11" => -- Modo tres, activar el DC
        control_Stepper <= "00";
    when others => control_Stepper <= "00";
end case;
end if;
end process;

--- Process para stepper
frecuencia_stepper_entero<=to_integer(unsigned(sw & "00000")); --Mediante el sw se le introduce el valor máximo de frecuencia para el motor paso a paso
tope_frecuencia_stepper<=(100000000/frecuencia_stepper_entero)/2;

--- Control de Stepper
process(clk, inicio, control_Stepper)
begin 
if inicio = '1' then
    direccion_aux <= '0'; -- La dirección en la que el motor girará, horaria (clockwise) y antihoraria (counterclockwise).
    en_stepper <= sw_stepper;
elsif rising_edge(clk) then
    case control_Stepper is
    when "00" =>    -- Parado
        en_stepper <= '0'; -- El enable del stepper se pone a 1 si la velocidad es mayor que 0.
    when "01" =>    -- En direccion Uno
        direccion_aux <= '1';
        if(FC1_Cale = '1') then -- Si ya hemos llegado al destino, apgamos el stepper
            en_stepper <= '0';
        else
            en_stepper <= sw_stepper;
        end if;
    when "10" =>    -- En direccion contraria
        direccion_aux <= '0';
        if(FC2_Tarj = '1')then -- Si hemos llegado a la tarjeta
            en_stepper <= '0';
        else
            en_stepper <= sw_stepper;
        end if;
    when "11" =>    -- En las 2 direcciones
        en_stepper <= sw_stepper;     
    when others =>
        direccion_aux <= '0';
        en_stepper <= sw_stepper; 
    end case;
end if;
end process;

process(clk)
begin
if inicio='1' then
    reloj_stepper<=0;
elsif rising_edge(clk) then
   if reloj_stepper=tope_frecuencia_stepper then --0 then
        reloj_stepper<=0;
   else
        reloj_stepper<=reloj_stepper+1;
   end if;
end if;
end process;

process(clk)
begin
if clk='1' and clk'event then
    if reloj_stepper=0 then -- con el A
        stepper_aux<=not(stepper_aux);
    end if;
end if;
end process;
DIR<=direccion_aux;

process(clk, sw_blq_stepper)
begin
if(rising_edge(clk))then
    if(sw_blq_stepper = '1')then 
        STEP<=stepper_aux; -- Cuando la señal step cambia de estado (por ejemplo, de '0' a '1' o de '1' a '0'), el motor realiza un paso en la dirección especificada por la señal dir (dirección)
    else
        STEP <= '0';
    end if;
end if;
end process;

-- Insercion de datos por botones
process(clk, inicio, modo_menu)
begin
if inicio = '1' then
elsif rising_edge(clk) then
    case modo_menu is
    when "011" => -- Cambiar la distancia manualmente
        if aumentar_valor = '1' then
            distancia_objetivo <= distancia_objetivo +1;
        elsif disminuir_valor = '1'then
            distancia_objetivo <= distancia_objetivo -1;
        end if;
    when "100" => -- Cambiar la velocidad manualmente
        if parada = '0'then
        if aumentar_valor = '1' then
            velocidad_objetivo <= velocidad_objetivo +1;
        elsif disminuir_valor = '1'then
            velocidad_objetivo <= velocidad_objetivo -1;
        end if;
        end if;
    when others =>
    end case;
end if;
end process;



-- Generación de sel, process para ir variando el valor del sel con los botones
process(clk, inicio)
begin
if inicio = '1' then
    modo_menu <= "000";
elsif rising_edge(clk) then
    if(rotar_derecha = '1')then
        modo_menu<= modo_menu +1;
    elsif(rotar_izquierda = '1')then
        modo_menu <= modo_menu -1;
    end if;
end if;
end process;



--- Process para pwmDC
process(pwm_motor_DC, clk, inicio)
begin
case pwm_motor_DC is
    when "0000" => tope_motor_DC <= 0;
    when "0001" => tope_motor_DC <= 50000;
    when "0010" => tope_motor_DC <= 100000;
    when "0011" => tope_motor_DC <= 150000;
    when "0100" => tope_motor_DC <= 200000;
    when "0101" => tope_motor_DC <= 250000;
    when "0110" => tope_motor_DC <= 300000;
    when "0111" => tope_motor_DC <= 400000;
    when "1001" => tope_motor_DC <= 450000;
    when "1010" => tope_motor_DC <= 500000;
    when others => tope_motor_DC <= 0;
end case;
end process;


--Automata moviento del motor DC en función de los topes
process(inicio, clk)
begin
if inicio = '1' then
    contador_pwm <= 0;
    estado_pwm <= "000";
elsif rising_edge(clk)then
    case estado_pwm is
    when "000" => 
        contador_pwm <= 0;
        if(tope_motor_DC = 0) then
            estado_pwm <= "001";
        else
            estado_pwm <= "010";
        end if;
    when "001" =>                                                                                                                                                                                          
        contador_pwm <= 1;
        estado_pwm <= "011";
    when "010" => 
        contador_pwm <= 1;
        estado_pwm <= "100";   
     when "011" =>
        contador_pwm <= contador_pwm +1;
        if (contador_pwm = 500000 and tope_motor_DC = 0)then
            estado_pwm <= "001";
        elsif (contador_pwm = 500000)then
            estado_pwm <= "010";
        end if;
     when "100" =>
        contador_pwm <= contador_pwm +1;
        if (contador_pwm = tope_motor_DC and tope_motor_DC = 500000)then
            estado_pwm <= "010";
        elsif (contador_pwm = tope_motor_DC)then
            estado_pwm <= "011";
        end if;
     when others => 
        contador_pwm <= 0;
        estado_pwm <= "000";
    end case;
end if;
end process;


--- Process para hallDC
--- Cuenta las revoluciones del motor cada segundo y luego las pasa a la variable rev_per_seg
process(clk, inicio) -- Pendiente
begin
if rising_edge(clk) then
    if inicio='1' then
        contador_uno_motor_dc <= 0;
        contador_automata_motor_dc <= 0;
        revoluciones_por_minuto <= 0;
        aux_revoluciones_por_minuto <= 0;
        estado_hall <= "000";
        contador_sensor_hall <= 0;
    else
        if contador_uno_motor_dc = 100 then
            case estado_hall is
                when "000" => -- Estado_hall inicial 
                    contador_automata_motor_dc <= 0;
                    if  hall = "00" then
                        estado_hall <= "001";
                    end if; 
                when "001" =>
                    contador_automata_motor_dc <= contador_automata_motor_dc + 1;
                    revoluciones_por_minuto <= revoluciones_por_minuto;
                    if contador_automata_motor_dc >= 60000 then
                        revoluciones_por_minuto <= 0;
                        estado_hall <= "000";
                    elsif hall = "01" then 
                        estado_hall <= "010";
                    elsif hall = "10" then 
                        estado_hall <= "011";
                    end if;       
                 when "010" =>
                   contador_automata_motor_dc <= contador_automata_motor_dc + 1;     
                    if contador_automata_motor_dc >= 60000 then
                        revoluciones_por_minuto <= 0;
                        estado_hall <= "000";
                    elsif hall = "00" then
                        estado_hall <= "100";
                    end if;       
                 when "011" =>
                    contador_automata_motor_dc <= contador_automata_motor_dc + 1;  
                    if contador_automata_motor_dc >= 60000 then
                        revoluciones_por_minuto <= 0;
                        estado_hall <= "000";
                    elsif hall = "00" then
                        estado_hall <= "100";
                    end if; 
                when "100" =>
                    aux_revoluciones_por_minuto <= (60000000 / (contador_automata_motor_dc * 8 * 120));
                    -- En este caso, la velocidad del motor se actualiza después de 100 mediciones, lo que puede ayudar a reducir la cantidad de actualizaciones innecesarias y filtrar posibles variaciones o ruido en la señal
                    if contador_sensor_hall = 100 and (aux_revoluciones_por_minuto < revoluciones_por_minuto - 2 or aux_revoluciones_por_minuto > revoluciones_por_minuto + 2) then -- Solo actualizamos el rpm si el nuevo valor difiere en valor absoluto del anterior en má de dos unidades, para evitar cambios absurdos
                        revoluciones_por_minuto <= aux_revoluciones_por_minuto;
                        contador_sensor_hall <= 0;
                    else
                        contador_sensor_hall <= contador_sensor_hall + 1;
                    end if;
                    estado_hall <= "000";   
                when others =>
                    estado_hall <= "000";
                 end case;
            contador_uno_motor_dc <= 0;
        else
            contador_uno_motor_dc <= contador_uno_motor_dc + 1;
        end if;
    end if;
end if;
if parada = '0' then -- Sino esta parado, sacamos la velocidad por pantalla
valor_Velocidad <= std_logic_vector(to_unsigned(revoluciones_por_minuto, 14));
end if;
end process;


--- Process para distancia
process(clk, inicio)
begin
if inicio='1' then
    contador_base_Distancia<=0;
elsif rising_edge(clk) then
    if contador_base_Distancia=100 then
        contador_base_Distancia<=0;
        if contador_micros=60000 then
            contador_micros<=0;
        else
            contador_micros<=contador_micros+1;
        end if;                   
    else
        contador_base_Distancia<=contador_base_Distancia+1;
    end if;
end if;
end process;

-- Generador del trigger, creamos un pulso de disparo para el sensor HC-SR04
process(contador_micros)
begin
if contador_micros<10 then
    TRIGGER<='1';
else
    TRIGGER<='0';
end if;
end process;

-- Contador de echo 
process(clk, inicio)
begin
if inicio='1' then
    contador_echo<=0;
elsif rising_edge(clk) then
    --  Para garantizar que el contador de eco comience desde cero al inicio de cada ciclo de 60 ms. 
    if contador_micros=0 then
        contador_echo<=0;
    else
        -- El código garantiza que el contador de eco sólo se incremente en el momento específico del ciclo cuando el sensor está recibiendo el eco (ciclo de 60 ms)
        if contador_base_Distancia=0 then
            if ECHO='1' then -- Si esta reciviendo echo
                contador_echo<=contador_echo+1;
            end if;
        end if;
    end if;
end if;
end process;                                

-- Registro y calculo de la distancia por cada ciclo
process(inicio, clk)
begin
if inicio='1' then
    distancia_entero<=0;
elsif rising_edge(clk) then
    if contador_micros=60000 then -- Hacemos una medición cada 60ms
        distancia_entero<=contador_echo/58; -- Según la fórmula proporcionada en la descripción del sensor
    end if;
end if;
end process; 

distancia_actual <= "0000" & std_logic_vector(to_unsigned(distancia_entero, 10)); -- Sacarlo por pantalla




--- Process para Reloj
process(inicio, clk)
begin
if inicio='1' then
	contador_base<=0;
elsif rising_edge(clk) then
if contador_base=100000000 then
	contador_base<=0;
else
	contador_base<=contador_base+1;
end if;
end if;
end process;

-- Descripcion del contador BCD
process(inicio, clk) -- Contador BCD (De 0 a 9), sumando uno cada segundo
begin
if inicio='1' then
contador_reloj_seg_unidades<="0000";
elsif rising_edge(clk) then
    if contador_base=100000000 then
        if contador_reloj_seg_unidades="1001" then
            contador_reloj_seg_unidades<="0000";
        else
            contador_reloj_seg_unidades<=contador_reloj_seg_unidades+1;
        end if;
    end if;      
end if;
end process;

process(inicio, clk) -- Contador de decenas de segundos, llega hasta 5
begin
if inicio='1' then
	contador_reloj_seg_decenas<="0000";
elsif rising_edge(clk) then
	if contador_base=100000000 and contador_reloj_seg_unidades=9 then
		if contador_reloj_seg_decenas=5 then
			contador_reloj_seg_decenas<="0000";
		else
			contador_reloj_seg_decenas<=contador_reloj_seg_decenas+1;
		end if;
	end if;
end if;
end process;

process(inicio, clk) -- Contador de unidades de minuto
begin
if inicio='1' then
contador_reloj_min_unidades<="0000";
elsif rising_edge(clk) then
    if contador_base=100000000 and contador_reloj_seg_unidades=9 and contador_reloj_seg_decenas=5 then
        if contador_reloj_min_unidades="1001" then
            contador_reloj_min_unidades<="0000";
        else
            contador_reloj_min_unidades<=contador_reloj_min_unidades+1;
        end if;
    end if;      
end if;
end process;

process(inicio, clk) -- Contador de decenas de minuto
begin
if inicio='1' then
	contador_reloj_min_decenas<="0000";
elsif rising_edge(clk) then
	if contador_base=100000000 and contador_reloj_seg_unidades=9 and contador_reloj_seg_decenas=5 and contador_reloj_min_unidades=9 then
		if contador_reloj_min_decenas=5 then
			contador_reloj_min_decenas<="0000";
		else
			contador_reloj_min_decenas<=contador_reloj_min_decenas+1;
		end if;
	end if;
end if;
end process;

process(clk, inicio) 
begin
if inicio='1' then
	enable_seg_aux<="1110";
elsif rising_edge(clk) then
	if contador_enable_aux= 100000 then
		enable_seg_aux<=enable_seg_aux(2 downto 0)&enable_seg_aux(3); -- Rotamos el enable_seg_aux
end if;
end if;
end process;

process(inicio, clk) -- Contador del enable seg
begin
if inicio='1' then
	contador_enable_aux<=0;
elsif rising_edge(clk) then
	if contador_enable_aux= 100000 then
		contador_enable_aux<=0;
	else
		contador_enable_aux<=contador_enable_aux+1;
	end if;
end if;
end process;

salida_reloj <= contador_reloj_min_decenas & contador_reloj_min_unidades & contador_reloj_seg_decenas & contador_reloj_seg_unidades;

-- Multiplexado datos
process(inicio, clk, modo_menu)
begin
case(modo_menu) is
   when "001" => multiplexado_Sensores <= distancia_actual; 
   when "010" => multiplexado_Sensores <= valor_Velocidad; 
   when "011" => multiplexado_Sensores <= std_logic_vector(to_unsigned(distancia_objetivo, 14));
   when "100" => multiplexado_Sensores <= std_logic_vector(to_unsigned(velocidad_objetivo, 14)); 
   when others => multiplexado_Sensores <= "00000000000000";
end case;
end process;


--- Binario a BCD

process(clk, inicio) -- Reloj
begin
if inicio='1' then
    contador_reloj_binario_bcd<=0;
elsif rising_edge(clk) then
    if contador_reloj_binario_bcd=100000000 then
        contador_reloj_binario_bcd<=0;
    else
        contador_reloj_binario_bcd<=contador_reloj_binario_bcd+1;
    end if;
end if;
end process;                        

process(clk, inicio)
begin
if inicio='1' then
    variable_apoyo<="0000000000000000"&multiplexado_Sensores;
    estado_binario_bcd<="00";
    contador_bits<= 0;
    un<="0011";
    dec<="0011";
    cen<="0011";
    mil<="0011";
    final<='0';
elsif rising_edge(clk) then
    case estado_binario_bcd is
    when "00" =>    contador_bits<=0;
                    final<='0';
                    variable_apoyo<="0000000000000000"&multiplexado_Sensores;
                    if sw_blq_stepper='1' then
                        estado_binario_bcd<="01";
                    end if;        
    when "01" =>    contador_bits<=contador_bits+1;
                    final<='0';
                    variable_apoyo<=variable_apoyo(28 downto 0)&'0';
                    if contador_bits<13 then
                        estado_binario_bcd<="10";
                    else
                        estado_binario_bcd<="11";
                    end if;
    when "10" =>    contador_bits<=contador_bits;
                    final<='0';
                        if variable_apoyo(21 downto 18)>4 then
                            variable_apoyo(21 downto 18)<=variable_apoyo(21 downto 18)+"0011";
                        end if;
                        if variable_apoyo(17 downto 14)>4 then
                            variable_apoyo(17 downto 14)<=variable_apoyo(17 downto 14)+"0011";
                        end if;
                        if variable_apoyo(25 downto 22)>4 then
                            variable_apoyo(25 downto 22)<=variable_apoyo(25 downto 22)+"0011";
                        end if;
                        if variable_apoyo(29 downto 26)>4 then
                            variable_apoyo(29 downto 26)<=variable_apoyo(29 downto 26)+"0011";
                        end if;
                    estado_binario_bcd<="01";
    when "11" =>    contador_bits<=0;
                    final<='1';
                        dec<=variable_apoyo(21 downto 18);
                        un<=variable_apoyo(17 downto 14);
                        cen<=variable_apoyo(25 downto 22);
                        mil<=variable_apoyo(29 downto 26);
                    estado_binario_bcd<="00";
    when others =>  contador_bits<=0;
                    final<='0';
                    estado_binario_bcd<="00";
    end case;
end if;
end process;

valor_BCD <= mil & cen & dec & un;

---Multiplexado del reloj
process(modo_menu)
begin
if(modo_menu = "000")then
    salida_7_seg <= salida_reloj; -- Si el modo es 0, mostramos el reloj en el siete segmentnos
else
    salida_7_seg <= valor_BCD; -- Sino mostramos valor_BCD
end if;
end process;


---Process para 7seg

---Mux 7seg
process(enable_seg_aux)
begin
case enable_seg_aux is
when "1110" => salida_pantalla<=salida_7_seg(3 downto 0);
when "1101" => salida_pantalla<=salida_7_seg(7 downto 4);
when "1011" => salida_pantalla<=salida_7_seg(11 downto 8);
when "0111" => salida_pantalla<=salida_7_seg(15 downto 12);
when others => salida_pantalla<="0000";
end case;
end process;

enable_seg <= enable_seg_aux;

--Bcd to 7seg
process(salida_pantalla)
begin
case salida_pantalla is
when "0000" => segmentos<="0000001";
when "0001" => segmentos<="1001111";
when "0010" => segmentos<="0010010";
when "0011" => segmentos<="0000110";
when "0100" => segmentos<="1001100";
when "0101" => segmentos<="0100100";
when "0110" => segmentos<="1100000";
when "0111" => segmentos<="0001111";
when "1000" => segmentos<="0000000";
when "1001" => segmentos<="0001100";
when others => segmentos<="0110000";
end case;
end process;

end Behavioral;
