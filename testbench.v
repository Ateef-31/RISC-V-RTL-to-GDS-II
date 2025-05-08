module risc_processor_tb;
    reg clk;
    reg reset;
    wire [7:0] result;

    // Instantiate the processor
    risc_processor uut (
        .clk(clk),
        .reset(reset),
        .result(result)
    );
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz clock
    end
    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        #10;
        reset = 0;
        // Run for enough cycles to execute all instructions
        #200;
        // Display final register and memory contents
        $display("Final Register Contents:");
        $display("R0 = %h", uut.reg_file[0]);
        $display("R1 = %h", uut.reg_file[1]);
        $display("R2 = %h", uut.reg_file[2]);
        $display("R3 = %h", uut.reg_file[3]);
        $display("Memory[3] = %h", uut.memory[3]);
        $display("Memory[5] = %h", uut.memory[5]);
        $display("Final Result = %h", result);
        // Stop simulation
        $finish;
    end
    // Monitor signals
    initial begin
        $monitor("Time=%0t State=%b PC=%h IR=%h Result=%h", 
                 $time, uut.state, uut.pc, uut.ir, result);
    end
endmodule
