signal contador_ticks: integer range 0 to 100000; --contador de microsegundos ticks de reloj ----
signal rpm: integer range 0 to 9999; ----
signal aux_rpm: integer range 0 to 9999; ---
signal cont_microsDC: integer range 0 to 100000;-------
signal estado_hall: std_logic_vector (2 downto 0); ----
signal sentidoGiro: std_logic;

signal hall: std_logic_vector (1 downto 0);
signal cont_hall: integer range 0 to 1000; ----
signal hallData: std_logic_vector(13 downto 0);

--begin
hall <= dcEnc;
--
---------------------------------------------process para hallDC
-- cuenta las revoluciones del motor cada segundo y luego las pasa a la variable rev_per_seg
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
                when "000" => -- estado_hall inicial
       
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

--menu
when "011" => muxSensores <= hallData;--hallData;