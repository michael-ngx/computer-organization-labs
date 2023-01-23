/* Program that converts a binary number to decimal */
           
           .text               // executable code follows
           .global _start
_start:
            MOV    R4, #N
            MOV    R5, #Digits  // R5 points to the decimal digits storage location
            LDR    R4, [R4]     // R4 holds N
            MOV    R1, R4       
BRUH:		MOV	   R0, R1		// DIVIDEND goes in R0
			MOV    R1, #10		// DIVISOR goes in R1
            BL     DIVIDE
            STRB   R0, [R5]  	// Store digit collected from DIVIDE
			ADD	   R5, #1
			CMP    R1, #0
			BGT	   BRUH			// Keep dividing until R1 = 0
END:        B      END

/* Subroutine to perform the integer division R0 / R1.
 * Returns: quotient in R1, and remainder in R0 */
 
DIVIDE: 	MOV    R2, #0
CONT:       CMP    R0, R1
            BLT    DIV_END
            SUB    R0, R1
            ADD    R2, #1
            B      CONT
DIV_END:    MOV    R1, R2     // quotient in R1 (remainder in R0)
            MOV    PC, LR

N:          .word  9998       // the decimal number to be converted
Digits:     .space 4          // storage space for the decimal digits

            .end
