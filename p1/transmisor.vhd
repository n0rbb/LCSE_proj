library IEEE;
use IEEE.std_logic_1164.all;


entity transmisor is
	port (
		reset, start: in boolean;
         	clk: in std_logic;
		data: out std_logic;
		eot: out boolean
	);
end;

architecture behavior of transmisor is
	type estados is (idle, startBit, sendData, stopBit);
	signal current_state, next_state: estados;
	signal data: std_logic;
	signal eot: boolean;

begin
	process(reset, current_state, reset, start)
	begin 
		next_state <= current_state;
		eot <= true; 
		data <= '0';
		-- Definir aquí los contadores y PulseEndOfCount creo
		if (reset = true) then
			next_state <= idle;
		else
			case current_state is
				when idle =>
					if (start = true) then
						next_state <= startBit;
					else
						next_state <= idle;
					end if;
				
				when startBit => 
					if (pulse_width >= pulseEndOfCount) then
						pulse_width := 0;
						next_state <= sendData;
					else
						pulse_width:= pulse_width + 1;
						next_state <= startBit;
					end if;

				when sendData =>
					if (pulse_width = pulseEndOfCount and data_count = 7) then
						pulse_width := 0;
						data_count := 0;
						next_state <= stopBit;
					
					elsif (pulse_width = pulseEndOfCount and data_count < 7) then
						pulse_width := 0;
						data_count := data_count + 1;
						next_state <= sendData;
					else
						pulse_width := pulse_width + 1;
						next_state <= sendData;
					end if;

				when stopBit => 
					if (pulse_width >= pulseEndOfCount) then
						pulse_width := 0;
						next_state <= idle;
					else
						pulse_width:= pulse_width + 1;
						next_state <= stopBit;
					end if;

	end process;

end;

