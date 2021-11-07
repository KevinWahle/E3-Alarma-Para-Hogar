module	easySerialOut(
	
	input EN,	// ENANBLE
	
	input CLK,	// CLK Signal
	
	input [3:0]msg,	// Mensaje a transmitir
	
	input [3:0]SB, 		// Stand By, canidad de pulsos en los que no se transmite
	
	input state_send,	// Aviso de comienzo de transmision
	
	input state_out		// Canal de transmision
	
	);	  
	
	
	reg init;
	reg [3:0] cont;
	
	serial serialOut(
    .init(init),        // Recibo de aviso de transmisión
    .clk(CLK),         // señal de clock
    .state(msg),        // Estado a transmitir
    .status_send(state_send),		// Envio de aviso de transmisión
    .status_out(state_out), // Canal de transmisión
    );	
	
	
	
	
	
	
	
endmodule