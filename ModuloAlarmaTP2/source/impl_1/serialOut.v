module serialOut (
    input wire init,        // Recibo de aviso de transmisión
    input wire clk,         // señal de clock
    input wire[3:0] state,        // Estado a transmitir
    output reg status_send,// Envio de aviso de transmisión
    output reg status_out // Canal de transmisión
    );

    integer counter=0;
	reg[3:0] aux;

    always @(posedge clk)
		begin
			if (counter == 0)
	        begin
	                status_send =0;
	                status_out =0;
					aux = state;
	        end

			if (init)           // Comienza la transmision
            begin
                counter = 4;    // Inicio el contador, aviso y empiezo a transmitir
                status_send =1; 
            end
            
            if (counter)    // Transmisión de bits
            begin
                status_out = aux[counter-1];
                counter = counter - 1;
            end  
		end	
endmodule   