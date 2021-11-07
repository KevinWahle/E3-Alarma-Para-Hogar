parameter OK=0, ERROR=2, NOKEY=3; 

module keyChecker(
	input pulsed,
	input wire cable1,
	input wire cable2,
	input reg[1:0] key[0:3],
	output reg[1:0] valid=NOKEY
);
	integer counter=0;
	reg[1:0] actualKey[0:3]= {0,0,0,0};
	
	always	@(posedge pulsed)
		begin	
			actualKey[counter]={cable1,cable2};
			counter = counter + 1;
			if (counter==4)
				begin
					if (actualKey==key)
						valid=OK;
					else
						valid=ERROR;
					counter=0;
				end
			else 
				begin
				valid = NOKEY;
				end
		end
endmodule	