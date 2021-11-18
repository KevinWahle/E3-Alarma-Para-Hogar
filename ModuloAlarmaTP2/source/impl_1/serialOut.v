module serialOut (
    input wire init,        	// Recibo de aviso de transmisión
    input wire clk,         	// señal de clock
    input wire [3:0]state,      // Estado a transmitir
    output reg status_send,		// Envio de aviso de transmisión
    output reg status_out 		// Canal de transmisión
	);
	
	integer j;
	reg [3:0]temp_data_out;
	
    always @(posedge clk) begin
		if (!init) begin
			status_send <= 1'b0;
			status_out <= 1'b0;
			temp_data_out <= state;
			j = 0;
		end
		else if (init) begin			// Comienza la transmision
			status_send <= 1'b1;
			status_out <= temp_data_out[j];	
			j = j + 1;
			if (j>3)
				j=0;
		end  
	end
endmodule