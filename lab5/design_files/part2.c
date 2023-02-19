/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

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
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

// global variable
volatile int pixel_buffer_start;        // Buffer

// Function declarations
void clear_screen();
void swap(int* a, int* b);
void draw_line(int x0, int y0, int x1, int y1, short int color);
void plot_pixel(int x, int y, short int line_color);
void wait_for_vsync();

// Main program
int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    /* current y*/
    int y = 0;
    bool falling = true;
    
    /* Before iteration */
    clear_screen();
    draw_line(0, y, RESOLUTION_X, y, CYAN);
    wait_for_vsync();

    while (1){
        draw_line(0, y, RESOLUTION_X, y, 0);            // Draw black to previous line

        // Calulate new line
        if (falling){
            if (y == RESOLUTION_Y) falling = false;
            else y++;
        } else {
            if (y == 0) falling = true;
            else y--;
        }
        
        draw_line(0, y, RESOLUTION_X, y, CYAN);         // Draw new line
        wait_for_vsync();                               // Wait
    }
}

// Helper functions 
void clear_screen(){
    for (int x = 0; x < RESOLUTION_X; x++){
        for (int y = 0; y < RESOLUTION_Y; y++){
            plot_pixel(x, y, 0);
        }
    }
}

void draw_line(int x0, int y0, int x1, int y1, short int color){
    for (int x = x0; x <= x1; x++){
        plot_pixel(x, y0, color);
    }
}

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

void wait_for_vsync(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    register int status;

    *pixel_ctrl_ptr = 1;

    status = *(pixel_ctrl_ptr + 3);
    while ((status & 0x01) != 0){
        status = *(pixel_ctrl_ptr + 3);
    }
}