/* Lab 3 Part III
 *    Assume initial behavior: as soon as program is started, counter counts and displays from 0 to 99.
 *    After first key press, program pauses.
 */
            .text
            .global _start
_start:
		    MOV     sp, #0x20000
            LDR		R5, =0xFF200000     // For HEX and KEY addresses
            LDR     R8, =0xFFFEC600     // For timer
            LDR     R7, =50000000
            STR     R7, [R8]
            MOV     R7, #0b011          // Starts timer
            STR     R7, [R8, #0x8]

MAIN:	    MOV		R0, #0

// display R0 on HEX1-0
DISPLAY:    MOV     R1, #10             
            BL      DIVIDE              // tens digit in R1, ones digit in R2
            MOV     R9, R1              // save the tens digit
            BL      SEG7_CODE           
            MOV     R4, R1              // save bit code            (-> 000000xx)
            MOV     R2, R9              // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R1, #8              // Shift left by 2 bytes    (-> 0000xx00)
            ORR     R4, R1              // Combine bit code

            STR     R4, [R5, #0x20]     // Display the number on HEX1-0

    	    LDR		R6, [R5, #0x5C]     // Stopping condition
		    CMP		R6, #0
		    BEQ		DELAY

            STR		R6, [R5, #0x5C]     // Reset edgecapture to wait for next press
WAIT:       LDR		R6, [R5, #0x5C]     // Continuing condition
            CMP     R6, #0
            MOVEQ   R7, #0b010          // Stops timer
            STREQ   R7, [R8, #0x8]
            BEQ     WAIT

            STR		R6, [R5, #0x5C]     // Reset edgecapture
            MOV     R7, #0b011          // Starts timer again
            STR     R7, [R8, #0x8]

// Delay, add, and continue   
DELAY:	    LDR     R7, [R8, #0xc]      // Checks value from timer
            CMP     R7, #0
            BEQ     DELAY
            STR     R7, [R8, #0xc]      // Resets timer flag for next counts
            // After delay
            CMP     R0, #99
            BEQ		MAIN

            ADD 	R0, #1
            B		DISPLAY

/* Subroutine to perform the integer division R0 / R1.
 *    Parameters: R0 = Dividend, R1 = Divisor
 *    Returns: quotient in R1 (tens), and remainder in R2 (digits)
 */
DIVIDE: 	PUSH   {R3}
            MOV    R3, #0
            MOV    R2, R0
CONT:       CMP    R2, R1
            BLT    DIV_END
            SUB    R2, R1
            ADD    R3, #1
            B      CONT
DIV_END:    MOV    R1, R3
            POP    {R3}
            MOV    PC, LR

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R2 = the decimal value of the digit to be displayed
 *    Returns: R1 = bit pattern to be written to the HEX display
 */
SEG7_CODE:  PUSH    {R3}
            MOV     R3, #BIT_CODES  
            ADD     R3, R2         // index into the BIT_CODES "array"
            LDRB    R1, [R3]       // load the bit pattern (to be returned)
            POP     {R3}
            MOV     PC, LR

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

.end