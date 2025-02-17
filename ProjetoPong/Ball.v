module Ball (
    input wire clk, rstn, 
    input wire refr_tick,  
    input wire [9:0] pixel_x, pixel_y, 
    input wire [9:0] paddle_x, paddle_y,  // Posição do paddle
    input wire paddle_on,  // Sinal indicando se a bola está em contato com o paddle
    input wire wall_on,    // Sinal indicando se a parede está ativa
    output reg [9:0] x, y,               
    output reg [11:0] ball_rgb,          
    output reg ball_on                 
);

    // Parâmetros da bola
    localparam BALL_SIZE = 10;  // Tamanho da bola (10x10 pixels)
    localparam BALL_SPEED = 2;  // Velocidade da bola
    localparam BALL_COLOR = 12'h0FF;  // Cor da bola (vermelha)
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    localparam WALL_THICKNESS = 10; // Espessura da parede
    localparam PADDLE_WIDTH = 10;   // Largura da barra
    localparam PADDLE_HEIGHT = 100; // Altura da barra

    // Variáveis de velocidade da bola
    reg [9:0] vx, vy;

    // Inicializa a posição da bola e a direção do movimento
    always @(posedge clk or negedge rstn) begin
        if (~rstn) begin
            x <= MAX_X / 2;  // Posiciona a bola no centro horizontal
            y <= MAX_Y / 2;  // Posiciona a bola no centro vertical
            vx <= BALL_SPEED; // Velocidade horizontal
            vy <= BALL_SPEED; // Velocidade vertical
        end else if (refr_tick) begin
            // Verificação de colisão com as paredes
            if (wall_on) begin
                // Colisão com a parede superior
                if (y <= WALL_THICKNESS) begin
                    vy <= BALL_SPEED;  // Inverte a direção vertical para baixo
                end
                // Colisão com a parede inferior
                if (y + BALL_SIZE >= MAX_Y - WALL_THICKNESS) begin
                    vy <= -BALL_SPEED;  // Inverte a direção vertical para cima
                end
                // Colisão com a parede esquerda
                if (x <= WALL_THICKNESS) begin
                    vx <= BALL_SPEED;  // Inverte a direção horizontal para a direita
                end
            end

            // Verificação de colisão com o paddle
            if (paddle_on) begin
                // A bola bate no paddle, verifica se a bola está dentro da área do paddle
                if ((x + BALL_SIZE >= paddle_x) && (x <= paddle_x + PADDLE_WIDTH) && 
                    (y + BALL_SIZE >= paddle_y) && (y <= paddle_y + PADDLE_HEIGHT)) begin
                    // Inverte a direção da bola
                    vy <= -vy;  // Inverte a direção vertical da bola
                    // Ajuste a posição da bola para não atravessar o paddle
                    if (vy < 0) begin
                        y <= paddle_y + PADDLE_HEIGHT;  // Coloca a bola no topo do paddle
                    end else if (vy > 0) begin
                        y <= paddle_y - BALL_SIZE;  // Coloca a bola abaixo do paddle
                    end
                end
            end

            // Movimentação da bola
            x <= x + vx;
            y <= y + vy;
        end
    end

    // Define quando o pixel da bola está sendo desenhado
    always @(*) begin
        if ((x <= pixel_x) && (pixel_x < x + BALL_SIZE) && (y <= pixel_y) && (pixel_y < y + BALL_SIZE)) begin
            ball_on = 1;
            ball_rgb = BALL_COLOR;
        end else begin
            ball_on = 0;
            ball_rgb = 12'h000;
        end
    end

endmodule
