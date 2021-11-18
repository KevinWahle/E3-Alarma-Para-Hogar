module codeCkeck (

	input wire KB_RECV,
	input wire [1:0] KB_IN,
	input wire [7:0] validKey,
	input wire CLK,
	
	output reg [1:0] KEY_STATUS = 2'd3
	
	// DEBUG
	//output wire [1:0] DEBUG,
	//output wire [7:0] DEBUG_KEY

);

	parameter [1:0] KEY_OK = 0, KEY_ERROR = 2, NO_KEY = 3;

	wire [1:0] key[3:0];
		
	assign key[0] = validKey[1:0];
	assign key[1] = validKey[3:2];
	assign key[2] = validKey[5:4];
	assign key[3] = validKey[7:6];
	
	reg [1:0] actualKey [3:0];

	reg [1:0] counter = 2'd3;
	
		
	parameter [1:0] READ = 0, FINISH = 1, WAIT = 2;

	reg [1:0] state = WAIT;
	reg [1:0] nextState = WAIT;
	
	
	//assign DEBUG = state;	//counter;
	//assign DEBUG_KEY = { actualKey[3], actualKey[2], actualKey[1], actualKey[0] };

	
	always @ (posedge KB_RECV)
		counter <= counter + 1'b1;

	always @ (state, counter) begin
		case (state)
			READ: begin
				KEY_STATUS <= NO_KEY;
				if (counter == 2'd3)
					nextState <= FINISH;
				else
					actualKey[counter + 1] <= KB_IN;

			end
			
			FINISH: begin
				nextState <= WAIT;
				if ((actualKey[0] == key[0]) & (actualKey[1] == key[1]) &
					(actualKey[2] == key[2]) & (actualKey[3] == key[3]))
					KEY_STATUS <= KEY_OK;
				else
					KEY_STATUS <= KEY_ERROR;
			end
			
			WAIT: begin
				KEY_STATUS <= NO_KEY;
				
				if (counter == 0) begin
					nextState <= READ;
					actualKey[0] <= KB_IN;

				end
				else begin 
					nextState <= WAIT;
				end
			end
			
			default: begin
				nextState <= WAIT;
				KEY_STATUS <= NO_KEY;
			end
		endcase
	end
	
	always @ (posedge CLK)
		state  <= nextState;


endmodule