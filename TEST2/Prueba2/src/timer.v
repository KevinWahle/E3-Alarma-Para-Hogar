// Timer con tiempo customizable
// Cuenta maxCount pulsos. Al finalizar emite senal de clkFinish por
// un ciclo y vuelve a contar.
module timer (
    input clkSignal,			// Señal del CLK a utilizar
    input[17:0] maxCount,		// Cantidad de pulsos a contar. Max: 131.071
    input wire EN,      		// Señal de ENABLE
    input wire RST,     		// Señal de RESET 
    output wire clkFinish		// Cuando se llega a 0, emite señal de FINISH (Activo alto)
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

	assign clkFinish = (state == FINISH);

	// // Esto no va a funcoinar, necesito que sea solo en el flanco del CLK
    // always @(clkSignal, EN, RST)
    // begin
	// 	if(RST) begin
    //     	clkFinish <= 1'b0;  
	// 		clkCont <= 18'b0;
	// 	end
	// 	else if(EN) begin	 	
	// 		if (clkFinish)
	// 			begin
	// 				clkFinish <= 1'b0;
	// 				clkCont <= 18'b0;
	// 			end
	// 		else begin
	//             clkCont = clkCont + 1'b1;
	//             if (clkCont == maxCount)
	// 				clkFinish <= 1'b1;
	// 		end
    //     	end
	// 	else if(!EN)
	// 		clkFinish <= 0;	
    // end	
endmodule