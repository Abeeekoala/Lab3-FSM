module F1_light #(
    parameter N = 6'd37 //Calibrated
) (
    input logic         clk,
    input logic         rst,
    input logic         trigger,
    output logic [7:0]  data_out
);

logic               cmd_seq;
logic               cmd_delay;
logic               mux_0;
logic               mux_1;
logic               fsm_en;
logic [6:0]         delay_clock;

//Multiplexer
assign  fsm_en = cmd_seq ? mux_1 : mux_0;

lfsr_7  lfsr(
        .clk        (clk),
        .rst        (rst),
        .en         (1),
        .data_out   (delay_clock)
);

delay   delay (
        .clk        (clk),
        .n          (delay_clock) ,
        .trigger    (cmd_delay),
        .rst        (rst),
        .time_out   (mux_0)
);

clktick clktick(
        .clk        (clk),
        .rst        (rst),
        .en         (cmd_seq),
        .N          (N),
        .tick       (mux_1)
);

f1_fsm  f1_fsm(
        .clk        (clk),
        .rst        (rst),
        .en         (fsm_en),
        .trigger    (trigger),
        .cmd_seq    (cmd_seq),
        .cmd_delay  (cmd_delay),
        .data_out   (data_out)
);

endmodule
