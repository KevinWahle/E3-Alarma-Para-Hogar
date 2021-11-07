module	test();
	reg pulsed=0, cable1=0, cable2=0;
	reg[1:0] result;
	reg[1:0] key[0:3]={0,1,2,3};
	
	keyChecker checkitout(pulsed, cable1, cable2, key, result);
	

	initial
		begin
			#5ns cable1=1; cable2=1;
			#5ns pulsed =1; cable1=0; cable2=0; 
			#1ns pulsed =0;
			#5ns pulsed =1; cable1=0; cable2=1; 
			#1ns pulsed =0;
			#5ns pulsed =1; cable1=1; cable2=0;
			#1ns pulsed =0;
			#5ns pulsed =1; cable1=1; cable2=1;
			#1ns pulsed =0;
			
			#10ns
			
			#5ns pulsed =1; cable1=1; cable2=1;
			#1ns pulsed =0;
			#5ns pulsed =1; cable1=1; cable2=0;
			#1ns pulsed =0;
			#5ns pulsed =1; cable1=0; cable2=1;
			#1ns pulsed =0;
			#5ns pulsed =1; cable1=0; cable2=0;
			#1ns pulsed =0;
			#10ns
			$finish;
		end	   

endmodule	
	