module serialIn (
    input wire KBinit,          // Recibo de aviso de transmisión
    input wire clk,             // señal de clock
    output reg[3:0] msg=4'b0000,        // mensaje Recibido
    output reg status_receive,    // Aviso de mensaje listo
    input wire serialIn,       // Canal de transmisión
    );
	
    integer counter=0;

    always @(posedge clk)
		begin

			if (KBinit)           	// Comienza la transmision
                begin
				counter = 5;    	// Inicio el contador, aviso y empiezo a transmitir
				status_receive <= 0;
            	end
				
            if(counter)    // Transmisión de bits
                begin
                counter = counter - 1;
				msg[counter-1] = serialIn;
                if (counter ==0)
                	status_receive <= 1;
                end
		end
endmodule