library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use IEEE.std_logic_unsigned.all;



entity main is
Port (
   clk: in std_logic;
   inicio: in std_logic;
   enableSw: in std_logic;
   enableSwS: in std_logic;
   enable_seg: out std_logic_vector(3 downto 0);
   segmentos: out std_logic_vector(6 downto 0);
   modo: in std_logic_vector(1 downto 0);
   alarma: out std_logic;
   paro: in std_logic;
   
   btnU: in std_logic;
   btnD: in std_logic;
   btnL: in std_logic;
   btnR: in std_logic;   
   
   cale: out std_logic;
   
   dcEnc: in std_logic_vector (1 downto 0);
   pwmEnt: in std_logic_vector(3 downto 0);
   pwmPos: out std_logic;
   pwmNeg: out std_logic;  
    
   enableSteper: out std_logic;
   fc2Tarj: in std_logic;
   fc1Calle: in std_logic;
   led: out std_logic_vector(15 downto 0);
   sw: in std_logic_vector(3 downto 0);
   dir: out std_logic;
   step: out std_logic;
   echo: in std_logic;
   trigger: out std_logic; 
    
   crc_en: OUT STD_LOGIC;
   ds_data_bus: INOUT	STD_LOGIC
   );
end main;

architecture Behavioral of main is

------ Signals -------

-- Signals para el control
signal rDist: integer range 0 to 1023;
signal rTemp: integer range 0 to 1023;
signal rHall: integer range 0 to 1023;
signal riesgo: std_logic;

-- Signals para filtrado del botón
signal estadoU: std_logic_vector (1 downto 0);
signal estadoD: std_logic_vector (1 downto 0);
signal estadoL: std_logic_vector (1 downto 0);
signal estadoR: std_logic_vector (1 downto 0);

-- Signals para pwmDC
signal estadoPWM: std_logic_vector(2 downto 0);
signal contPWM: integer range 0 to 500000;
signal tope: integer range 0 to 500000;
signal pwm: std_logic;
signal sentido: std_logic;

-- PID
signal error: integer range -50000 to 50000;

-- Signals para hallDC
signal cont_baseDC: integer range 0 to 100000000;
signal contador_ticks: integer range 0 to 100000; -- Contador de microsegundos ticks de reloj
signal contador_ticks_2: integer range 0 to 100000; -- Contador de microsegundos ticks de reloj
signal rpm: integer range 0 to 9999;
signal aux_rpm: integer range 0 to 9999;
signal cont_microsDC: integer range 0 to 100000;
signal estado_hall: std_logic_vector (2 downto 0);
signal sentidoGiro: std_logic;

-- Conexión del sensor hall
signal hall: std_logic_vector (1 downto 0);
signal cont_hall: integer range 0 to 1000;

-- Signals para distancia
signal cont_micros: integer range 0 to 60000;
signal cont_baseDist: integer range 0 to 100;
signal cont_echo: integer range 0 to 60000;
signal distancia_entero: integer range 0 to 1023;

-- Signals para stepper
signal dirAux: std_logic;
signal reloj_paso_paso: integer range 0 to 10000000; -- Generar la frecuencia de 50 Hz
signal paso_paso_aux: std_logic; -- Para generar la salida
signal tope_frecuencia_paso_paso: integer range 0 to 1000000000; -- Para controlar la velocidad
signal frecuencia_paso_paso_entero: integer range 0 to 10000;

-- Signal para PT100
TYPE STATE_TYPE is (WAIT_800ms, RESET, PRESENCE, SEND, WRITE_BYTE, WRITE_LOW, WRITE_HIGH, GET_DATA, READ_BIT);
SIGNAL state: STATE_TYPE;
SIGNAL data	: STD_LOGIC_VECTOR(71 downto 0);
SIGNAL S_reset	: STD_LOGIC;
SIGNAL i			: INTEGER RANGE 0 TO 799999;
SIGNAL write_command : STD_LOGIC_VECTOR(7 downto 0);
SIGNAL presence_signal		: STD_LOGIC;
SIGNAL WRITE_BYTE_CNT	: INTEGER RANGE 0 TO 8	:= 0;	-- Citac pro odesilany bajt
SIGNAL write_low_flag	: INTEGER RANGE 0 TO 2	:= 0;	-- Priznak pozice ve stavu WRITE_LOW
SIGNAL write_high_flag	: INTEGER RANGE 0 TO 2	:= 0;	--	Priznak pozice ve stavu WRITE_HIGH
SIGNAL read_bit_flag		: INTEGER RANGE 0 TO 3	:= 0;	-- Priznak pozice ve stavu READ_BIT
SIGNAL GET_DATA_CNT		: INTEGER RANGE 0 TO 72	:= 0;	-- Citac pro pocet prectenych bitu
SIGNAL CONT_AUX: integer range 0 to 100; 				
signal dataOut			: STD_LOGIC_VECTOR(71 downto 0);

-- Signals para bin to bcd
signal vector_aux: std_logic_vector (29 downto 0);
signal estado: std_logic_vector (1 downto 0);
signal cont_bits: integer range 0 to 13;
signal fin: std_logic;
signal sal_mux: std_logic_vector (3 downto 0);
signal unidades: std_logic_vector (3 downto 0);
signal decenas: std_logic_vector (3 downto 0);
signal centenas: std_logic_vector (3 downto 0);
signal millares: std_logic_vector (3 downto 0);
signal enable_aux: std_logic_vector (3 downto 0);
signal cont_base_enable: integer range 0 to 100000;
signal cont: integer range 0 to 100000000;

-- Signals para intercomunicar Cajas
signal relojData: std_logic_vector(15 downto 0);
signal TempData: std_logic_vector(8 downto 0);
signal distData: std_logic_vector(13 downto 0);
signal to7seg: std_logic_vector(15 downto 0);
signal muxSensores: std_logic_vector(13 downto 0);
signal bcdData: std_logic_vector(15 downto 0);
signal selLSB: std_logic_vector(1 downto 0);
signal hallData: std_logic_vector(13 downto 0);
signal sel: std_logic_vector(2 downto 0);
signal rDistData: std_logic_vector(14 downto 0);
signal der: std_logic;
signal izq: std_logic;
signal menos: std_logic;
signal mas: std_logic;
signal controlSt: std_logic_vector(1 downto 0);
signal controlDC: std_logic;

-- Signal para 7seg
signal salida_ver: std_logic_vector (3 downto 0); 

-- Signals para Reloj
signal cont_seg_uni: std_logic_vector (3 downto 0);
signal cont_seg_dec: std_logic_vector (3 downto 0);
signal cont_min_uni: std_logic_vector (3 downto 0);
signal cont_min_dec: std_logic_vector (3 downto 0);
signal cont_riesgo: integer range 0 to 9999;
signal cont_base: integer range 0 to 100000000;
signal cont_enable_aux: integer range 0 to 100000;
signal enable_seg_aux: std_logic_vector (3 downto 0);


------ Procesos -------

begin

led <= sel & "0110111101111";
selLSB <= sel(1 downto 0);
hall <= dcEnc;

-- Filtrado de botón U
process(inicio, clk)
begin
if inicio='1' then
    estadoU<="00";
elsif rising_edge(clk) then
    case estadoU is
    when "00" =>
        if btnU='0' then
            estadoU<="00";
        else
            estadoU<="01";
        end if;           
    when "01" =>
        if btnU='0' then
            estadoU<="10";
        else
            estadoU<="01";
        end if;
    when "10" =>
        estadoU<="00";
    when others =>
        estadoU<="00";
    end case;
end if;
end process; 

process(estadoU)
begin
case estadoU is
when "00" => mas<='0';
when "01" => mas<='0';
when "10" => mas<='1';
when others => mas<='0';
end case;
end process;

---- Filtrado de botón D
process(inicio, clk)
begin
if inicio='1' then
    estadoD<="00";
elsif rising_edge(clk) then
    case estadoD is
    when "00" =>
        if btnD='0' then
            estadoD<="00";
        else
            estadoD<="01";
        end if;           
    when "01" =>
        if btnD='0' then
            estadoD<="10";
        else
            estadoD<="01";
        end if;
    when "10" =>
        estadoD<="00";
    when others =>
        estadoD<="00";
    end case;
end if;
end process; 

process(estadoD)
begin
case estadoD is
when "00" => menos<='0';
when "01" => menos<='0';
when "10" => menos<='1';
when others => menos<='0';
end case;
end process;

---- Filtrado de botón L
process(inicio, clk)
begin
if inicio='1' then
    estadoL<="00";
elsif rising_edge(clk) then
    case estadoL is
    when "00" =>
        if btnL='0' then
            estadoL<="00";
        else
            estadoL<="01";
        end if;           
    when "01" =>
        if btnL='0' then
            estadoL<="10";
        else
            estadoL<="01";
        end if;
    when "10" =>
        estadoL<="00";
    when others =>
        estadoL<="00";
    end case;
end if;
end process; 

process(estadoL)
begin
case estadoL is
when "00" => izq<='0';
when "01" => izq<='0';
when "10" => izq<='1';
when others => izq<='0';
end case;
end process;

---- Filtrado de botón R
process(inicio, clk)
begin
if inicio='1' then
    estadoR<="00";
elsif rising_edge(clk) then
    case estadoR is
    when "00" =>
        if btnR='0' then
            estadoR<="00";
        else
            estadoR<="01";
        end if;           
    when "01" =>
        if btnR='0' then
            estadoR<="10";
        else
            estadoR<="01";
        end if;
    when "10" =>
        estadoR<="00";
    when others =>
        estadoR<="00";
    end case;
end if;
end process; 

process(estadoR)
begin
case estadoR is
when "00" => der<='0';
when "01" => der<='0';
when "10" => der<='1';
when others => der<='0';
end case;
end process;


----------- CONTROL -----------

-- Generacion de lineas de control
process(inicio, clk, modo)
begin
if inicio = '1'then
    controlSt <= "00";
elsif rising_edge(clk) then
case modo is
    when "00"=> -- Modo ida y vuelta continuo
        cale <= '0';
        controlSt <= "11"; 
        controlDC <= '0';
    when "01"=> -- Ida y vuelta hasta temperatura de riesgo
        controlDC <= '0';
        if riesgo = '1' then
        controlSt <= "00";
        cale <= '0';
        else
        controlSt <= "11";
        cale <= '1';
        end if;
    when "10" =>    -- Poner stepper a distancia especificada
        controlDC <= '0';
        cale <= '0';
        if(rDist > distData)then
            controlSt <= "01";
        elsif rDist < distData then
            controlSt <= "10";
        else controlSt <= "00";
        end if;
    when "11" =>
        cale <= '0';
        controlSt <= "00"; 
        controlDC <= '1';
    when others => controlSt <= "00";
end case;
end if;
end process;

-- Insercion de datos por botones
process(clk, inicio, sel)
begin
if inicio = '1' then
    riesgo <= '0';
elsif rising_edge(clk) then
    case sel is
    when "101" =>
        if mas = '1' then
            rTemp <= rTemp +1;
        elsif menos = '1'then
            rTemp <= rTemp -1;
        end if;
    when "110" => 
        if mas = '1' then
            rDist <= rDist +1;
        elsif menos = '1'then
            rDist <= rDist -1;
        end if;
    when "111" => 
        if paro = '0'then
        if mas = '1' then
            rHall <= rHall +1;
        elsif menos = '1'then
            rHall <= rHall -1;
        end if;
        end if;
    when others =>
    end case;
end if;
if(TempData > rTemp)then
    riesgo <= '1';
else
    riesgo <= '0';
end if;
end process;

-- Generación de sel
process(clk, inicio)
begin
if inicio = '1' then
    sel <= "000";
elsif rising_edge(clk) then
    if(der = '1')then
        sel<= sel +1;
    elsif(izq = '1')then
        sel <= sel -1;
    end if;
end if;
end process;

--- Process para pwmDC
process(controlDC, pwmEnt, clk, inicio)
begin
if controlDC = '0'then
    case pwmEnt is
    when "0000" => tope <= 0;
    when "0001" => tope <= 50000;
    when "0010" => tope <= 100000;
    when "0011" => tope <= 150000;
    when "0100" => tope <= 200000;
    when "0101" => tope <= 250000;
    when "0110" => tope <= 300000;
    when "0111" => tope <= 350000;
    when "1000" => tope <= 400000;
    when "1001" => tope <= 450000;
    when "1010" => tope <= 500000;
    when others => tope <= 0;
    end case;
else
    --PID
    if inicio = '1'then 
        error <= 0;
    elsif rising_edge(clk)then
        error <= (rHall - rpm) *10;
        if error > 50000 then
            tope <= 50000;
        
        end if;
    end if;
end if;

end process;


process(sentido)
begin
if(sentido = '0')then
    pwmPos <= pwm;
    pwmNeg <= '0';
else
    pwmPos <= '0';
    pwmNeg <= pwm;
end if;
end process;



process(inicio, clk)
begin
if inicio = '1' then
    contPWM <= 0;
    estadoPWM <= "000";
elsif rising_edge(clk)then
    case estadoPWM is
    when "000" => 
        contPWM <= 0;
        if(tope = 0) then
            estadoPWM <= "001";
        else
            estadoPWM <= "010";
        end if;
    when "001" =>                                                                                                                                                                                            
        contPWM <= 1;
        estadoPWM <= "011";
    when "010" => 
        contPWM <= 1;
        estadoPWM <= "100";   
     when "011" =>
        contPWM <= contPWM +1;
        if (contPWM = 500000 and tope = 0)then
            estadoPWM <= "001";
        elsif (contPWM = 500000)then
            estadoPWM <= "010";
        end if;
     when "100" =>
        contPWM <= contPWM +1;
        if (contPWM = tope and tope = 500000)then
            estadoPWM <= "010";
        elsif (contPWM = tope)then
            estadoPWM <= "011";
        end if;
     when others => 
        contPWM <= 0;
        estadoPWM <= "000";
    end case;
end if;
end process;

process(estadoPWM)
begin
case estadoPWM is
when "000" => pwm <= '0';
when "001" => pwm <= '0';
when "010" => pwm <= '1';
when "011" => pwm <= '0';
when "100" => pwm <= '1';
when others => pwm <= '0';
end case;
end process;

--- Process para hallDC
--- Cuenta las revoluciones del motor cada segundo y luego las pasa a la variable rev_per_seg
process(clk, inicio)
begin
if rising_edge(clk) then
    if inicio='1' then
        contador_ticks <= 0;
        cont_microsDC <= 0;
        rpm <= 0;
        aux_rpm <= 0;
        estado_hall <= "000";
        cont_hall <= 0;
    else
        if contador_ticks = 100 then
            case estado_hall is
                when "000" => -- Estado_hall inicial
                   
                    cont_microsDC <= 0;
                   
                    if  hall = "00" then
                        estado_hall <= "001";
                    end if;
                   
                when "001" =>
                    cont_microsDC <= cont_microsDC + 1;
                    rpm <= rpm;
                   
                    if cont_microsDC >= 60000 then
                        rpm <= 0;
                        estado_hall <= "000";
                    elsif hall = "01" then
                        sentidoGiro <= '0';
                        estado_hall <= "010";
                    elsif hall = "10" then
                        sentidoGiro <= '1';
                        estado_hall <= "011";
                    end if;
                   
                 when "010" =>
                   cont_microsDC <= cont_microsDC + 1;
                   
                    if cont_microsDC >= 60000 then
                        rpm <= 0;
                        estado_hall <= "000";
                    elsif hall = "00" then
                        estado_hall <= "100";
                    end if;
                   
                 when "011" =>
                    cont_microsDC <= cont_microsDC + 1;
                   
                    if cont_microsDC >= 60000 then
                        rpm <= 0;
                        estado_hall <= "000";
                    elsif hall = "00" then
                        estado_hall <= "100";
                    end if;
               
                when "100" =>
                    aux_rpm <= (60000000 / (cont_microsDC * 8 * 120));
                    if cont_hall = 100 and (aux_rpm < rpm - 2 or aux_rpm > rpm + 2) then
                        rpm <= aux_rpm;
                        cont_hall <= 0;
                    else
                        cont_hall <= cont_hall + 1;
                    end if;
                    estado_hall <= "000";
                   
                when others =>
                    estado_hall <= "000";
                end case;

            contador_ticks <= 0;
        else
            contador_ticks <= contador_ticks + 1;
        end if;
    end if;
end if;
if paro = '0' then
hallData <= std_logic_vector(to_unsigned(rpm, 14));
end if;
end process;




--- Process para distancia
-- Contador de micros y generacion del ciclo de 60 ms
process(clk, inicio)
begin
if inicio='1' then
    cont_baseDist<=0;
elsif rising_edge(clk) then
    if cont_baseDist=100 then
        cont_baseDist<=0;
        if cont_micros=60000 then
            cont_micros<=0;
        else
            cont_micros<=cont_micros+1;
        end if;                   
    else
        cont_baseDist<=cont_baseDist+1;
    end if;
end if;
end process;

-- Generador del trigger
process(cont_micros)
begin
if cont_micros<10 then
    trigger<='1';
else
    trigger<='0';
end if;
end process;

-- Contador de echo 
process(clk, inicio)
begin
if inicio='1' then
    cont_echo<=0;
elsif rising_edge(clk) then
    if cont_micros=0 then
        cont_echo<=0;
    else
        if cont_baseDist=0 then
            if echo='1' then
                cont_echo<=cont_echo+1;
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
    if cont_micros=60000 then
        distancia_entero<=cont_echo/58;
    end if;
end if;
end process; 
distData <= "0000" & std_logic_vector(to_unsigned(distancia_entero, 10));


--- Process para stepper
frecuencia_paso_paso_entero<=to_integer(unsigned(sw & "00000"));
tope_frecuencia_paso_paso<=(100000000/frecuencia_paso_paso_entero)/2;

--- Control de Stepper
process(clk, inicio, controlST)
begin 
if inicio = '1' then
    dirAux <= '0';
    enableSteper <= enableSwS;
elsif rising_edge(clk) then
    case controlSt is
    when "00" =>    -- Parado
        enableSteper <= '0';
    when "01" =>    -- En direccion calle
     dirAux <= '1';
     if(fc1Calle = '1')then
        enableSteper <= '0';
        else
        enableSteper <= enableSwS;
        end if;
    when "10" =>    -- En direccion placa
        dirAux <= '0';
        if(fc2Tarj = '1')then
        enableSteper <= '0';
        else
        enableSteper <= enableSwS;
        end if;
    when "11" =>    -- En las 2 direcciones
        enableSteper <= enableSwS;     
    if(fc2Tarj = '0' and fc1Calle = '0')then
        dirAux <= dirAux;
    else
        if(fc2Tarj = '1')then
            dirAux <= '1';
        else
            dirAux <= '0';
        end if;
    end if;
    when others =>
       dirAux <= '0';
    enableSteper <= enableSwS; 
    end case;
end if;
end process;

process(clk)
begin
if inicio='1' then
    reloj_paso_paso<=0;
elsif rising_edge(clk) then
   if reloj_paso_paso=tope_frecuencia_paso_paso then --0 then
        reloj_paso_paso<=0;
   else
        reloj_paso_paso<=reloj_paso_paso+1;
   end if;
end if;
end process;

process(clk)
begin
if clk='1' and clk'event then
    if reloj_paso_paso=0 then -- con el A
        paso_paso_aux<=not(paso_paso_aux);
    end if;
end if;
end process;
dir<=dirAux;

process(clk, enableSw)
begin
if(rising_edge(clk))then
    if(enableSw = '1')then
        step<=paso_paso_aux;
    else
        step <= '0';
    end if;
end if;
end process;

--- Process para PT100
process(clk)
CONSTANT PRESENCE_ERROR_DATA: STD_LOGIC_VECTOR(71 downto 0):= "111111111111111111111111111111111111111111111111111111111111111111111111";

	VARIABLE bit_cnt: INTEGER RANGE 0 TO 71;	
	VARIABLE flag: INTEGER RANGE 0 TO 5;		

	begin
		if rising_edge(clk) and cont_aux=0 then
			case	state is
				when RESET =>																
					S_reset <= '0';														
					if (i = 0) then 
						ds_data_bus <= '0';												
					elsif (i = 485) then 
						ds_data_bus <= 'Z'; 											
					elsif (i = 550) then
						presence_signal <= ds_data_bus;								
					elsif (i = 1000) then 
						state <= PRESENCE;										
					end if;
			
				when PRESENCE =>														
					-- detekce senzoru na sbernici
					if (presence_signal = '0' and ds_data_bus = '1') then		
						S_reset <= '1';													
						state	  <= SEND;													
					else																		
						S_reset	<= '1';													
						dataOut 	<= PRESENCE_ERROR_DATA;								
						crc_en	<= '1';												
						state		<= WAIT_800ms;											-
					end if;

				when SEND =>															
					if (flag = 0) then													
						flag := 1;
						write_command <="11001100"; 									
						state 		  <= WRITE_BYTE;								
					elsif (flag = 1) then												
						flag := 2;
						write_command <="01000100"; 									
						state 		  <= WRITE_BYTE;									
					elsif (flag = 2) then												
						flag := 3;	
						state <= WAIT_800ms; 											
					elsif (flag = 3) then												
						flag := 4;
						write_command <="11001100"; 								
						state			  <= WRITE_BYTE;									
					elsif (flag = 4) then												
						flag := 5;
						write_command <="10111110"; 									
						state			  <= WRITE_BYTE;								
					elsif (flag = 5) then											
						flag := 0;														
						state <= GET_DATA;											
					end if;

				when  WAIT_800ms =>													
					CRC_en <= '0';														
					S_reset <= '0';														
					if (i = 799) then													
						S_reset <='1';														
						state	  <= RESET;												
					end if;

				when GET_DATA =>															
					case GET_DATA_CNT is												
						when 0 to 71=>													
							ds_data_bus  <= '0';									
							GET_DATA_CNT <= GET_DATA_CNT + 1;						
							state 		 <= READ_BIT;								
						when 72=>												
							bit_cnt := 0;													
							GET_DATA_CNT <=0;										
							dataOut 	 <= data(71 downto 0);						
							CRC_en 		 <= '1';											
							state 		 <= WAIT_800ms;						
						when others =>	 													
							read_bit_flag <= 0;										
							GET_DATA_CNT  <= 0; 										
					end case;

				when READ_BIT =>															
					case read_bit_flag is											
						when 0=>																
							read_bit_flag <= 1;
						when 1=>																
							ds_data_bus <= 'Z';--aqui											
							S_reset 		<= '0';											
							if (i = 13) then												
								S_reset		 <= '1';										
								read_bit_flag <= 2;
							end if; 
						when 2=>																
							data(bit_cnt)	<= ds_data_bus;							
							bit_cnt := bit_cnt + 1;										
						when 3=>															
							S_reset <= '0';												
							if (i = 63) then												
								S_reset<='1';												
								read_bit_flag <= 0;										
								state 		  <= GET_DATA;							
							end if;
						when others => 												
							read_bit_flag <= 0;									
							bit_cnt		  := 0;											
							GET_DATA_CNT  <= 0;								
							state			  <= RESET;										
					end case;

				when WRITE_BYTE =>											
					case WRITE_BYTE_CNT is												
						when 0 to 7=>														
							if (write_command(WRITE_BYTE_CNT) = '0') then		
								state <= WRITE_LOW; 									
							else																
								state <= WRITE_HIGH;									
							end if;
							WRITE_BYTE_CNT <= WRITE_BYTE_CNT + 1;					
						when 8=>													
							WRITE_BYTE_CNT <= 0;											
							state				<= SEND;										
						when others=>														
							WRITE_BYTE_CNT  <= 0;										
							write_low_flag  <= 0;										
							write_high_flag <= 0;										
							state 		   <= RESET;									
						end case;

				when WRITE_LOW =>															
					case write_low_flag is												
						when 0=>																
							ds_data_bus <= '0';										
							S_reset 		<= '0';											
							if (i = 59) then												
								S_reset		   <='1';										
								write_low_flag <= 1;
							end if;
						when 1=>																
							ds_data_bus <= 'Z';										
							S_reset 		<= '0';											
							if (i = 3) then												
								S_reset 		   <= '1';									
								write_low_flag <= 2;
							end if;
						when 2=>																
							write_low_flag <= 0;											
							state 		   <= WRITE_BYTE;								
						when others=>														
							WRITE_BYTE_CNT  <= 0;										
							write_low_flag  <= 0;										
							state 		    <= RESET;									
					end case;

				when WRITE_HIGH =>														
					case write_high_flag is												
						when 0=>																
							ds_data_bus <= '0';											
							S_reset <= '0';												
							if (i = 9) then												
								S_reset 			<= '1';									
								write_high_flag <= 1;
							end if;
						when 1=>																
							ds_data_bus <= 'Z';											
							S_reset 		<= '0';											
							if (i = 53) then											
								S_reset			<= '1';									
								write_high_flag <= 2;
							end if;
						when 2=>																
							write_high_flag <= 0;										
							state 			 <= WRITE_BYTE;							
						when others =>														
							WRITE_BYTE_CNT  <= 0;										
							write_high_flag <= 0;										
							state 		    <= RESET;									
					end case;

				when others =>																
					state <= RESET;														
					
			end case;
		end if;
	end process;

	process(clk, S_reset)

	begin
		if (rising_edge(clk)) then
		  if cont_aux=100 then 
			 cont_aux<=0;
		  	 if (S_reset = '1')then		
				    i <= 0;						
			 else
				    i <= i + 1;				
			 end if;
		   else
		   cont_aux<=cont_aux+1;
		   end if; 
		  end if;

	end process;



TempData <= dataOut(12 downto 4);

--- Process para Reloj
process(inicio, clk, riesgo)
begin
if inicio = '1' or not(modo = "01") then
    cont_riesgo <= 0;
    alarma <= '0';
elsif rising_edge(clk) then
    if(riesgo = '1' and cont_base = 100000000)then
        alarma <= '1';
        if(cont_riesgo = 9999) then
            cont_riesgo <= 0;
        else
            cont_riesgo <= cont_riesgo +1;
        end if;
    else
        cont_riesgo <= 0;
    end if;
end if;
end process;

process(inicio, clk)
begin
if inicio='1' then
	cont_base<=0;
elsif rising_edge(clk) then
if cont_base=100000000 then
	cont_base<=0;
else
	cont_base<=cont_base+1;
end if;
end if;
end process;

-- Descripcion del contador BCD
process(inicio, clk)
begin
if inicio='1' then
cont_seg_uni<="0000";
elsif rising_edge(clk) then
    if cont_base=100000000 then
        if cont_seg_uni="1001" then
            cont_seg_uni<="0000";
        else
            cont_seg_uni<=cont_seg_uni+1;
        end if;
    end if;      
end if;
end process;

process(inicio, clk)
begin
if inicio='1' then
	cont_seg_dec<="0000";
elsif rising_edge(clk) then
	if cont_base=100000000 and cont_seg_uni=9 then
		if cont_seg_dec=5 then
			cont_seg_dec<="0000";
		else
			cont_seg_dec<=cont_seg_dec+1;
		end if;
	end if;
end if;
end process;

process(inicio, clk)
begin
if inicio='1' then
cont_min_uni<="0000";
elsif rising_edge(clk) then
    if cont_base=100000000 and cont_seg_uni=9 and cont_seg_dec=5 then
        if cont_min_uni="1001" then
            cont_min_uni<="0000";
        else
            cont_min_uni<=cont_min_uni+1;
        end if;
    end if;      
end if;
end process;

process(inicio, clk)
begin
if inicio='1' then
	cont_min_dec<="0000";
elsif rising_edge(clk) then
	if cont_base=100000000 and cont_seg_uni=9 and cont_seg_dec=5 and cont_min_uni=9 then
		if cont_min_dec=5 then
			cont_min_dec<="0000";
		else
			cont_min_dec<=cont_min_dec+1;
		end if;
	end if;
end if;
end process;

process(clk, inicio)
begin
if inicio='1' then
	enable_seg_aux<="1110";
elsif rising_edge(clk) then
	if cont_enable_aux= 100000 then--100000 then
		enable_seg_aux<=enable_seg_aux(2 downto 0)&enable_seg_aux(3);
end if;
end if;
end process;

process(inicio, clk)
begin
if inicio='1' then
	cont_enable_aux<=0;
elsif rising_edge(clk) then
	if cont_enable_aux= 100000 then--100000 then
		cont_enable_aux<=0;
	else
		cont_enable_aux<=cont_enable_aux+1;
	end if;
end if;
end process;

relojData <= cont_min_dec & cont_min_uni & cont_seg_dec & cont_seg_uni;

---Mux datos
process(inicio, clk, sel)
begin
case(sel) is

   when "001" => muxSensores <= "00000" & TempData;
   when "010" => muxSensores <= distData;
   when "011" => muxSensores <= hallData;--hallData;
   
   when "100" => muxSensores <= std_logic_vector(to_unsigned(cont_riesgo, 14));
   when "101" => muxSensores <= std_logic_vector(to_unsigned(rTemp, 14));
   when "110" => muxSensores <= std_logic_vector(to_unsigned(rDist, 14));
   when "111" => muxSensores <= std_logic_vector(to_unsigned(rHall, 14));
   when others => muxSensores <= "00000000000000";
end case;
end process;


---Onv bin2bcd
process(clk, inicio)
begin
if inicio='1' then
    cont<=0;
elsif rising_edge(clk) then
    if cont=100000000 then
        cont<=0;
    else
        cont<=cont+1;
    end if;
end if;
end process;                        

process(clk, inicio)
begin
if inicio='1' then
    vector_aux<="0000000000000000"&muxSensores;
    estado<="00";
    cont_bits<= 0;
    unidades<="0011";
    decenas<="0011";
    centenas<="0011";
    millares<="0011";
    fin<='0';
elsif rising_edge(clk) then
    case estado is
    when "00" =>    cont_bits<=0;
                    fin<='0';
                    vector_aux<="0000000000000000"&muxSensores;
                    if enableSw='1' then
                        estado<="01";
                    end if;        
    when "01" =>    cont_bits<=cont_bits+1;
                    fin<='0';
                    vector_aux<=vector_aux(28 downto 0)&'0';
                    if cont_bits<13 then
                        estado<="10";
                    else
                        estado<="11";
                    end if;
    when "10" =>    cont_bits<=cont_bits;
                    fin<='0';
                    if vector_aux(21 downto 18)>4 then
                        vector_aux(21 downto 18)<=vector_aux(21 downto 18)+"0011";
                    end if;
                    if vector_aux(17 downto 14)>4 then
                        vector_aux(17 downto 14)<=vector_aux(17 downto 14)+"0011";
                    end if;
                    if vector_aux(25 downto 22)>4 then
                        vector_aux(25 downto 22)<=vector_aux(25 downto 22)+"0011";
                    end if;
                    if vector_aux(29 downto 26)>4 then
                        vector_aux(29 downto 26)<=vector_aux(29 downto 26)+"0011";
                    end if;
                    estado<="01";
    when "11" =>    cont_bits<=0;
                    fin<='1';
                    decenas<=vector_aux(21 downto 18);
                    unidades<=vector_aux(17 downto 14);
                    centenas<=vector_aux(25 downto 22);
                    millares<=vector_aux(29 downto 26);
                    estado<="00";
    when others =>  cont_bits<=0;
                    fin<='0';
                    estado<="00";
    end case;
end if;
end process;

bcdData <= millares & centenas & decenas & unidades;

---Mux reloj
process(sel)
begin
if(sel = "000")then
    to7seg <= relojData;
else
    to7seg <= bcdData;
end if;
end process;

---Process para 7seg

---Mux 7seg
process(enable_seg_aux)
begin
case enable_seg_aux is
when "1110" => salida_ver<=to7seg(3 downto 0);
when "1101" => salida_ver<=to7seg(7 downto 4);
when "1011" => salida_ver<=to7seg(11 downto 8);
when "0111" => salida_ver<=to7seg(15 downto 12);
when others => salida_ver<="0000";
end case;
end process;

enable_seg <= enable_seg_aux;

--Bcd2 7seg
process(salida_ver)
begin
case salida_ver is
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