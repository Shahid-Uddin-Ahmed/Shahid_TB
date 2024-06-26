module mealy_o_1010_tb;

    // AS DUT
    
    ///////////////////////////////////////////////////////////////////////////////////////////////////
    //-LOCALPARAMS
    ///////////////////////////////////////////////////////////////////////////////////////////////////

    //localparam bit ;
    //localparam int ;
    //localparam int ;
  
    //////////////////////////////////////////////////////////////////////////////
    //-SIGNALS
    //////////////////////////////////////////////////////////////////////////////
    
    logic   clk;        // simulation timing clock
    logic   rst_n;      // active low reset  
    logic   in;          // Input data
    logic   out;          // Output data

    //////////////////////////////////////////////////////////////////////////////
    //-VARIABLES
    //////////////////////////////////////////////////////////////////////////////

    int         pass;  // number of time results did matched
    int         fail;  // number of time results did not matched

    //////////////////////////////////////////////////////////////////////////////
    //-RTLS
    //////////////////////////////////////////////////////////////////////////////

    mealy_o_1010 u_mealy_o_1010(
      .x(in),
      .z(out),
      .clk(clk),
      .rst_n(rst_n)
    );

    // Driver mailboxs
    mailbox #(logic) in_dvr_mbx  = new();
    // Monitor mailboxs
    mailbox #(logic) in_mon_mbx  = new();
    mailbox #(logic) out_mon_mbx  = new();

    ////////////////////////////////////////////////////////////////////////////
    // METHODS
    ////////////////////////////////////////////////////////////////////////////
  
    // Apply system reset and initialize all inputs
    task static apply_reset();
    #100ns;
    rst_n <= '0;
    clk   <= '0;
    in    <= '0;
    out   <= '0;
    #100ns;
    rst_n <= '1;
    endtask
    
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
                logic data;
                in_dvr_mbx.get(data);
                in <= data;
                @ (posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                begin
                    in_mon_mbx.put(in);
                end
            end

            forever begin // out monitor
                @ (posedge clk);
                begin
                    out_mon_mbx.put(out);
             end
            end
    /////////////////////////////////Scoreboard/////////////////////////////////////
    ///////////////////////////////////////////////////////////////////////////////

            forever begin 
                logic dut_out;
                logic [0:3] expected_out;
                logic dut_in;
                in_mon_mbx.get(dut_in);
                out_mon_mbx.get(dut_out);

                expected_out[0] <= dut_in;
                expected_out[1] <= expected_out[0];
                expected_out[2] <= expected_out[1];
                expected_out[3] <= expected_out[2];

           if(expected_out === 1010) 
               dut_out=1;
           else dut_out=0;

           if(dut_out === out) 
                 pass++;
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
        // Apply reset
         apply_reset();
        // Start all the verification components
        start_driver_monitor_scoreboard();
        // generate random data inputs
         @(posedge clk);
              //repeat (5) bin_in <= ($urandom);
         repeat (100) begin 
            in_dvr_mbx.put($urandom);
        end
        //Delay
        repeat (150) @(posedge clk);
        // print results
        $display("%0d/%0d PASSED", pass, pass+fail);
        // End simulation
        $finish;
    end

endmodule
  
