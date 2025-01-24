module top (
	input wire clk,
	input wire reset ,
	output reg [3:0] counter
);

	always @(posedge clk or posedge reset) begin
		if (reset)
			counter <= 0;
		else
			counter <= counter + 1;
	end
	endmodule
