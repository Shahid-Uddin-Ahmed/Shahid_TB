module bin_to_gray_tb;

  // AS DUT
  localparam int w = 8;
  //////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////

  logic         clk;  // simulation timing clock
  logic [w-1:0] bin_in;  // input
  logic [w-1:0] gray_out;  // outut

  //////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////

  int         pass;  // number of time results did matched
  int         fail;  // number of time results did not matched

  //////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////

  bin_to_gray #(
      .w(w)
  ) b2g_dut (
      .bin_in(bin_in),
      .gray_out(gray_out)
  );

    // Driver mailboxs
    mailbox #(logic [w-1:0]) bin_in_dvr_mbx  = new();
    
    // Monitor mailboxs
    mailbox #(logic [w-1:0]) bin_in_mon_mbx  = new();
    mailbox #(logic [w-1:0]) gray_out_mon_mbx = new();

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
                logic [w-1:0] data;
                bin_in_dvr_mbx.get(data);
                bin_in <= data;
                @ (posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                begin
                    bin_in_mon_mbx.put(bin_in);
                end
            end

            forever begin // out monitor
                @ (posedge clk);
                begin
                    gray_out_mon_mbx.put(gray_out);
                end
            end

            forever begin // scoreboard
                logic [w-1:0] dut_data_out;
                logic [w-1:0] expected_data_out;
                logic [w-1:0] dut_data_in;
                bin_in_mon_mbx.get(dut_data_in);
                gray_out_mon_mbx.get(dut_data_out);
                expected_data_out = dut_data_in ^ (dut_data_in >> 1);
                if (dut_data_out === expected_data_out) pass++;
                else fail++;
            end
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
              repeat (1000) bin_in_dvr_mbx.put ($urandom);
   //Delay
   //#1000;
   repeat (10) @(posedge clk);
   // print results
   $display("%0d/%0d PASSED", pass, pass+fail);
   // End simulation
   $finish;
  end

endmodule
     
