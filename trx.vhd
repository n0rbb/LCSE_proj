----------------------------------------------------------------------------------
-- Engineer: Mario de Miguel
-- 
-- Create Date: 20.09.2024 11:42:18
-- Design Name: 
-- Module Name: tx - Behavioral
-- Project Name: LCSE
-- Target Devices: 
-- Tool Versions: 
-- Description: Transmisor protocolo RS232
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity trx is
    port(
        reset, start, clk : in std_logic;
        data : in std_logic_vector(7 downto 0);
        tx, eot : out std_logic
    );
end trx;


architecture Behavioral of trx is
    type estados is (idle, startBit, sendData, stopBit);
    signal current_state, next_state : estados;
    signal step : std_logic := '0';
    signal data_count, data_count_flag : natural := 1;
    signal Pulse_width : std_logic_vector(7 downto 0);
    signal ns_flag, cs_flag : estados; --Flags para luego
    constant PulseEndOfCount : unsigned(7 downto 0) := to_unsigned(173, 8); --173 en 8 bits, + un ciclo de registro.
    
begin
    combinacional : process(current_state, step) --Lógica de transiciones y de salidas. NO SECUENCIAL. Esto se va a ejecutar cada vez que current_state cambie.
    begin
            case current_state is
                when idle =>
                    eot <= '1'; --EOT activo en idle.
                    tx <= '1'; -- Pasamos un 1 porque no hay transmisión.
                  --  if (start = '1') then
                    --    ns_flag <= startBit;
                    --else 
                     --   ns_flag <= idle;
                    --end if;
                    
                when startBit =>
                    eot <= '0'; -- Bajamos EOT.
                    tx <= '0'; -- El primer bit es siempre un 0;
                    ns_flag <= sendData;
                    
                when sendData =>
                    --eot <= '0' -- En teoría no debería cambiar EOT. 
                    tx <= data(data_count - 1);
                    if (data_count = 8) then --Téngase en cuenta que aquí ponemos el flag a stopBit, pero queda un ciclo de ejecución antes de asignar al current state porque step activa otra vez esto.
                        ns_flag <= stopBit;
                        data_count <= 1;                   
                    else
                        data_count <= data_count + 1;
                    end if;
                   
                when stopBit =>
                    --data_count <= 1; 
                    tx <= '1'; -- El bit de terminar es un 1
                    eot <= '0';
                    ns_flag <= idle;
            end case;
            
    end process combinacional;
    
    secuencial : process(clk, reset) --El proceso secuencial incrementa los contadores que tenga que incrementar y llama a combinacional.
    begin
        if (reset = '0') then --Reset asíncrono (se puede resetear en estado de reloj). 
            cs_flag <= idle;
            
     
            
        else 
            if CLK'event and CLK = '1' then --Secuencialidad de las transiciones.
                if (current_state = idle) then --En idle no vamos con la frecuencia de paso de bits, sino con la frecuencia de reloj, así que me da igual el contador pulsewidth.
                    pulse_width <= (others => '0'); --Simplemente voy a poner pulse_width a 0 continuamente
                    --current_state <= next_state; --En idle siempre quiero estar alerta a cambiar el estado en cualquier ciclo de reloj. En realidad, creo que al tener un start asíncrono esto me la pela. 
                  elsif (start = '1') then --Meter en CL
                        cs_flag <= startBit; 
                else --El resto de estados deben mantenerse durante el tiempo de bit (174 ciclos de reloj!)
                       pulse_width <= std_logic_vector(unsigned(pulse_width) + to_unsigned(1, 8));
                    
                    if (unsigned(pulse_width) = PulseEndOfCount) then
                        cs_flag <= ns_flag;
                        step <= not step;
                        pulse_width <= (others => '0');
                    end if;
                end if;
            next_state <= ns_flag;
            current_state <= cs_flag; 
            end if;
    end if;
    end process secuencial;
    
   -- next_state <= ns_flag;
   -- current_state <= cs_flag; 
