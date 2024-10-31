module f1_fsm (
    input   logic       rst,
    input   logic       en,
    input   logic       clk,
    input   logic       trigger,
    output  logic [7:0] data_out,
    output  logic       cmd_seq,
    output  logic       cmd_delay
);
//Define states
logic start = 1'b0;

typedef enum logic[3:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8} F1_state;      // map a state to a 4-bit binary representation 
                                                                            // i.e. S0 to 4'b0000, and S8 to 4'b1000
F1_state current_S, next_S;

//State registers
always_ff @(posedge clk or posedge rst)
    if (rst)    current_S <= S0;
    else        current_S <= next_S;
always_comb
    case (current_S)
            S0:begin
                                                next_S = en ? current_S + 1 : current_S;
                                                start = trigger ? 1'b1 : start;
            end
            S1, S2, S3, S4, S5, S6:             next_S = en ? current_S + 1 : current_S;
            S7:begin
                                                next_S = en ? current_S + 1 : current_S;
                                                cmd_delay = en ? 1'b1: 1'b0;
            end
            S8:begin                            
                                                cmd_delay = 1'b0;
                                                next_S = en ? S0 : current_S;
                                                start = en ? 1'b0: start;
            end
            default:                            next_S = S0; // handle exceptions
    endcase
//Output logic

assign cmd_seq = !(current_S == S8) && start;
assign data_out = (8'b1 << current_S) - 1; //Shift by current state and then subtract 1

endmodule
