// Timer con tiempo customizable
// Cuenta maxCount pulsos. Al finalizar emite senal de clkFinish por
// un ciclo y vuelve a contar.
module timer (
    input clkSignal,			// Se?al del CLK a utilizar
    input[17:0] maxCount,		// Cantidad de pulsos a contar. Max: 131.071
    input wire EN,      		// Se?al de ENABLE
    input wire RST,     		// Se?al de RESET 
    output wire clkFinish		// Cuando se llega a 0, emite se?al de FINISH (Activo alto)
);

	reg[17:0] clkCont = 18'b0;	    // Cantidad de pulsos restantes, que se iran descontando con cada pulso del CLK

	parameter COUNT = 0, FINISH = 1;
	reg state = COUNT;		// Estado del timer
	reg nextState = COUNT;	// Siguiente estado del timer

	always @(posedge clkSignal, posedge RST, negedge EN) begin
		if (RST | !EN) begin
			state <= COUNT;
			clkCont <= 0;
			
		end
		else
			case (state)
				COUNT: begin
					clkCont = clkCont + 1'b1;
					if (clkCont == maxCount) begin
						state <= FINISH;
					end
				end
				FINISH: begin
					state <= COUNT;
					clkCont <= 0;
				end 
				default:
					state <= COUNT;
			endcase
	end

	assign clkFinish = state;
	
endmodule