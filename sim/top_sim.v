`timescale 1ns / 1ps

module top_sim;

  // Clock and reset
  reg clk;
  reg rst;
  
  // Button inputs
  reg [4:0] btns;
  
  // Analog inputs: VP and VN
  reg vp_in;
  reg vn_in;
  
  wire [7:0] signal_out;
  wire [15:0] led;
  
  // Instantiate the DUT
  top dut (
    .clk(clk),
    .rst(rst),
    .btns(btns),
    .vp_in(vp_in),
    .vn_in(vn_in),
    .signal_out(signal_out),
    .led(led)
  );
  
  // Clock generation: 100 MHz (10 ns period)
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end
  
  // Reset and stimulus
  initial begin
    // VCD dump for waveform viewing
    $dumpfile("top_sim.vcd");
    $dumpvars(0, top_sim);
    
    // Initial conditions
    rst = 1;
    btns = 5'b00000;
    vp_in = 1'b0;
    vn_in = 1'b0;
    
    // Release reset after 100 ns
    #100 rst = 0;
    
    // Let XADC initialize and settle
    #1000;
    
    // Simulate some button presses
    #500 btns[0] = 1;
    #50 btns[0] = 0;
    
    // Generate analog-like input using PWM (pulse-width modulation simulation)
    // This simulates a varying voltage input to VP
    repeat_analog_stimulus();
    
    // Run for a total of 5 us
    #5000 $finish;
  end
  
  
  // Task to generate PWM-based analog stimulus (simulates varying voltage)
  task repeat_analog_stimulus;
    integer i;
    begin
      // Ramp up: increase duty cycle from 10% to 90%
      for (i = 10; i <= 90; i = i + 10) begin
        pwm_pulse(i, 100);  // i% duty cycle for 100 us
      end
      
      // Hold at high level
      #500 vp_in = 1;
      
      // Ramp down: decrease duty cycle from 90% to 10%
      for (i = 90; i >= 10; i = i - 10) begin
        pwm_pulse(i, 100);  // i% duty cycle for 100 us
      end
    end
  endtask
  
  // Generate PWM waveform at specified duty cycle
  task pwm_pulse;
    input integer duty_cycle;  // 0-100
    input integer duration_us;  // duration in microseconds
    integer on_time, off_time;
    integer i;
    begin
      on_time = (duration_us * duty_cycle) / 100;
      off_time = duration_us - on_time;
      
      vp_in = 1;
      #(on_time * 1000);   // on_time in ns
      vp_in = 0;
      #(off_time * 1000);  // off_time in ns
    end
  endtask

  // Monitor key signals
  initial begin
    $monitor("Time: %t | clk=%b rst=%b | vp_in=%b vn_in=%b | do_out=%h drdy_out=%b eoc_out=%b | signal_out=%h led=%h",
      $time, clk, rst, vp_in, vn_in, dut.signal_in_16b, dut.drdy_out, dut.eoc_out, signal_out, led);
  end

endmodule
