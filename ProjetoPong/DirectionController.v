// 4-State Moore state machine

// A Moore machine's outputs are dependent only on the current state.
// The output is written only when the state changes.  (State
// transitions are synchronous.)

module DirectionController
(
	input	clk, rstn, turn_right, turn_left,
	output reg [3:0] data_out // bit 0: x (column) count_enable,
	                          // bit 1: x (column) updown,
	                          // bit 2: y (row) count_enable,
	                          // bit 3: y (row) updown
);
	
	// Signal declaration
	reg [1:0] state_reg, state_next;
				
	// Declare states
	localparam [1:0] F = 2'b00, 
	                 B = 2'b01, 
						  T = 2'b10;
	
	// state register
	always@(posedge clk, negedge rstn)
		if(!rstn)
			state_reg <= F;
		else
			state_reg <= state_next;
	
	// Moore Output depends only on the state
	always @ (state_reg) 
	begin
		case(state_reg)
			F:
				data_out = 4'b0000;
			B:
				data_out = 4'b1100;
			T:
				data_out = 4'b0100;
				
			default:
				data_out = 4'b0000;
		endcase
	end
		
	// Determine the next state
	always @ *
	begin
		case(state_reg)
			F:
				if(turn_right) state_next = B;
				else if(turn_left) state_next = T;
				else state_next = F;
			B:
				// Determine transitions for this state
				if(turn_right) state_next = F;
				else if(turn_left) state_next = T;
				else state_next = B;
				
			T:
				// Determine transitions for this state
				if(turn_right) state_next = B;
				else if(turn_left) state_next = F;
				else state_next = T;
				
			default:
				state_next = F;
		endcase
	end
endmodule