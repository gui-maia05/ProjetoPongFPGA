module PixelGen(
    input wire clk, rstn,
    input wire video_on, p_tick,
    input wire right_k, left_k,
    input wire [9:0] pixel_x, pixel_y,
    output reg [3:0] r, g, b
);

    localparam BACKGROUND_COLOR = 12'h000;

    reg [3:0] r_reg, g_reg, b_reg;
    wire [11:0] paddle_rgb, ball_rgb, wall_rgb;
    wire paddle_on, ball_on, wall_on;
    wire refr_tick;

    // refr_tick: 1-clock tick asserted at start of v-sync
    assign refr_tick = (pixel_y == 481) && (pixel_x == 0);
    
    // Instanciar o módulo Wall
    Wall wall (
        .clk(clk),
        .rstn(rstn),
        .pixel_x(pixel_x),
        .pixel_y(pixel_y),
        .wall_on(wall_on),
        .wall_rgb(wall_rgb)
    );
    
    // Instanciar o módulo Paddle
    Paddle paddle (
        .clk(clk), 
        .rstn(rstn), 
        .refr_tick(refr_tick),
        .turn_r(right_k), 
        .turn_l(left_k),
        .y(pixel_y), 
        .x(pixel_x),
		  .wall_on(wall_on), 
        .paddle_rgb(paddle_rgb),
        .paddle_on(paddle_on)
    );
    
    // Instanciar o módulo Ball
    Ball ball (
        .clk(clk),
        .rstn(rstn),
        .refr_tick(refr_tick),
        .paddle_on(paddle_on),
		  .wall_on(wall_on),
        .pixel_x(pixel_x),   
        .pixel_y(pixel_y),   
        .ball_rgb(ball_rgb),
        .ball_on(ball_on)
    );
    
    // Definir as cores
    always@* begin
        if (~video_on)
            {r, g, b} = 12'h000;  // Fundo preto
        else if (wall_on)
            {r, g, b} = wall_rgb;  // Cor da parede
        else if (ball_on)
            {r, g, b} = ball_rgb;  // Cor da bola
        else if (paddle_on)
            {r, g, b} = paddle_rgb;  // Cor do paddle
        else
            {r, g, b} = BACKGROUND_COLOR;  // Cor de fundo
    end

endmodule