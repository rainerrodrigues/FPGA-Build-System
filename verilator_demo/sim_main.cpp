#include "Vtop.h"
#include "verilated.h"

int main(int argc, char** argv) {
	Verilated::commandArgs(argc, argv);

	Vtop* top = new Vtop;
	top->reset = 1;
	top->clk  = 0;

	for (int i = 0;i < 20; i++) {
		top->clk = !top->clk;
		if (i == 1) top->reset = 0;
		top->eval();
		printf("Cycle %d: Counter = %d\\n",i,top->counter);
	}

	delete top;
	return 0;
}
