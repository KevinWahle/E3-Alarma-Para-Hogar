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
	reg waiting = 1;
	integer j=0;
	
	// SERIAL OUT --------------------------------------------------------
	serialOut serial(
		.init(init),        		// Recibo de aviso de transmisión
		.clk(CLK),         			// señal de clock
		.state(msg),        		// Estado a transmitir
		.status_send(state_send),	// Envio de aviso de transmisión
		.status_out(state_out) 		// Canal de transmisión
    );
	//--------------------------------------------------------------------
		
	always @ (posedge CLK) begin
		if (EN) begin
			if(waiting) begin
				init = 0;
				cont = cont + 1'b1;
				if (cont == SB) begin
					waiting = 0;
				end
			end
			else begin	// Envia el MSG
				init = 1;
				cont = 0;
				j = j + 1;			// Esperamos que serial out envie todo el mensaje
				if (j>3) begin
					j=0;
					waiting = 1;
				end
			end
		end
		else begin
			init = 0;
			cont = 0;
		end
	end
endmodule