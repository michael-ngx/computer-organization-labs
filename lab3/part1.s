/* Lab 3 Part I
 *    
 *    
 */
                .text
                .global _start
_start:
                MOV     sp, #0x20000        // Initialize sp
                LDR		R8, =0xFF200050     // R8 holds address of KEYs
                LDR     R9, =0xFF200020     // R9 holds address of HEX3-0

BLANK:          LDR     R5, [R8]            // R5 <- KEYs
                CMP     R5, #0
                BEQ     BLANK               // Keep waiting if no keys pressed
                // Pressed any keys when display is blank
                BL      ZERO

MAIN_LOOP:      LDR     R5, [R8]            // R5 <- KEYs
                // No keys pressed
                CMP     R5, #0
                BEQ     MAIN_LOOP           
                // KEY0
                CMP     R5, #1
                BLEQ    ZERO
                // KEY1
                CMP     R5, #2
                BLEQ    ADD
                // KEY2
                CMP     R5, #4
                BLEQ    SUB
                // KEY3
                CMP     R5, #8
                BEQ     CLEAR

                B       MAIN_LOOP

ZERO:           PUSH    {LR}
                BL      NOT_RELEASED        // Wait until KEYs are released
                MOV     R0, #0              // R0 <- 0
                BL      SEG7_CODE           // Get display bit code of R0 to R1
                STRB    R1, [R9]            // Displays R0                  ////////// Device warning - no store bits
                POP     {LR}
                MOV     PC, LR

ADD:            PUSH    {LR}
                BL      NOT_RELEASED        // Wait until KEYs are released
                CMP     R0, #9
                BEQ     OVER
                ADD     R0, #1              // If R0 < 9, R0++
                BL      SEG7_CODE           // Get display bit code of R0 to R1
                STRB    R1, [R9]            // Displays R0                  ////////// Device warning - no store bits
OVER:           POP     {LR}
                MOV     PC, LR

SUB:            PUSH    {LR}
                BL      NOT_RELEASED        // Wait until KEYs are released
                CMP     R0, #0
                BEQ     UNDER
                SUB     R0, #1              // If R0 > 0, R0--
                BL      SEG7_CODE           // Get display bit code of R0 to R1
                STRB    R1, [R9]            // Displays R0                  ////////// Device warning - no store bits
UNDER:          POP     {LR}
                MOV     PC, LR

CLEAR:          BL      NOT_RELEASED        // Wait until KEYs are released
                MOV     R1, #0
                STRB    R1, [R9]            // Clear display
                B       BLANK               // Go back to the begining wait state

NOT_RELEASED:   LDR     R3, [R8]
                CMP     R3, #0
                BNE     NOT_RELEASED        // Keep waiting if the key is not released
                MOV     PC, LR

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R1 = bit pattern to be written to the HEX display
 */
SEG7_CODE:      MOV     R2, #BIT_CODES  
                ADD     R2, R0         // index into the BIT_CODES "array"
                LDRB    R1, [R2]       // load the bit pattern (to be returned)
                MOV     PC, LR

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

.end