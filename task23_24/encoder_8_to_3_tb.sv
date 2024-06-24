module encoder_8_to_3_tb;

  // AS DUT
  
  //////////////////////////////////////////////////////////////////////////////
  //-SIGNALS
  //////////////////////////////////////////////////////////////////////////////
    
    logic     clk;          // simulation timing clock
    logic [7:0] D=0;          // Input data
  logic [2:0] Y;          // Output data ulta-palta

  //////////////////////////////////////////////////////////////////////////////
  //-VARIABLES
  //////////////////////////////////////////////////////////////////////////////

  int         pass;  // number of time results did matched
  int         fail;  // number of time results did not matched

  //////////////////////////////////////////////////////////////////////////////
  //-RTLS
  //////////////////////////////////////////////////////////////////////////////

  encoder_8_to_3 e8to3_dut (
      .D(D),
      .Y(Y)
  );

    // Driver mailboxs
    mailbox #(logic [7:0]) D_dvr_mbx  = new();
    // Monitor mailboxs
    mailbox #(logic [7:0]) D_mon_mbx  = new();
    mailbox #(logic [2:0]) Y_mon_mbx  = new();

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
/////////////////////////////////////TODO/////////////////////////////
  task static start_driver_monitor_scoreboard();
        fork

            forever begin // in driver
                logic [7:0] data;
                D_dvr_mbx.get(data);
                D <= data;
                @ (posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                begin
                    D_mon_mbx.put(D);
                $display("data in= %b",D);
                end
            end

            forever begin // out monitor
                @ (posedge clk);
                begin
                    Y_mon_mbx.put(Y);
                 $display("data out= %b",Y);              
             end
            end

            forever begin // scoreboard
                logic [2:0] dut_Y_out;
                logic [2:0] expected_Y_out;
                logic [7:0] dut_D_in;
                D_mon_mbx.get(dut_D_in);
                Y_mon_mbx.get(dut_Y_out);
        if (dut_D_in[7])       expected_Y_out = 3'b111;
        else if (dut_D_in[6])  expected_Y_out = 3'b110;
        else if (dut_D_in[5])  expected_Y_out = 3'b101;
        else if (dut_D_in[4])  expected_Y_out = 3'b100;
        else if (dut_D_in[3])  expected_Y_out = 3'b011;
        else if (dut_D_in[2])  expected_Y_out = 3'b010;
        else if (dut_D_in[1])  expected_Y_out = 3'b001;
        else if (dut_D_in[0])  expected_Y_out = 3'b000;
        else expected_Y_out = 0;
        if(expected_Y_out === dut_Y_out) pass++;
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
   repeat (100) begin 
        D_dvr_mbx.put ($urandom);
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
  
