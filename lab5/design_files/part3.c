/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000

/* Cyclone V FPGA devices */
#define PIXEL_BUF_CTRL_BASE   0xFF203020

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define NUM_BOXES 8

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <time.h>

// Begin part3.c code for Lab 7

// global variable
volatile int pixel_buffer_start;
int x_box[NUM_BOXES];
int y_box[NUM_BOXES];
int last_x[NUM_BOXES];
int last_y[NUM_BOXES];
int last_last_x[NUM_BOXES];         // We need last last because the buffers are swapped
int last_last_y[NUM_BOXES];
int dx_box[NUM_BOXES];
int dy_box[NUM_BOXES];
short int color[] = {WHITE, YELLOW, RED, GREEN, BLUE, CYAN, MAGENTA, GREY, PINK, ORANGE};
short int color_box[NUM_BOXES];
short int color_line[NUM_BOXES];

// Function declarations
void clear_screen();
void swap(int* a, int* b);
void draw_line(int x0, int y0, int x1, int y1, short int color);
void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();

/* **************************************************************************************************************/
/* MAIN */
/* **************************************************************************************************************/

int main(void)
{
    srand(time(NULL));
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    
    // initialize location and direction of rectangles with random integers
    for (int i = 0; i < NUM_BOXES; i++){
        x_box[i] = rand() % (RESOLUTION_X - 1);
        y_box[i] = rand() % (RESOLUTION_Y - 1);
        last_x[i] = x_box[i];
        last_y[i] = y_box[i];
        last_last_x[i] = x_box[i];
        last_last_y[i] = y_box[i];
        dx_box[i] = rand() % 2 * 2 - 1;
        dy_box[i] = rand() % 2 * 2 - 1;
    }

    // initialize box and line colors with random colors
    for (int j = 0; j < sizeof(color)/sizeof(color[0]); j++){
        color_box[j] = color[rand() % NUM_BOXES];
        color_line[j] = color[rand() % NUM_BOXES];
    }

    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen(); // pixel_buffer_start points to the pixel buffer
    
    while (1)
    {
        for (int i = 0; i < NUM_BOXES; i++){
            /* Erase any boxes and lines that were drawn in the last iteration */
            plot_pixel(last_last_x[i],     last_last_y[i],     0);
            plot_pixel(last_last_x[i] + 1, last_last_y[i],     0);
            plot_pixel(last_last_x[i],     last_last_y[i] + 1, 0);
            plot_pixel(last_last_x[i] + 1, last_last_y[i] + 1, 0);
            draw_line(last_last_x[i], last_last_y[i], last_last_x[(i + 1) % NUM_BOXES], last_last_y[(i + 1) % NUM_BOXES], 0);
        
            // code for drawing the boxes and lines
            plot_pixel(x_box[i],     y_box[i],     color_box[i]);
            plot_pixel(x_box[i] + 1, y_box[i],     color_box[i]);
            plot_pixel(x_box[i],     y_box[i] + 1, color_box[i]);
            plot_pixel(x_box[i] + 1, y_box[i] + 1, color_box[i]);
            draw_line(x_box[i], y_box[i], x_box[(i + 1) % NUM_BOXES], y_box[(i + 1) % NUM_BOXES], color_line[i]);
        
            // code for updating the locations of boxes
            if ((dx_box[i] == 1 && x_box[i] == RESOLUTION_X - 2) || (dx_box[i] == -1 && x_box[i] == 0)){
                dx_box[i] = -dx_box[i];
            } 
            if ((dy_box[i] == 1 && y_box[i] == RESOLUTION_Y - 2) || (dy_box[i] == -1 && y_box[i] == 0)){
                dy_box[i] = -dy_box[i];
            }
            last_last_x[i] = last_x[i];
            last_last_y[i] = last_y[i];
            last_x[i] = x_box[i];
            last_y[i] = y_box[i];
            x_box[i] += dx_box[i];
            y_box[i] += dy_box[i];
        }

        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

/* **************************************************************************************************************/
/* SUBROUTINES */
/* **************************************************************************************************************/

void wait_for_vsync(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    register int status;

    *pixel_ctrl_ptr = 1;

    status = *(pixel_ctrl_ptr + 3);
    while ((status & 0x01) != 0){
        status = *(pixel_ctrl_ptr + 3);
    }
}

void clear_screen(){
    for (int x = 0; x < RESOLUTION_X; x++){
        for (int y = 0; y < RESOLUTION_Y; y++){
            plot_pixel(x, y, 0);
        }
    }
}

void swap(int* a, int* b){
    int c = *a;
    *a = *b;
    *b = c;
}

void draw_line(int x0, int y0, int x1, int y1, short int color){
    bool is_steep = ABS(y1 - y0) > ABS(x1 - x0);
    // If the line is steep --> (deltay >> deltax) --> (error always > 0) --> wrong
    if (is_steep){
        swap(&x0, &y0);
        swap(&x1, &y1);
    }
    if (x0 > x1){
        swap(&x0, &x1);
        swap(&y0, &y1);
    }
    int deltax = x1 - x0;
    int deltay = ABS(y1 - y0);
    int error = -(deltax / 2);
    int y = y0;
    int y_step;
    if (y0 < y1) y_step = 1;
    else y_step = -1;

    for (int x = x0; x <= x1; x++){
        if (is_steep) plot_pixel(y, x, color);
        else plot_pixel(x, y, color);
        error += deltay;
        if (error > 0){
            y += y_step;
            error -= deltax;
        }
    }
}

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}
