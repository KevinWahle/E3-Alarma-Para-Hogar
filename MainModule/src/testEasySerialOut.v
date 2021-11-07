module test();
	
	reg clk = 1;
	
	wire serial_out;
	
	wire serial_send;
	
	//wire [3:0] SB = 4;
	
	//wire [3:0] msg = 4'b1010;	
	
	reg test = 0;
	
	reg [2:0] num = 0;
	
	wire [3:0] cable = {test, ~test, num==4, num!=2};
	
	easySerialOut serial(
		.EN(1),	// ENANBLE
		
		.CLK(clk),	// CLK Signal
		
		.msg(cable),		// Mensaje a transmitir
		
		.SB(3), 		// Stand By, canidad de pulsos en los que no se transmite
		
		.state_send(serial_send),	// Aviso de comienzo de transmision
		
		.state_out(serial_out)		// Canal de transmision
	
	);	  
	
	
	always #5ns clk = ~clk;
		
	always #15ns test = ~test;
	always #10ns num = num+1;
	
	
endmodule