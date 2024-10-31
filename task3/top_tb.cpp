#include "Vtop.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "../vbuddy.cpp"

#define MAX_SIM_CYC 1000000

int main(int argc, char **argv, char **env){
    int simcyc;         // simulation cycle
    int tick;           // each cycle has 2 ticks

    Verilated::commandArgs(argc, argv);

    Vtop* top = new Vtop;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("top.vcd");

    //init Vbuddy
    if (vbdOpen() != 1) return(-1);
    vbdHeader("L3T3: Auto FSM");
    // vbdSetMode(1);

    top->clk = 1;
    top->rst = 1;

    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++){
        // dump variable into VCD file and toggle clock
        top->N_in = vbdValue();
        for (tick = 0; tick < 2; tick ++){
            tfp->dump (2*simcyc + tick);
            top->clk = !top->clk;
            top->eval ();
        }

        vbdBar(top->data_out & 0xFF);
        
        top->rst = (simcyc < 2);

        //display simcyc
        vbdCycle(simcyc);

        // either simulation finished, or 'q' is pressed
        if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) 
            exit(0);
    }


}
