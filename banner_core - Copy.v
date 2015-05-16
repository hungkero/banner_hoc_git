//-------------------------------------------------------------------
//--  Project     : Chroma_Key
//--  Description : chroma key core without avalon
//--  File        : chroma_key_IP.v
//--  Rev         : 1.2
//--  Designer    : IC Design Lab - VIP Team
//--  Date        : 10 Sep., 2013 
//--------------------------------------------------------------------//
//-- Revision History :
//--------------------------------------------------------------------//
//--   Ver  :| Author            :| Mod. Date :| Changes Made:
// ----------+--------------------+------------+--------------------
//--   V1.0 :| Nguyen Ngoc Tai   :| 10/09/13  :| Initial Revision 
//-----------------------------------------------------------------
//--   V1.1 :| Cuong.TV          :| 12/03/14  :| change 
//-----------------------------------------------------------------
//-----------------------------------------------------------------
//--   V1.2 :| Hieu              :| 23/04/14  :| change 
//-----------------------------------------------------------------
//--  Description :  
//    Tao ra bo mat na cho kenh chroma key
//		Output : avalon ST source 8 bit
// ---------------------------------------------------------------------

module banner_core	
					(		
								clk,
						        reset,		
					//-----------din------------//
								din_ready,
								din_valid,
								din_startofpacket,
								din_endofpacket,
								din_data,
								
																
						//data
								dout_data_ready,
								dout_data_valid,
								dout_data_startofpacket,
								dout_data_endofpacket,
						 		dout_data_data,
						
								dout_mask_ready,
								dout_mask_valid,
								dout_mask_startofpacket,
								dout_mask_endofpacket,
								dout_mask_data				
						
					);
					

input       	clk;
input      		reset;

input				din_ready;

input				din_valid;
input				din_startofpacket;
input				din_endofpacket;
input [23:0]		din_data;

			  //data
input         	dout_data_ready;
output     		dout_data_valid;
output     		dout_data_startofpacket;
output     		dout_data_endofpacket;
output [23:0] 	dout_data_data;
  //mask
input         dout_mask_ready;
output     dout_mask_valid;
output     dout_mask_startofpacket;
output     dout_mask_endofpacket;
output [7:0]  dout_mask_data;


//----------- WIDTH AND HEIGHT ------------//
wire [15:0]  	WIDTH;
wire [15:0]  	HEIGHT;

//----------- data din 1 ------------//

wire 		    din_almost_empty;	// Tin hieu bao empty bo FIFO sink
wire 		    dout_rdreq;			// Tin hieu yeu cau xuat du lieu tu bo FIFO sink


wire	     dout_almost_full_data;		
wire	     dout_almost_full_mask;

wire        data_valid_out;
wire    [7:0]	mask_out;	
wire   [23:0]   data_out;
wire   [23:0] data_delay1;

banner_sink_24bit_fifo	 banner_sink_24bit_fifo
					(	
						.clk(clk),
						.reset(reset),
					//-----------din------------//
						.din_ready(din_ready),
						.din_valid(din_valid),
						.din_startofpacket(din_startofpacket),
						.din_endofpacket(din_endofpacket),
						.din_data(din_data),
					//-----------dout-----------//
						.rdreq_sink(dout_rdreq),  //tu bo banner_data_request
						.almost_empty_sink(din_almost_empty),
						.dout_data_sink(data_out),
					//-----------WIDTH & HEIGHT------------//
						.WIDTH(WIDTH),
						.HEIGHT(HEIGHT)				
					);
									
banner_mask_create		mask_create
							( 	.clk	(clk),
								.reset	(reset), 
						//-----------Video size ------------//
								.WIDTH	(WIDTH),
								.HEIGHT	(HEIGHT),
						//----------- input -----------------//	
								.din_almost_empty(din_almost_empty),
								.dout_almost_full_data(dout_almost_full_data),
								.dout_almost_full_mask(dout_almost_full_mask),
						//------------ output -------------//
								.dout_rdreq(dout_rdreq),
								//.start_of_frame_out(SOF1),
								.data_valid_out(data_valid_out),
								.mask_out(mask_out)								
							);
symbol_delay_data	#(.WIDTH(23),
					  .N(1)
					)
	symbol_delay_data( 	.clock(clk),
						.reset(reset),
						
					    .data_in(data_out),
						.enable(dout_rdreq),
				
						.data_out(data_delay1)				
				);					

					  
banner_source_24bit_fifo
	banner_source_24bit_fifo (	.clk(clk),
								.reset(reset),
							//-----------din------------//
								.WIDTH(WIDTH),
								.HEIGHT(HEIGHT),
							//-----------din------------//	
								.din_wrreq(data_valid_out),
								.din_data(data_delay1),
							//-----------dout-----------//
							    .dout_almost_full(dout_almost_full_data),							
								.dout_ready(dout_data_ready),
								.dout_valid(dout_data_valid),
								.dout_startofpacket(dout_data_startofpacket),
								.dout_endofpacket(dout_data_endofpacket),
								.dout_data(dout_data_data)									
							);											

mask_source_8bit_fifo  
	mask_source_8bit_fifo	(	.clk(clk),
								.reset(reset),
							//-----------din------------//
								.WIDTH(WIDTH),
								.HEIGHT(HEIGHT),
							//-----------din------------//
								.din_wrreq(data_valid_out),
								.din_data(mask_out),
							//-----------dout-----------//
								.dout_almost_full(dout_almost_full_mask),
								.dout_ready(dout_mask_ready),
								.dout_valid(dout_mask_valid),
								.dout_startofpacket(dout_mask_startofpacket),
								.dout_endofpacket(dout_mask_endofpacket),
								.dout_data(dout_mask_data)				
							);					
endmodule
