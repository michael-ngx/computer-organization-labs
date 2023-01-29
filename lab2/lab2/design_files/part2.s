/* Program that counts consecutive 1's */

            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #TEST_NUM   // R4 points to start of list
            MOV     R5, #0          // Largest number of 1's so far
            
MAIN_LOOP:  LDR     R1, [R4], #4    // Gets data to R1. Move pointer to next data
            CMP     R1, #0          // Finishes when reaches last element in list
            BEQ     END
            BL      ONES            // Calculate consecutive 1's of current number (in R1)
            CMP     R5, R0          
            MOVLT   R5, R0          // Update if needed
            B       MAIN_LOOP

END:        B       END  

// Find longest string of 1's
// Parameter is in R1
// Result is in R0
ONES:       MOV     R0, #0          // R0 will hold the result

LOOP:       CMP     R1, #0          // loop until the data contains no more 1's
            BEQ     END_SUB         // escape from loop  
            LSR     R2, R1, #1      // perform SHIFT, followed by AND
            AND     R1, R1, R2     
            ADD     R0, #1          // count the string length so far
            B       LOOP

END_SUB:    MOV     PC, LR          // subroutine return                        

TEST_NUM:   .word   0x103fe00f  
            .word   0xf7400878
            .word   0x9957a585
            .word   0x8a37275f
            .word   0x8bd4b238
            .word   0x39591b6a
            .word   0xd5cdde8d
            .word   0xb69dd920
            .word   0x10cde002
            .word   0xf0ff4ff3
            .word   0x1066ffff
            .word   0x0

            .end                            
