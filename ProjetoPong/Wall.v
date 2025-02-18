module Wall (
    input wire clk, rstn, 
    input wire [9:0] pixel_x, pixel_y,
    output reg wall_on,        // Sinal que indica se o pixel está dentro da parede
    output reg [11:0] wall_rgb // Cor da parede
);

    // Parâmetros da parede
    localparam WALL_COLOR = 12'hFFF; // Cor da parede (branca)
    localparam WALL_THICKNESS = 10;  // Espessura da parede

    localparam MAX_X = 640;  // Largura da tela
    localparam MAX_Y = 480;  // Altura da tela

    // Lógica para desenhar a parede
    always @(*) begin
        // Inicializa o sinal e a cor da parede
        wall_on = 0;

        // Desenha a parede na parte esquerda (colunas 0 a WALL_THICKNESS)
        if (pixel_x < WALL_THICKNESS) begin
            wall_on = 1;
            wall_rgb = WALL_COLOR;  // Cor da parede
        end

        // Desenha a parede na parte superior (linhas 0 a WALL_THICKNESS)
        else if (pixel_y < WALL_THICKNESS) begin
            wall_on = 1;
            wall_rgb = WALL_COLOR;  // Cor da parede
        end

        // Desenha a parede na parte inferior (linhas MAX_Y-WALL_THICKNESS até MAX_Y)
        else if (pixel_y >= (MAX_Y - WALL_THICKNESS)) begin
            wall_on = 1;
            wall_rgb = WALL_COLOR;  // Cor da parede
        end
    end

endmodule
