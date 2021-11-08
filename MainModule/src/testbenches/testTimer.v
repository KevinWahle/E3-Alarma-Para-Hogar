module testCLK();

reg clkSignal = 1;

reg[17:0] maxCount = 5;

wire [17:0]cont;

wire finish;

reg RESET;

reg[1:0] led_sel = 0;

always #10ns clkSignal <= ~clkSignal;

timer myCLK(.EN(1), .clkSignal(clkSignal), .maxCount(maxCount), .clkFinish(finish), .RST(RESET));

initial 
	begin
		RESET = 1;
		#10ns RESET = 0;
	end

always @ (posedge finish)
begin
	
		led_sel = led_sel + 1;
		
		if (led_sel == 0)
		begin
			maxCount = maxCount - 1;
			if (maxCount == 0)
				maxCount = 5;
		end
		
end

endmodule