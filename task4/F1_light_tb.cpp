#include "VF1_light.h"
#include "verilated.h"
#include "verilated_vcd_c.h"
#include "iostream"
#include "../vbuddy.cpp" // include vbuddy code
#define MAX_SIM_CYC 100000

uint16_t intToBCD(int decimal) {
    uint16_t bcd = 0;
    int shift = 0;

    // Process each decimal digit and store it in the BCD representation
    while (decimal > 0 && shift < 16) {
        int digit = decimal % 10;                  // Get the last decimal digit
        bcd |= (digit << shift);                   // Place the BCD digit in the correct position
        decimal /= 10;                             // Move to the next decimal digit
        shift += 4;                                // Move 4 bits for the next BCD digit
    }

    return bcd;
}


int main(int argc, char **argv, char **env){
    int simcyc;         // simulation cycle
    int tick;           // each cycle has 2 ticks
    uint16_t time;
    bool timing = 0;

    Verilated::commandArgs(argc, argv);

    VF1_light* top = new VF1_light;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open ("F1_light.vcd");

    //init Vbuddy
    if (vbdOpen() != 1) return(-1);
    vbdHeader("L3T4: F1 Light");
    vbdSetMode(1);

    top->clk = 1;
    top->rst = 1;

    for (simcyc = 0; simcyc < MAX_SIM_CYC; simcyc++){
        // dump variable into VCD file and toggle clock
        for (tick = 0; tick < 2; tick ++){
            tfp->dump (2*simcyc + tick);
            top->clk = !top->clk;
            top->eval ();
        }

        vbdBar(top->data_out & 0xFF);
        top->trigger = vbdFlag();
        top->rst = (simcyc < 2);

        if (!timing && top->data_out == 0b11111111) {
            timing = 1;
        }
        if (top->data_out == 0 && timing){
            vbdInitWatch();
            while (timing){
                if (vbdFlag()){
                    time = intToBCD(vbdElapsed());
                    timing = 0;
                } 
            }
            vbdHex(4, (int(time)>>16) & 0xF);
            vbdHex(3, (int(time)>>8) & 0xF);
            vbdHex(2, (int(time)>>4) & 0xF);
            vbdHex(1, int(time) & 0xF);
        }
        //display simcyc
        vbdCycle(simcyc);

        // either simulation finished, or 'q' is pressed
        if ((Verilated::gotFinish()) || (vbdGetkey()=='q')) 
            exit(0);
    }


}