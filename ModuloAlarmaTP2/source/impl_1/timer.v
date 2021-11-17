// Timer con tiempo customizable
// Cuenta maxCount pulsos. Al finalizar emite senal de clkFinish por
// un ciclo y vuelve a contar.
module timer (
    input clkSignal,			// Señal del CLK a utilizar
    input[17:0] maxCount,		// Cantidad de pulsos a contar. Max: 131.071
    input wire EN,      		// Señal de ENABLE
    input wire RST,     		// Señal de RESET 
    output reg clkFinish = 0 	// Cuando se llega a 0, emite señal de FINISH (Activo alto)

);

	reg[17:0] clkCont = 0;	    // Cantidad de pulsos restantes, que se iran descontando con cada pulso del CLK

    always @(posedge clkSignal or posedge EN or negedge EN or posedge RST)
    begin
		if(RST) begin
			clkCont <= 0;
        	clkFinish <= 0;  
		end
		else if(EN) begin	 	
			if (clkFinish)
				begin
					clkFinish <= 0;
					clkCont <= 0;
				end
			else begin
	            clkCont = clkCont + 1'b1;
	            if (clkCont == maxCount)
					clkFinish <= 1;
			end
        	end
		else if(!EN)
			clkFinish <= 0;	
    end	
endmodule