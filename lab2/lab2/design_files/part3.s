/* Program that counts consecutive 1's */

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
            BEQ     END

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
END:        B       END  

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

// Loop to find longest string of 1's
// Parameter is in R1
// Count result is in R0
LOOP:       CMP     R1, #0          // loop until the data contains no more 1's
            MOVEQ   PC, LR          // subroutine return   
            LSR     R2, R1, #1      // perform SHIFT, followed by AND
            AND     R1, R1, R2     
            ADD     R0, #1          // count the string length so far
            B       LOOP
            
PARAM:      .word   0xaaaaaaaa

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
            .word   0x10660000
            .word   0x0

            .end                            