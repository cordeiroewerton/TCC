module iir_filter_tb();
	logic clk, rst_n, y_valid;
	logic signed [15:0] d_in, d_out;

	integer x_in, x_out; // Corrigido para 'integer'
	logic signed [15:0] x_read;

	iir_filter u0(.clk(clk), .rst_n(rst_n), .x_in(d_in), .x_valid(1),.y_out(d_out), .y_valid(y_valid));

  	always #1 clk = ~clk;

  	always_ff@(posedge clk) begin
		if (x_out) begin // Verifica se o arquivo está aberto
			$fwrite(x_out, "%d, ", d_out);
		end
  	end

  	initial begin
		clk <= 0;
		rst_n <= 0;
		d_in <= 0;
		x_in = $fopen("/home/jose.cordeiro/Desktop/TCC/Sinais_de_entrada/signal_bd.txt", "r"); // Corrigido para '='
		if (x_in == 0) begin
			$display("Erro ao abrir o arquivo 'valores.txt'");
			$finish;
		end
		x_out = $fopen("/home/jose.cordeiro/Desktop/TCC/Sinais_de_saida/saida.txt", "w"); // Corrigido para '='
		if (x_out == 0) begin
			$display("Erro ao abrir o arquivo 'x_valores_out.txt'");
			$finish;
		end
  	end

  	initial begin
		repeat(10) @(posedge clk);
		rst_n <= 0;
		@(posedge clk);
		rst_n <= 1;
		repeat (1) @(posedge clk);
		while (!$feof(x_in)) begin
			$fscanf(x_in, "%d\n", d_in);
			@(posedge clk);
		end
		repeat(100) @(posedge clk);
		$fclose(x_in);
		$fclose(x_out);
		$stop;
  	end
endmodule

