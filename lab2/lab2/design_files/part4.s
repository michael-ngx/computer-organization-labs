/* Part III */
/* Program that counts consecutive 1's, stored in R5, consecutive 0's, stored in R6, alternating 0's 1's, stored in R7 */

            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #TEST_NUM   // R4 points to start of list
            MOV     R5, #0          // Largest number of 1's so far
            MOV     R6, #0          // Largest number of 0's so far
            MOV     R7, #0          // Largest number of alternate 01 so far
            
MAIN_LOOP:  
            LDR     R1, [R4]        // Gets data to R1
            CMP     R1, #0          // Finishes when reaches last element in list
            BEQ     END_PART3

            // Find longest string of 1's
            BL      ONES
            CMP     R5, R0          
            MOVLT   R5, R0          // Update if needed

            // Find longest string of 0's
            LDR     R1, [R4]        // Reload R1 (due to shifting) 
            BL      ZEROS
            CMP     R6, R0          
            MOVLT   R6, R0          // Update if needed

            // Find longest string of alternating 1's and 0's
            LDR     R1, [R4]        // Reload R1 (due to shifting)
            MOV     SP, #0x20000    // Initialize sp
            BL      ALTERNATE
            CMP     R7, R0          
            MOVLT   R7, R0          // Update if needed

            ADD     R4, #4          // Next data
            B       MAIN_LOOP
END_PART3:  B       DISPLAY  

ONES:       MOV     R0, #0
            B       LOOP

ZEROS:      MVN     R1, R1          // Perform NOT R1
            B       ONES

ALTERNATE:  MOV     R2, #PARAM      // R2 <- 0xaaaaaaaa
            LDR     R2, [R2]
            EOR     R1, R2          // R1 <- R1 XOR 0xaaaaaaaa
            PUSH    {R1, LR}        // Store LR to go back to MAIN
            BL      ONES            // Number of consecutive 1's
            POP     {R1}
            MOV     R8, R0
            BL      ZEROS           // Number of consecutive 0's
            CMP     R0, R8          
            MOVLT   R0, R8          // Longest string of alternating = MAX(ONES, ZEROS)
            POP     {LR}            // POP LR to go back to MAIN
            MOV     PC, LR          // return to MAIN

// Loop to find longest string of 1's. 
LOOP:       CMP     R1, #0          // loop until the data contains no more 1's
            MOVEQ   PC, LR          // subroutine return   
            LSR     R2, R1, #1      // perform SHIFT, followed by AND
            AND     R1, R1, R2     
            ADD     R0, #1          // count the string length so far
            B       LOOP
            
PARAM:      .word   0xaaaaaaaa

TEST_NUM:   .word   0x103fe00f, 0xf7400878, 0x9957a585, 0x8a37275f, 0x8bd4b238, 0x39591b6a
            .word   0xd5cdde8d, 0xb69dd920, 0x10cde002, 0xf0ff4ff3, 0x10660000, 0x0

/* Part IV
 * Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4
 * 
 */
DISPLAY:    
            LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            // code for R5
            MOV     R0, R5          // display R5 on HEX1-0
            MOV     R1, #10
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code            (-> 000000xx)
            MOV     R0, R9          // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R0, #8          // Shift left by 2 bytes    (-> 0000xx00)
            ORR     R4, R0          // combine bit code
            
            // code for R6
            MOV     R0, R6          // display R6 on HEX3-2
            MOV     R1, #10
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            LSL     R0, #16         // Shift left by 2 bytes    (-> 00xx0000)
            ORR     R4, R0          // combine bit code
            MOV     R0, R9          // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R0, #24         // Shift left by 3 bytes    (-> xx000000)
            ORR     R4, R0          // combine bit code

            STR     R4, [R8]        // display the numbers from R6 and R5
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4
            
            // code for R7
            MOV     R0, R7          // display R5 on HEX1-0
            MOV     R1, #10
            BL      DIVIDE          // ones digit will be in R0; tens
                                    // digit in R1
            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code            (-> 000000xx)
            MOV     R0, R9          // retrieve the tens digit, get bit code
            BL      SEG7_CODE       
            LSL     R0, #8          // Shift left by 2 bytes    (-> 0000xx00)
            ORR     R4, R0          // combine bit code

            STR     R4, [R8]        // display the number from R7

END:        B       END

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit pattern to be written to the HEX display
 */
SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

/* Subroutine to perform the integer division R0 / R1.
 *    Parameters: R0 = Dividend, R1 = Divisor
 *    Returns: quotient in R1, and remainder in R0 
 */
DIVIDE: 	MOV    R2, #0
CONT:       CMP    R0, R1
            BLT    DIV_END
            SUB    R0, R1
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2
            MOV    PC, LR

            .end
        