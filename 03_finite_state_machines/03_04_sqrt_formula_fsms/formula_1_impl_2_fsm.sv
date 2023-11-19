//----------------------------------------------------------------------------
// Task
//----------------------------------------------------------------------------

module formula_1_impl_2_fsm
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

    output logic        isqrt_1_x_vld,
    output logic [31:0] isqrt_1_x,

    input               isqrt_1_y_vld,
    input        [15:0] isqrt_1_y,

    output logic        isqrt_2_x_vld,
    output logic [31:0] isqrt_2_x,

    input               isqrt_2_y_vld,
    input        [15:0] isqrt_2_y
);

    // Task:
    // Implement a module that calculates the folmula from the `formula_1_fn.svh` file
    // using two instances of the isqrt module in parallel.
    //
    // Design the FSM to calculate an answer and provide the correct `res` value

    enum logic [1:0] 
    {
        st_idle        = 2'd0,
        st_wait_res_ab = 2'd1,
        st_wait_res_c  = 2'd2
    } state, next_state;

    always_comb 
    begin
        next_state = state;
        isqrt_1_x = 'x;
        isqrt_1_x_vld = 1'b0;
        isqrt_2_x = 'x;
        isqrt_2_x_vld = 1'b0;

        case (state)
            st_idle: 
            begin
                isqrt_1_x = a;
                isqrt_2_x = b;
                if (arg_vld) 
                begin
                    isqrt_1_x_vld = 1'b1;
                    isqrt_2_x_vld = 1'b1;
                    next_state = st_wait_res_ab;
                end
            end

            st_wait_res_ab: 
            begin
                isqrt_1_x = c;
                isqrt_2_x = '0;
                if (isqrt_1_y_vld && isqrt_2_y_vld) 
                begin
                    isqrt_1_x_vld = 1'b1;
                    isqrt_2_x_vld = 1'b1;
                    next_state = st_wait_res_c;
                end
            end

            st_wait_res_c: 
            begin
                if (isqrt_1_y_vld && isqrt_2_y_vld)
                    next_state = st_idle;
            end
        endcase
    end

    always_ff @ (posedge clk) 
    begin
        if (rst)
            state <= st_idle;
        else
            state <= next_state;
    end

    always_ff @ (posedge clk)
    begin
        if (state == st_idle)
            res <= '0;
        else if (isqrt_1_y_vld && isqrt_2_y_vld)
            res <= res + isqrt_1_y + isqrt_2_y;
    end

    always_ff @ (posedge clk) 
    begin
        if (rst)
            res_vld <= 1'b0;
        else
            res_vld <= (state == st_wait_res_c & (isqrt_1_y_vld & isqrt_2_y_vld));
    end
endmodule
