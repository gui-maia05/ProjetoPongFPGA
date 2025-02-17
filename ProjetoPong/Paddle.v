module Paddle (
    input wire clk, rstn, 
    input wire refr_tick,
    input wire turn_r, turn_l,
    input wire [9:0] x, y,
    input wire wall_on,        // Entrada para verificar a colisão com a parede
    output wire [11:0] paddle_rgb,
    output wire paddle_on
	 
);
    // x, y coordinates (0,0) to (639,479)
    localparam MAX_X = 640;
    localparam MAX_Y = 480;
    
    // paddle attributes
    localparam PADDLE_WIDTH = 10;   // Largura da barra
    localparam PADDLE_HEIGHT = 100; // Altura da barra
    localparam PADDLE_X = 620;      // Posição inicial X
    localparam PADDLE_Y = 190;      // Posição inicial Y
    localparam PADDLE_COLOR = 12'hF0F;
    localparam PADDLE_STEP = 2;     // Quantos pixels a barra move a cada atualização
    
    integer x_count;
    integer y_count;
    
    wire x_updown, x_en, y_updown, y_en;
    
    assign paddle_rgb = PADDLE_COLOR;
    assign paddle_on = (x_count < x) && (x < x_count + PADDLE_WIDTH) && (y_count < y) && (y < y_count + PADDLE_HEIGHT);
    
    // Controle do movimento horizontal (sem limitação, barra fixa)
    always @(posedge clk, negedge rstn)
    begin
        if(rstn == 0)
            x_count <= PADDLE_X;  // A barra está fixa na posição X
    end
    
    // Controle do movimento vertical com verificação de colisão com a parede (wall_on)
    always @(posedge clk, negedge rstn)
    begin
        if(rstn == 0)
            y_count <= PADDLE_Y;  // Posição inicial Y
        else if(y_en == 1 && refr_tick == 1'b1)
            begin
                // Verificação de colisão com a parede (wall_on) e a barra (paddle_on)
                if (wall_on && y_updown == 1 && (y_count + PADDLE_HEIGHT <= MAX_Y - PADDLE_STEP)) begin
                    // Impede que a barra ultrapasse o limite inferior da parede (wall)
                    y_count <= (y_count < MAX_Y - PADDLE_HEIGHT - PADDLE_STEP) ? y_count + PADDLE_STEP : MAX_Y - PADDLE_HEIGHT;
                end
                // Verificação de colisão com a parede superior (limite da tela)
                else if (wall_on && y_updown == 0 && (y_count > 0)) begin
                    // Impede que a barra ultrapasse a borda superior
                    y_count <= (y_count > PADDLE_STEP) ? y_count - PADDLE_STEP : 0;
                end
                // Verificação se a barra e a parede estão na mesma posição (paddle_on e wall_on)
                else if (wall_on && paddle_on) begin
                    // Impede o movimento da barra se ambos estiverem na mesma posição
                    // A barra não se moverá se estiver na mesma posição da parede
                    y_count <= y_count;  // A barra não se move
                end
                // Caso contrário, mova a barra livremente
                else if(y_updown == 1) // Movendo para baixo
                    y_count <= (y_count < MAX_Y - PADDLE_HEIGHT - PADDLE_STEP) ? y_count + PADDLE_STEP : MAX_Y - PADDLE_HEIGHT; // Limite inferior
                else if(y_updown == 0) // Movendo para cima
                    y_count <= (y_count > PADDLE_STEP) ? y_count - PADDLE_STEP : 0; // Limite superior
            end
    end
    
    // Máquina de estados para controlar a direção do movimento
    DirectionController (
        .clk(clk), 
        .rstn(rstn), 
        .turn_right(turn_r), 
        .turn_left(turn_l), 
        .data_out({y_updown, y_en, x_updown, x_en})
    );
endmodule
