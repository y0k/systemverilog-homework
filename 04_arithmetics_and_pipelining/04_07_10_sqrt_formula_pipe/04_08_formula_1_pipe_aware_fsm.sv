//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_pipe_aware_fsm
(
    input               clk,
    input               rst,

    input               arg_vld,
    input        [31:0] a,
    input        [31:0] b,
    input        [31:0] c,

    output logic        res_vld,
    output logic [31:0] res,

    // isqrt interface

    output logic        isqrt_x_vld,
    output logic [31:0] isqrt_x,

    input               isqrt_y_vld,
    input        [15:0] isqrt_y
);
    // Task:
    //
    // Implement a module formula_1_pipe_aware_fsm
    // with a Finite State Machine (FSM)
    // that drives the inputs and consumes the outputs
    // of a single pipelined module isqrt.
    //
    // The formula_1_pipe_aware_fsm module is supposed to be instantiated
    // inside the module formula_1_pipe_aware_fsm_top,
    // together with a single instance of isqrt.
    //
    // The resulting structure has to compute the formula
    // defined in the file formula_1_fn.svh.
    //
    // The formula_1_pipe_aware_fsm module
    // should NOT create any instances of isqrt module,
    // it should only use the input and output ports connecting
    // to the instance of isqrt at higher level of the instance hierarchy.
    //
    // All the datapath computations except the square root calculation,
    // should be implemented inside formula_1_pipe_aware_fsm module.
    // So this module is not a state machine only, it is a combination
    // of an FSM with a datapath for additions and the intermediate data
    // registers.
    //
    // Note that the module formula_1_pipe_aware_fsm is NOT pipelined itself.
    // It should be able to accept new arguments a, b and c
    // arriving at every N+3 clock cycles.
    //
    // In order to achieve this latency the FSM is supposed to use the fact
    // that isqrt is a pipelined module.
    //
    // For more details, see the discussion of this problem
    // in the article by Yuri Panchul published in
    // FPGA-Systems Magazine :: FSM :: Issue ALFA (state_0)
    // You can download this issue from https://fpga-systems.ru/fsm

    typedef enum bit [3:0] {
    FSM_IDLE   = 4'd0,
    FSM_A      = 4'd1,
    FSM_B      = 4'd2,
    FSM_C      = 4'd3,
    FSM_WAIT   = 4'd4,
    FSM_RES_A  = 4'd5,
    FSM_RES_B  = 4'd6,
    FSM_RES_C  = 4'd7,
    FSM_DONE   = 4'd8
    } state_e;

    state_e state, next_state;
    logic [31:0] result;

    always_ff @(posedge clk) begin
    if (rst)
        state <= FSM_IDLE;
    else
        state <= next_state;
    end

    always_comb begin
    next_state = state;
    case (state)
        FSM_IDLE: if (arg_vld) next_state = FSM_A;
        FSM_A: next_state = FSM_B;
        FSM_B: next_state = FSM_C;
        FSM_C: next_state = FSM_WAIT;
        FSM_WAIT: if (isqrt_y_vld) next_state = FSM_RES_A;
        FSM_RES_A: next_state = FSM_RES_B;
        FSM_RES_B: next_state = FSM_RES_C;
        FSM_RES_C: next_state = FSM_DONE;
        FSM_DONE: next_state = FSM_IDLE;
    endcase
    end

    always_comb begin
    case (state)
        FSM_IDLE: begin
        res_vld = 1'b0;
        end
        FSM_A: begin
        isqrt_x = a;
        isqrt_x_vld = 1'b1;
        end
        FSM_B: begin
        isqrt_x = b;
        isqrt_x_vld = 1'b1;
        end
        FSM_C: begin
        isqrt_x = c;
        isqrt_x_vld = 1'b1;
        end
        FSM_WAIT: begin
        isqrt_x_vld = 1'b0;
        end
        FSM_DONE: begin
        res = result;
        res_vld = 1'b1;
        end
    endcase
    end

    always_ff @(posedge clk) begin
    if (arg_vld)
        result <= 32'd0;
    else if (isqrt_y_vld)
        result <= result + {16'd0, isqrt_y};
    end

endmodule
