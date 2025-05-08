module risc_processor (
    input clk,
    input reset,
    output reg [7:0] result
    );
    // Instruction format: 4-bit opcode, 2-bit rs, 2-bit rt
    parameter ADD = 4'b0000; // rs + rt
    parameter SUB = 4'b0001; // rs - rt
    parameter AND = 4'b0010; // rs & rt
    parameter OR  = 4'b0011; // rs | rt
    parameter LD  = 4'b0100; // Load from memory[rs]
    parameter ST  = 4'b0101; // Store to memory[rt]
    // Internal registers
    reg [7:0] reg_file [0:3]; // 4 registers, 8-bit each
    reg [7:0] memory [0:15];  // 16 bytes of memory
    reg [7:0] pc;             // Program counter
    reg [7:0] ir;             // Instruction register
    reg [7:0] alu_out;        // ALU output
    // State machine
    reg [1:0] state;
    parameter FETCH = 2'b00, DECODE = 2'b01, EXECUTE = 2'b10, WRITE_BACK = 2'b11;
    // Instruction memory (ROM)
    reg [7:0] instr_mem [0:15];
    initial begin
        // Sample program:
        // R1 = R0 + R2
        // R3 = R1 - R0
        // R2 = R1 & R3
        // R0 = R2 | R1
        // Load R1 from memory[R0]
        // Store R2 to memory[R3]
        instr_mem[0] = {ADD, 2'b00, 2'b10, 2'b01}; // ADD R0, R2 -> R1
        instr_mem[1] = {SUB, 2'b01, 2'b00, 2'b11}; // SUB R1, R0 -> R3
        instr_mem[2] = {AND, 2'b01, 2'b11, 2'b10}; // AND R1, R3 -> R2
        instr_mem[3] = {OR,  2'b10, 2'b01, 2'b00}; // OR  R2, R1 -> R0
        instr_mem[4] = {LD,  2'b00, 2'b00, 2'b01}; // LD  mem[R0] -> R1
        instr_mem[5] = {ST,  2'b11, 2'b00, 2'b10}; // ST  R2 -> mem[R3]
    end

    // Control signals
    wire [3:0] opcode = ir[7:4];
    wire [1:0] rs = ir[3:2];
    wire [1:0] rt = ir[1:0];
    wire [1:0] rd = (opcode == LD) ? rt : rs;
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            pc <= 0;
            state <= FETCH;
            result <= 0;
            reg_file[0] <= 8'h05; // R0 = 5
            reg_file[1] <= 8'h00; // R1 = 0
            reg_file[2] <= 8'h03; // R2 = 3
            reg_file[3] <= 8'h00; // R3 = 0
            memory[5] <= 8'h0A;   // mem[5] = 10
        end else begin
            case (state)
                FETCH: begin
                    ir <= instr_mem[pc];
                    pc <= pc + 1;
                    state <= DECODE;
                end
                DECODE: begin
                    state <= EXECUTE;
                end
                EXECUTE: begin
                    case (opcode)
                        ADD: alu_out <= reg_file[rs] + reg_file[rt];
                        SUB: alu_out <= reg_file[rs] - reg_file[rt];
                        AND: alu_out <= reg_file[rs] & reg_file[rt];
                        OR:  alu_out <= reg_file[rs] | reg_file[rt];
                        LD:  alu_out <= memory[reg_file[rs]];
                        ST:  memory[reg_file[rt]] <= reg_file[rs];
                        default: alu_out <= 0;
                    endcase
                    state <= WRITE_BACK;
                end
                WRITE_BACK: begin
                    if (opcode != ST)
                        reg_file[rd] <= alu_out;
                    result <= alu_out;
                    state <= FETCH;
                end
            endcase
        end
    end
endmodule
