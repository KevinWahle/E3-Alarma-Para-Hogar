
module keyChecker(
	input pulsed,
	input wire cable1,
	input wire cable2,
	input wire[7:0] keyIn,
	output reg[1:0] valid=3
);

	parameter OK=0, ERROR=2, NOKEY=3; 

	reg [1:0]key[3:0];

	integer counter=0;
	integer i = 0;
	reg[1:0] actualKey[0:3]; // = {2'b00,2'b00,2'b00,2'b00};

	initial
	begin
		actualKey[0] = 0;
		actualKey[1] = 0;
		actualKey[2] = 0;
		actualKey[3] = 0;
		
		key[0] = keyIn[1:0];
		key[1] = keyIn[3:2];
		key[2] = keyIn[5:4];
		key[3] = keyIn[7:6];
	end
	
	
	always	@(posedge pulsed)
		begin	
			actualKey[counter]={cable1,cable2};
			counter = counter + 1;
			if (counter==4)
				begin
					valid=OK;
					for (i = 0; i < 4; i = i + 1)
						if (actualKey[i] != key[i])
							valid = ERROR;	
					
					counter=0;
				end
			else 
				begin
				valid = NOKEY;
				end
		end
endmodule	