module Test;
	reg SIREN_OUT_;   //Salida de sirena
    reg SENSOR1_IN_, SENSOR2_IN_;  //Sensores

    wire STATUS_OUT_; //Datos
    wire STATUS_SEND_; //Habilitador
    reg [1:0] KB_IN_;   //Datos
    reg KB_RECV_;   //Habilitador 
	
	reg SERCLK_OUT_;
	reg RESET_IN_; 	
	
	MainModule alarmante (
	.SIREN_OUT(SIREN_OUT_), .SENSOR1_IN(SENSOR1_IN_), .SENSOR2_IN(SENSOR2_IN_),
	.STATUS_OUT(STATUS_OUT_), .STATUS_SEND(STATUS_SEND_),
	.KB_IN(KB_IN_), .KB_RECV(KB_RECV_),
	.SERCLK_OUT(SERCLK_OUT_), .RESET_IN(RESET_IN_)  
	);
	
	
initial begin
	#10ns SENSOR1_IN_ = 0; RESET_IN_ = 0;
	#10ns SENSOR2_IN_ = 0; RESET_IN_ = 1;
	#10ns KB_RECV_ =0; KB_IN_= 0; RESET_IN_ = 0;
	
	#5ns KB_IN_={0'b1,0'b1};
	#5ns KB_RECV_ =1; KB_IN_= 1; 
	#10ns KB_RECV_ =0;
	#5ns KB_RECV_ =1; KB_IN_=1; 
	#10ns KB_RECV_ =0;
	#5ns KB_RECV_ =1; KB_IN_=1;
	#10ns KB_RECV_ =0;
	#5ns KB_RECV_ =1; KB_IN_=1;
	#10ns KB_RECV_ =0;

	#10ns $finish;	
	
end
endmodule