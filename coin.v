module mossbauer
#( lt= 30 , ht = 60 , reset_count = 20000 )
( input wire RF1, input wire RF2, input clk ,output wire C1, output wire C2
);

logic C1on; // When C1 is on, the RF2 will be outputed to CH1 
logic C2on;
logic Vgl ; // Voltage is higher than the low threshold 
logic Vlh ; // Voltage is lower than the high threshold 
integer C1count ; 
integer C2count ; 

logic Vdir ; 
reg last_RF1  ;

// Initial Value: C1on and C2on are turned off . 
initial begin
	last_RF1 <= RF1 ; 
	C1on <= 0 ; 
	C2on <= 0 ;
	Vlh <= 0 ; 
	Vgl <= 0 ;
	C1count <= 0 ;
	C2count <= 0 ;
end 


// Judge the direction of the voltage.
// The Vdir is not used here. 
always @(RF1) begin
	if( RF1 > last_RF1 ) begin
		Vdir <= 1 ;
	end 
	else if (RF1 < last_RF1) begin 
		Vdir <= 0 ; 
	end
	last_RF1 <= RF1 ; 
end 

// When the voltage is higher than the low threshold 
always@(RF1) begin
	if(RF1>lt) 
		Vgl <= 1 ;
	else
		Vgl <= 0 ; 
end

// When the voltage is lower than the high threshold 
always@(RF1) begin
	if(RF1<ht) 
		Vlh <= 1 ;
	else
		Vlh <= 0 ; 
end


// rising edge of the indicator Vgl --> Positive Edge of RF1 -->C1on 
always@(Vgl) begin
	if (Vgl==1) begin
		C1on <= 1 ; 
		C1count <= 0 ; 
		// C2on <= 0 ; 
		// C2count <= 0 ;  
		// For robustness.
	end 
	else begin
		C1on <= 0 ; 
		C1count <= 0 ; 
	end
end

// Rising Edge of the indicator Vlh --> Negative Edge of RF1  --> C2on 
always@(Vlh) begin
	if (Vlh==1) begin
		C2on <= 1 ; 
		C2count <= 0 ; 
		// C1on <= 0 ; 
		// C1countn <= 0 ; 
		// For robustness. 
	end
	else begin 
		C2on <= 0 ; 
		C2count <= 0 ; 
	end	
end

// After a fixed period of time , the CH1 will be turned off . 
always@(posedge clk)	begin 
	if (C1on ==1 ) begin
		C1count <= C1count +1 ; 
	end
		
	if(C1count>= reset_count ) begin
		C1on <= 0 ;
		C1count <= 0 ; 
	end
end

// After a fixed period of time, the Ch2 will also be turned off. 
always@(posedge clk)	begin 
	if (C2on ==1 ) begin
		C2count <= C2count +1 ; 
		end

	if(C2count>= reset_count ) begin
		C2on <= 0 ;
		C2count <= 0 ; 
	end
end

// Output the signal based on the C1on and C2on 
assign C1 = C1on ? RF2 : 0;
assign C2 = C2on ? RF2 : 0;

endmodule 
