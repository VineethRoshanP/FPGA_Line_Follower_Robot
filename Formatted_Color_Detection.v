module Color_Detection (
    input  clk_1MHz, cs_out, en,
	output reg [1:0] filter, cs_scaler,
	output reg [1:0] color
);

// red   -> color = 1;
// green -> color = 2;
// blue  -> color = 3;

// red filter: S2 - 0, S3 - 0
// blue filter: S2 - 0, S3 - 1
// clear filter: S2 - 1, S3 - 0
// green filter: S2 - 1, S3 - 1

reg [9:0] blue_frequency, green_frequency, red_frequency;
reg [13:0] counter;
reg [1:0] prev_color;
reg detect;
reg [31:0] detect_delay;

parameter RED_FILTER = 0, BLUE_FILTER = 1, CLEAR_FILTER = 2, GREEN_FILTER = 3;
parameter RED_COLOR = 1, BLUE_COLOR = 3, CLEAR_COLOR = 0, GREEN_COLOR = 2;

initial begin
    
	filter = BLUE_FILTER; 
	cs_scaler = 2;
	blue_frequency = 0;
	green_frequency = 0;
	red_frequency = 0;
	counter = 0;
	color = CLEAR_COLOR;
	prev_color = CLEAR_COLOR;
	detect = 0;
	detect_delay = 0;

end

always @(posedge cs_out) begin
	
	if (counter <= 10000) begin

        case (filter)

            RED_FILTER: red_frequency = red_frequency + 1;

            BLUE_FILTER: blue_frequency = blue_frequency + 1;

            GREEN_FILTER: green_frequency = green_frequency + 1;

            default;

        endcase

    end

	if (filter == CLEAR_FILTER) begin	
		
		if (en == 1'b1) begin
			
			if (red_frequency >= 100 && green_frequency >= 100 && blue_frequency >= 100) begin
				
				// white detected
				if(prev_color == CLEAR_COLOR) begin
					color = CLEAR_COLOR;
				end
				
				else begin
					color = prev_color;
				end
				
			end
			
			else if (red_frequency < 100 && green_frequency < 100 && blue_frequency < 100) begin
				
				// black detected
				if(prev_color == CLEAR_COLOR) begin
					color = CLEAR_COLOR;
				end
				
				else begin
					color = prev_color;
				end
				
			end
		
			else begin
			
				if(detect == 0 && detect_delay >= 1000000) begin
					
						if (red_frequency >= 100 && green_frequency < 100 && blue_frequency < 100) begin

							// red detected
							color = RED_COLOR;
							prev_color = RED_COLOR;
					
						end

						else if (red_frequency < 100 && green_frequency >= 100 && blue_frequency < 100) begin

							// green detected
							color = GREEN_COLOR;
							prev_color = GREEN_COLOR;
					
						end
					
						else if (red_frequency < 100 && green_frequency < 100 && blue_frequency >= 100) begin

							//blue detected
							color = BLUE_COLOR;
							prev_color = BLUE_COLOR;

						end

						detect = 1;

				end
				
			end
			
		end 
		
		else begin

			detect = 1'b0;

		end


		red_frequency = 0;
		green_frequency = 0;
		blue_frequency = 0;
		
	end

end

always @(posedge clk_1MHz) begin

	if (counter == 10001) begin

        case (filter)
		
			RED_FILTER: filter = CLEAR_FILTER;
			BLUE_FILTER: filter = GREEN_FILTER;
			GREEN_FILTER: filter = RED_FILTER;
			CLEAR_FILTER: filter = BLUE_FILTER;
            default;
		
		endcase
		
		counter = 0;

    end
	
	if (counter <= 10000) begin

		counter = counter + 1;

	end
	
	if (en == 1'b1) begin

		detect_delay = detect_delay + 1;

	end
	
	else begin

		detect_delay = 0;
		
	end

end

endmodule
