/*
module demux_1_to_4_tb;
    // Inputs to DUT
    logic [1:0] sel;
    logic       data_in;
    
    // Outputs from DUT
    logic [3:0] data_out;

    // Instantiate the DUT (Device Under Test)
    demux_1_to_4 dut (
        .sel(sel),
        .data_in(data_in),
        .data_out(data_out)
    );

    // Testbench Signals
    logic [1:0] tb_sel;
    logic       tb_data_in;
    logic [3:0] expected_data_out;
    
    // Driver
    task drive(input logic [1:0] drv_sel, input logic drv_data_in);
        sel     = drv_sel;
        data_in = drv_data_in;
    endtask
    
    // Monitor
    task monitor();
        $display("Time: %0t | sel = %b | data_in = %b | data_out = %b", $time, sel, data_in, data_out);
    endtask
    
    // Scoreboard
    task check(input logic [3:0] exp_data_out);
        if (data_out !== exp_data_out) begin
            $display("FAILL at time %0t: Expected data_out = %b, but got %b", $time, exp_data_out, data_out);
        end else begin
            $display("PASS at time %0t: Expected data_out = %b, got %b", $time, exp_data_out, data_out);
        end
    endtask

    // Generate VCD dump for GTKWave
    initial begin
        $dumpfile("dump.vcd");
        $dumpvars;
    end
    
    // Test Cases
    initial begin
        // Test case 1
        tb_sel = 2'b00; tb_data_in = 1'b1; expected_data_out = 4'b0001;
        drive(tb_sel, tb_data_in);
        #10;
        monitor();
        check(expected_data_out);

        // Test case 2
        tb_sel = 2'b01; tb_data_in = 1'b1; expected_data_out = 4'b0010;
        drive(tb_sel, tb_data_in);
        #10;
        monitor();
        check(expected_data_out);

        // Test case 3
        tb_sel = 2'b10; tb_data_in = 1'b1; expected_data_out = 4'b0100;
        drive(tb_sel, tb_data_in);
        #10;
        monitor();
        check(expected_data_out);

        // Test case 4
        tb_sel = 2'b11; tb_data_in = 1'b1; expected_data_out = 4'b1000;
        drive(tb_sel, tb_data_in);
        #10;
        monitor();
        check(expected_data_out);

        // Finish simulation
        $finish;
    end
endmodule
*/

module demux_1_to_4_tb;

  // AS DUT
  
  //////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////
    
    logic       clk;      // simulation timing clock
    logic [1:0] sel=0;      // 2-bit select line
    logic       data_in=0;  // Input data
    logic [3:0] data_out; // Output data

  //////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////

  int         pass;  // number of time results did matched
  int         fail;  // number of time results did not matched

  //////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////

  demux_1_to_4 d1to4_dut (
      .sel(sel),
      .data_in(data_in),
      .data_out(data_out)
  );

    // Driver mailboxs
    mailbox #(logic) data_in_dvr_mbx  = new();
    mailbox #(logic [1:0]) sel_dvr_mbx  = new();
    // Monitor mailboxs
    mailbox #(logic) data_in_mon_mbx  = new();
    mailbox #(logic [1:0]) sel_mon_mbx  = new();
    mailbox #(logic [3:0]) data_out_mon_mbx = new();

   ////////////////////////////////////////////////////////////////////////////
   // METHODS
   ////////////////////////////////////////////////////////////////////////////

   // start toggling system clock forever every 5ns
  task static start_clock();
    fork
      forever begin
        clk <= '1;
        #5ns;
        clk <= '0;
        #5ns;
      end
    join_none
  endtask
  
  task static start_driver_monitor_scoreboard();
        fork

            forever begin // in driver
                logic [1:0] select;
                logic data;
                sel_dvr_mbx.get(select);
                sel <= select;
                data_in_dvr_mbx.get(data);
                data_in <= data;
                $display("-------------------------data---------in--------= %b",data_in);
                @ (posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                begin
                    sel_mon_mbx.put(sel);
                    data_in_mon_mbx.put(data_in);
                $display("----------------------sel--------------------= %b",sel);
                $display("----------------------data_in--------------------= %b",data_in);
                end
            end

            forever begin // out monitor
                @ (posedge clk);
                begin
                    data_out_mon_mbx.put(data_out);
                $display("--------------data-----out-----------------------= %b",data_out);
                end
            end

            forever begin // scoreboard
                //$display("---------------------------Socre***********************************");
                logic [3:0] dut_data_out;
                logic [3:0] expected_data_out;
                logic dut_data_in;
                logic [1:0] dut_sel;
                $display("---------------------------Socre***********************************");
                data_in_mon_mbx.get(dut_data_in);
                data_out_mon_mbx.get(dut_data_out);
                sel_mon_mbx.get(dut_sel);
                $display("---------------------------sel= %b",dut_sel);
                expected_data_out[0] = (dut_sel == 2'b00) ? dut_data_in : 1'b0;
                expected_data_out[1] = (dut_sel == 2'b01) ? dut_data_in : 1'b0;
                expected_data_out[2] = (dut_sel == 2'b10) ? dut_data_in : 1'b0;
                expected_data_out[3] = (dut_sel == 2'b11) ? dut_data_in : 1'b0;
                if (dut_data_out[0] === expected_data_out[0]) pass++;
                else if (dut_data_out[1] === expected_data_out[1]) pass++;
                else if (dut_data_out[2] === expected_data_out[2]) pass++;
                else if (dut_data_out[3] === expected_data_out[3]) pass++;
                else fail++;
            end
            
        /*        // Scoreboard
        forever begin
            logic [3:0] dut_data_out;
            logic [3:0] expected_data_out;
            logic dut_data_in;
            logic [1:0] dut_sel;
            data_in_mon_mbx.get(dut_data_in);
            data_out_mon_mbx.get(dut_data_out);
            sel_mon_mbx.get(dut_sel);

            // Determine the expected data_out based on sel and data_in
            expected_data_out = 4'b0000;
            case (dut_sel)
                2'b00: expected_data_out[0] = dut_data_in;
                2'b01: expected_data_out[1] = dut_data_in;
                2'b10: expected_data_out[2] = dut_data_in;
                2'b11: expected_data_out[3] = dut_data_in;
            endcase

            // Check the DUT output against the expected output
            if (dut_data_out === expected_data_out) begin
                pass++;
                $display("PASS at time %0t: Expected = %b, Got = %b", $time, expected_data_out, dut_data_out);
            end else begin
                fail++;
            $display("FAIL at time %0t: Expected = %b, Got = %b", $time, expected_data_out, dut_data_out);
            end
           end*/


        join_none

  endtask
  initial begin
   // Dump VCD file for manual checking
   $dumpfile("dump.vcd");
   $dumpvars;
   // Start clock
   start_clock();
   // Start all the verification components
   start_driver_monitor_scoreboard();
   // generate random data inputs
   @(posedge clk);
              //repeat (5) bin_in <= ($urandom);
   repeat (100) begin 
        data_in_dvr_mbx.put (1);
        sel_dvr_mbx.put ($urandom);
   end
   //Delay
   //#1000;
   repeat (20) @(posedge clk);
   // print results
   $display("%0d/%0d PASSED", pass, pass+fail);
   // End simulation
   $finish;
  end

endmodule
     

