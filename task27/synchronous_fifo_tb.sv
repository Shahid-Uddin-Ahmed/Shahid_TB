module synchronous_fifo_tb;

    // Marking the start and end of Simulation
    initial $display("\033[7;36m TEST STARTED \033[0m");
    final   $display("\033[7;36m TEST ENDED \033[0m");

    //////////////////////////////////////////////////////////////////////////////
    //-LOCALPARAMS
    //////////////////////////////////////////////////////////////////////////////

    //localparam bit ;
    localparam int DEPTH = 8 ;
    localparam int DATA_WIDTH = 8 ;

    //////////////////////////////////////////////////////////////////////////////
    //-SIGNALS
    //////////////////////////////////////////////////////////////////////////////

    logic             clk;            // simulation timing clock in
    logic             rst_n;          // active low reset in 
    logic             w_en;           // write enable in
    logic             r_en;           // read enable in
    logic [DATA_WIDTH-1:0] data_in;   //input data
    logic             empty;          // fifo empty out
    logic             full;           // fifo full out
    logic [DATA_WIDTH-1:0] data_out;  //output data

    //////////////////////////////////////////////////////////////////////////////
    //-VARIABLES
    //////////////////////////////////////////////////////////////////////////////

    int         pass;  // number of time results did matched
    int         fail;  // number of time results did not matched

    //////////////////////////////////////////////////////////////////////////////
    //-RTL CONNECTON
    //////////////////////////////////////////////////////////////////////////////

    synchronous_fifo #(
        .DEPTH(DEPTH),
        .DATA_WIDTH(DATA_WIDTH)
        ) u_synchronous_fifo (
        .clk (clk),
        .rst_n (rst_n),
        .w_en (w_en),
        .r_en (r_en),
        .data_in (data_in),
        .empty (empty),
        .full (full),
        .data_out (data_out)
    );

    //Driver Mailbox
    mailbox #(logic [DATA_WIDTH-1:0]) data_in_dvr_mbx  = new();
    //mailbox #(logic) w_en_dvr_mbx  = new();
    //mailbox #(logic) r_en_dvr_mbx  = new();

    //Monitor Mailbox For I/O
    mailbox #(logic [DATA_WIDTH-1:0]) data_in_mon_mbx  = new();
    //mailbox #(logic) w_en_mon_mbx  = new();
    //mailbox #(logic) r_en_mon_mbx  = new();
    //mailbox #(logic) empty_mon_mbx  = new();
    //mailbox #(logic) full_mon_mbx  = new();
    mailbox #(logic [DATA_WIDTH-1:0]) data_out_mon_mbx  = new();

    //////////////////////////////////////////////////////////////////////////////
    //-METHODS
    //////////////////////////////////////////////////////////////////////////////

    // Apply system reset and initialize all inputs
    task static apply_reset();
        #10ns;
        clk     <= '0;
        rst_n   <= '0;
        w_en    <= '0;
        r_en    <= '0;
        data_in <= '0;
        #10ns;
        rst_n   <= '1;
    endtask

    // start toggling system clock forever every 5ns
    
    //always #5 clk = ~clk;

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

    task static driver_monitor_scoreboard();
        fork
            forever begin // in driver
                logic [DATA_WIDTH-1:0] data;
                //logic w;
                //logic r;

                data_in_dvr_mbx.get(data);
                data_in <= data;
                //w_en_dvr_mbx.get(w);
                //w_en <= w;
                //r_en_dvr_mbx.get(r);
                //r_en <= r;
                @(posedge clk);
            end

            forever begin // in monitor
                @ (posedge clk);
                data_in_mon_mbx.put(data_in);
                //w_en_mon_mbx.put(w_en);
                //r_en_mon_mbx.put(r_en);
            end

            forever begin // out monitor
                @ (posedge clk);
                data_out_mon_mbx.put(data_out);
                //full_mon_mbx.put(full);
                //empty_mon_mbx.put(empty);
            end

            ////////////Scoreboard//////////////

            forever begin
                
                logic [DATA_WIDTH-1:0] data_q[$];
                logic [DATA_WIDTH-1:0] expected_data;
                logic [DATA_WIDTH-1:0] dut_data_in;
                logic [DATA_WIDTH-1:0] dut_data_out;
                logic  dut_full;
                logic  dut_empty;

                data_in_mon_mbx.get(dut_data_in);
                //empty_mon_mbx.get(dut_empty);
                //full_mon_mbx.get(dut_full);
                data_out_mon_mbx.get(dut_data_out);

               if (w_en & !full) begin
                   data_q.push_back(dut_data_in);
               end
               if (r_en & !empty) begin
                   expected_data = data_q.pop_front();
               end
               if(expected_data === dut_data_out) pass++;
               else fail++;
            end
        join_none

    endtask

    ///////////////End Scoreboard////////////////

  //////////////////////////////////////////////////////////////////////////////
  //-PROCEDURALS
  //////////////////////////////////////////////////////////////////////////////

  initial begin  // main initial
    $dumpfile("dump.vcd");
    $dumpvars;
    //clock    
    start_clock();
    //reset  
    apply_reset();
    //driver, monitor and scoreboard
    driver_monitor_scoreboard();

    // letting things run for 10 posedge of clk
     //@(posedge clk);
            //fork
                //for (int i=0; i<30; i++) begin
                    @(posedge clk);
                    repeat(20) data_in_dvr_mbx.put($urandom);
                    if(!full) begin
                        //#10;
                        w_en= 1;
                    end
                    else begin
                        w_en = 0;
                    end
                    #10;
                    if(!empty) begin
                        //#10;
                        r_en= 1;
                    end
                    else begin
                        r_en = 0;
                    end
                    #50;
                    w_en = 0;

                    //w_en_dvr_mbx.put(i%2);
                //end
                //for (int i=0; i<30; i++) begin
                    //@(posedge clk);
                    //#2;
                    //r_en_dvr_mbx.put(i%2);
                //end
            //join

    repeat(150) @(posedge clk);

    // printing out number of passes out of total
    $display("\033[1;33m%0d/%0d PASSED\033[0m", pass, pass + fail);

    // end simulation
    $finish;

  end

endmodule

