module bin_to_gray 
#(  parameter int w=8
)
(   input logic [w-1:0] bin_in,
    output logic [w-1:0] gray_out
);

    for (genvar i=0; i<(w-1);i++)
        begin
            assign gray_out[i] = bin_in[i+1] ^ bin_in[i];
        end
            assign gray_out[w-1] = bin_in[w-1];

endmodule

