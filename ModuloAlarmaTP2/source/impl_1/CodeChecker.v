module keyChecker(
	input pulsed,
	input wire cable1,
	input wire cable2,
	input wire[7:0] keyIn,
	output wire[1:0] keyStatus,
	input wire reset
);

	reg [1:0] valid;
	assign keyStatus = valid;

	parameter OK=0, ERROR=2, NOKEY=3; 

	wire [1:0]key[3:0];
	integer counter=0;
	integer i = 0, j=0;
	reg [1:0]actualKey[0:3]; // = {2'b00,2'b00,2'b00,2'b00};

	initial
	begin
		actualKey[0] = 0;
		actualKey[1] = 0;
		actualKey[2] = 0;
		actualKey[3] = 0;
	end

	assign key[0] = keyIn[1:0];
	assign key[1] = keyIn[3:2];
	assign key[2] = keyIn[5:4];
	assign key[3] = keyIn[7:6];
	
	always	@(posedge pulsed or posedge reset)
		begin	
			if (reset) begin
				counter = 0; 
				valid = NOKEY;	
			end
			else
				begin	
				actualKey[counter]={cable1,cable2};
				counter = counter + 1'b1;
				if (counter==4)
					begin
						valid=OK;
						for (i = 0; i < 4; i = i + 1)
							for (j = 0; j < 2; j = j + 1)
								if (actualKey[i][j] != key[i][j])
									valid = ERROR;	
						counter=0;
					end
				else 
					begin
					valid = NOKEY;
					end
				end 
		end
endmodule	