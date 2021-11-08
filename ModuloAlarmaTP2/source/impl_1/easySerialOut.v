// Facilita la comunicacion serie.
// Al estar ENABLE, envia el mensaje
// Luego espera SB+1 pulsos sin enviar
// Y luego vuelve a enviar
module	easySerialOut(
	
	input EN,	// ENANBLE
	
	input CLK,	// CLK Signal
	
	input [3:0]msg,		// Mensaje a transmitir
	
	input [3:0]SB, 		// Stand By, canidad de pulsos en los que no se transmite
	
	output state_send,	// Aviso de comienzo de transmision
	
	output state_out		// Canal de transmision
	
	);	  
	
	
	reg init;
	reg [3:0] cont = 0;
	reg waiting = 0;
	
	serialOut serial(
    .init(init),        // Recibo de aviso de transmisiÃ³n
    .clk(CLK),         // seÃ±al de clock
    .state(msg),        // Estado a transmitir
    .status_send(state_send),		// Envio de aviso de transmisiÃ³n
    .status_out(state_out) // Canal de transmisiÃ³n
    );
	
	
	always @ (posedge CLK)
	begin
			
		if (EN)
		begin
			
			if (waiting)
			begin
				cont = cont + 1;
				if (cont == SB)
				begin
					waiting = 0;
					init = 1;
				end
			end
			else
			begin
				init = 0;
			end
		end
			
	end
	
	always @ (negedge state_send)
	begin
		cont = 0;
		waiting = 1;
	end
	
	
endmodule