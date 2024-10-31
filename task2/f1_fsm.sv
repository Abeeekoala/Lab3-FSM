module f1_fsm (
    input   logic       rst,
    input   logic       en,
    input   logic       clk,
    output  logic [7:0] data_out
);
//Define states
// typedef enum {S0, S1, S2, S3, S4, S5, S6, S7, S8} F1_state;                  // Naive way 
typedef enum logic[3:0] {S0, S1, S2, S3, S4, S5, S6, S7, S8} F1_state;       // map a state to a 4-bit binary representation 
                                                                       // i.e. S0 to 4'b0000, and S8 to 4'b1000
F1_state current_S, next_S;

//State registers
always_ff @(posedge clk or posedge rst)
    if (rst)    current_S <= S0;
    else        current_S <= next_S; 
//Next state logic

// always_comb
//     case (current_S)
//         S0:     next_S = en ? S1 : current_S; // if en S1 else current_S
//         S1:     next_S = en ? S2 : current_S;
//         S2:     next_S = en ? S3 : current_S;
//         S3:     next_S = en ? S4 : current_S;
//         S4:     next_S = en ? S5 : current_S;
//         S5:     next_S = en ? S6 : current_S;
//         S6:     next_S = en ? S7 : current_S;
//         S7:     next_S = en ? S8 : current_S;
//         S8:     next_S = en ? S0 : current_S;        
//     endcase

always_comb
    case (current_S)
            S0, S1, S2, S3, S4, S5, S6, S7:     next_S = en ? current_S + 1 : current_S;
            S8:                                 next_S = en ? S0 : current_S;
            default:                            next_S = S0; // handle exceptions
    endcase
//Output logic

// always_comb 
//     case (current_S)
//         S0:     data_out = 8'b0;
//         S1:     data_out = 8'b1;
//         S2:     data_out = 8'b11;
//         S3:     data_out = 8'b111;
//         S4:     data_out = 8'b1111;
//         S5:     data_out = 8'b11111;
//         S6:     data_out = 8'b111111;
//         S7:     data_out = 8'b1111111;
//         S8:     data_out = 8'b11111111;
//     endcase

assign data_out = (8'b1 << current_S) - 1; //Shift by current state and then subtract 1

endmodule
