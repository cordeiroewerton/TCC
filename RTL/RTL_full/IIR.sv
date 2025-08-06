module iir_filter #(
    parameter DATA_WIDTH = 16,
    parameter TAPS_B = 3,
    parameter TAPS_A = 3
)(
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic signed [DATA_WIDTH-1:0] x_in,
    input  logic                         x_valid,
    output logic signed [DATA_WIDTH-1:0] y_out,
    output logic                         y_valid
);

    
    logic signed [DATA_WIDTH-1:0] b[TAPS_B-1:0] = '{
        6, 13, 6
        };
    
    logic signed [DATA_WIDTH-1:0] a[TAPS_A-1:0] = '{
        8, 13, 6
    };

    // Buffer para armazenar entradas e saídas anteriores
    logic signed [DATA_WIDTH-1:0] x_buf[TAPS_B];
    logic signed [DATA_WIDTH-1:0] y_buf[TAPS_A];

    logic signed [2*DATA_WIDTH-1:0] acc, acc_a, acc_b;

    integer i;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TAPS_B; i++) x_buf[i] <= 1'b0;
            for (i = 0; i < TAPS_A-1; i++) y_buf[i] <= 1'b0;
            y_valid <= 1'b0;
        end else begin
            x_buf[0] <= x_in;
            x_buf[1] <= x_buf[0];
            x_buf[2] <= x_buf[1];

            y_buf[0] <= acc_a;
            y_buf[1] <= y_buf[0];
            y_buf[2] <= y_buf[1];
        end 
    end

    always_comb begin
        // Parte do numerador
        acc_a = x_buf[0] * b[2] + x_buf[1] * b[1] + x_buf[2] * b[0];

        // Parte do denominador
        y_out = y_buf[0] * a[2] + y_buf[1] * a[1] + y_buf[2] * a[0];

        //y_out = acc_b;

        //y = acc_a + acc_b;
    end
endmodule
