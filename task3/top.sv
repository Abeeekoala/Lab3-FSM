module top #(
    parameter N = 26
) (
    input logic         clk,
    input logic         rst,
    input logic         N_in,
    output logic [7:0]  data_out
);
logic fsm_en = 0;

clktick clktick(
        .clk        (clk),
        .rst        (rst),
        .en         (1'b1),
        .N          (N_in),
        .tick       (fsm_en)
);

f1_fsm  f1_fsm(
        .clk        (clk),
        .rst        (rst),
        .en         (fsm_en),
        .data_out   (data_out)
);

endmodule
