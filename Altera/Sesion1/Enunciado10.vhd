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

signal PA: std_logic;
signal PB: std_logic;
signal PC: std_logic;
signal PD: std_logic;
signal PE: std_logic;

signal PA_aux: std_logic_vector(1 downto 0); -- Usamos una variable auxiliar intermedia, ya que no podemos covertir std_logic a integer, tiene que ser std_logic_vector
signal PB_aux: std_logic_vector(1 downto 0);
signal PC_aux: std_logic_vector(1 downto 0);
signal PD_aux: std_logic_vector(1 downto 0);
signal PE_aux: std_logic_vector(1 downto 0);

signal PA_i: integer range 0 to 1; -- Los convertimos a integer para poder trabajar con ellos como si fueran números, no bits
signal PB_i: integer range 0 to 1;
signal PC_i: integer range 0 to 1;
signal PD_i: integer range 0 to 1;
signal PE_i: integer range 0 to 1;

signal led_resultado: std_logic;
signal led_resultado_final: std_logic;
signal resultado_i: integer range 0 to 6;
signal boton_trampa_PE: std_logic;


begin

PA<=v_sw(0);
PB<=v_sw(1);
PC<=v_sw(2);
PD<=v_sw(3);
PE<=v_sw(4);
boton_trampa_PE<=v_bt(0);
g_led(0)<=led_resultado_final;


process(PA,PB,PC,PD,PE)
begin
    PA_aux <= '0'&PA;
    PB_aux <= '0'&PB;
    PC_aux <= '0'&PC;
    PD_aux <= '0'&PD;
    PE_aux <= '0'&PE;
end process;

process(PA_aux,PB_aux,PC_aux,PD_aux,PE_aux)
begin
    PA_i<=to_integer(unsigned( PA_aux ));
    PB_i<=to_integer(unsigned( PB_aux ));
    PC_i<=to_integer(unsigned( PC_aux ));
    PD_i<=to_integer(unsigned( PD_aux ));
    PE_i<=to_integer(unsigned( PE_aux ));
end process;

process(PA_i,PB_i,PC_i,PD_i,PE_i)
begin
    resultado_i <= 2*PA_i + PB_i + PC_i + PD_i + PE_i;
end process;

process(resultado_i, PA_i)
begin
    if (resultado_i > 3) then -- Mayoría positiva
        led_resultado <= '1';
    elsif (resultado_i < 3) then -- Mayoría negativa
        led_resultado <= '0';
    else -- Empate
        if (PA_i = 1) then
            led_resultado <= '1'; 
        else
            led_resultado <= '0';
        end if;
    end if;
end process;

process(led_resultado, boton_trampa_PE)
begin
    if (boton_trampa_PE <= '0') then -- No olvidar que los botones por defecto están a 1, y al pulsarlos pasan a 0  
        led_resultado_final <= not(led_resultado); -- Si el botón de trampa esta activado, negamos en resultado (le damos la vuelta)
    else 
        led_resultado_final <=led_resultado;
    end if;
end process;

end Behavioral;