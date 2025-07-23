module iir_filter #(
    parameter DATA_WIDTH = 16,
    parameter TAPS_B = 5,
    parameter TAPS_A = 5
)(
    input  logic                         clk,
    input  logic                         rst_n,
    input  logic signed [DATA_WIDTH-1:0] x_in,
    input  logic                         x_valid,
    output logic signed [DATA_WIDTH-1:0] y_out,
    output logic                         y_valid
);

    // Coeficientes b (numerador) — Q1.15
    logic signed [DATA_WIDTH-1:0] b[TAPS_B] = '{
        180, 673, 988, 673, 180
    };
    // Coeficientes a (denominador) — Q1.15 (a[0] não é usado)
    logic signed [DATA_WIDTH-1:0] a[TAPS_A] = '{
        256, 792, 966, 554, 128
    };

    // Buffer para armazenar entradas e saídas anteriores
    logic signed [DATA_WIDTH-1:0] x_buf[TAPS_B];
    logic signed [DATA_WIDTH-1:0] y_buf[TAPS_A-1];  // não precisa armazenar y[n] atual

    logic signed [2*DATA_WIDTH-1:0] acc, acc_a, acc_b;

    integer i;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            for (i = 0; i < TAPS_B; i++) x_buf[i] <= 1'b0;
            for (i = 0; i < TAPS_A-1; i++) y_buf[i] <= 1'b0;
            y_valid <= 1'b0;
        end else begin
            if (x_valid) begin
                // Deslocar buffers
                for (i = TAPS_B-1; i > 0; i--) x_buf[i] <= x_buf[i-1];
                x_buf[0] <= x_in;

                for (i = TAPS_A-1; i > 0; i--) y_buf[i] <= y_buf[i-1];
                y_buf[0] <= y_out;

                y_valid <= 1'b1;
            end else begin
                y_valid <= 1'b0;
            end
        end
    end

    always_comb begin
        // Parte do numerador
        acc_a = (x_buf[0] * b[0]) + (x_buf[1] * b[1]) + (x_buf[2] * b[2]) +
        (x_buf[3] * b[3]) + (x_buf[4] * b[4]);

        // Parte do denominador
        acc_b = (y_buf[0] * a[1]) + (y_buf[1] * a[2]) + (y_buf[2] * a[3]) + (y_buf[3] * a[4]);

        acc = acc_a - acc_b;

        y_out = acc >>> 14;
    end
endmodule
