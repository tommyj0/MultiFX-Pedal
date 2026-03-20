
`timescale 1ns / 1ps

module top #(
  parameter OUTPUT_SIGNAL_BITS = 8
)(
  input clk,
  input rst,
  input [4:0] btns,
  input vp_in,  // XADC VP input (XA1_P)
  input vn_in,  // XADC VN input (XA1_N)
  output [OUTPUT_SIGNAL_BITS-1:0] signal_out,
  output [15:0] led
);
wire [15:0] signal_in_16b;
wire [11:0] signal_in_12b;
reg [11:0] signal_in_12b_reg;

assign signal_out = signal_in_12b_reg[11:4];
assign led = {4'h0,signal_out};

assign signal_in_12b = drdy_out ? signal_in_16b[11:0] : signal_in_12b_reg;

//----------- Begin Cut here for INSTANTIATION Template ---// INST_TAG
xadc_wiz_0 xadc_wiz_01 (
  .di_in('b0),                              // input wire [15 : 0] di_in
  .daddr_in('h3),                        // input wire [6 : 0] daddr_in
  .den_in(eoc_out),                            // input wire den_in
  .dwe_in('b0),                            // input wire dwe_in
  .drdy_out(drdy_out),                        // output wire drdy_out
  .do_out(signal_in_16b),                            // output wire [15 : 0] do_out
  .dclk_in(clk),                          // input wire dclk_in
  .reset_in(rst),                        // input wire reset_in
  .vp_in(vp_in),                              // input wire vp_in
  .vn_in(vn_in),                              // input wire vn_in
  // .user_temp_alarm_out(user_temp_alarm_out),  // output wire user_temp_alarm_out
  // .vccint_alarm_out(vccint_alarm_out),        // output wire vccint_alarm_out
  // .vccaux_alarm_out(vccaux_alarm_out),        // output wire vccaux_alarm_out
  .ot_out(ot_out),                            // output wire ot_out
  // .channel_out(channel_out),                  // output wire [4 : 0] channel_out
  .eoc_out(eoc_out),                          // output wire eoc_out
  .alarm_out(alarm_out),                      // output wire alarm_out
  .eos_out(eos_out),                          // output wire eos_out
  .busy_out(busy_out)                        // output wire busy_out
);
// INST_TAG_END ------ End INSTANTIATION Template ---------

always@(posedge clk)
begin
  if (rst)
  begin
    signal_in_12b_reg <= 'b0;
  end
  else
  begin
    signal_in_12b_reg <= signal_in_12b;
  end
end

endmodule