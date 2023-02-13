               .equ      EDGE_TRIGGERED,    0x1
               .equ      LEVEL_SENSITIVE,   0x0
               .equ      CPU0,              0x01    // bit-mask; bit 0 represents cpu0
               .equ      ENABLE,            0x1

               .equ      KEY0,              0b0001
               .equ      KEY1,              0b0010
               .equ      KEY2,              0b0100
               .equ      KEY3,              0b1000

               .equ      IRQ_MODE,          0b10010
               .equ      SVC_MODE,          0b10011

               .equ      INT_ENABLE,        0b01000000
               .equ      INT_DISABLE,       0b11000000

/*********************************************************************************
 * Initialize the exception vector table
 ********************************************************************************/
                .section .vectors, "ax"

                B        _start             // reset vector
                .word    0                  // undefined instruction vector
                .word    0                  // software interrrupt vector
                .word    0                  // aborted prefetch vector
                .word    0                  // aborted data vector
                .word    0                  // unused vector
                B        IRQ_HANDLER        // IRQ interrupt vector
                .word    0                  // FIQ interrupt vector

/* ********************************************************************************
 * This program demonstrates use of interrupts with assembly code. The program 
 * responds to interrupts from a timer and the pushbutton KEYs in the FPGA.
 *
 * The interrupt service routine for the timer increments a counter that is shown
 * on the red lights LEDR by the main program. The counter can be stopped/run by 
 * pressing any of the KEYs.
 ********************************************************************************/
                .text
                .global  _start
_start:        
                /* Set up stack pointers for IRQ and SVC processor modes */

                MOV      R0, #IRQ_MODE
                MSR      CPSR, R0
                LDR      sp, =0x40000
                MOV      R0, #SVC_MODE
                /* Enable IRQ interrupts in the ARM processor */                  
                ADD      R0, #INT_ENABLE
                MSR      CPSR, R0
                LDR      sp, =0x20000
                
                BL       CONFIG_GIC         // configure the ARM generic interrupt controller

                BL       CONFIG_PRIV_TIMER  // configure the timer
                BL       CONFIG_TIMER       // configure the FPGA interval timer
                BL       CONFIG_KEYS        // configure the pushbutton KEYs

                LDR      R5, =0xFF200000    // LEDR base address
                LDR      R6, =0xFF200020    // HEX3-0 base address
LOOP:
                LDR      R3, COUNT          // global variable
                STR      R3, [R5]           // light up the red lights
                LDR      R4, HEX_code       // global variable
                STR      R4, [R6]           // show the time in format SS:DD

                B        LOOP                            

/* Global variables */
                .global  COUNT
COUNT:          .word    0x0                // used by timer
                .global  RUN
RUN:            .word    0x1                // initial value to increment COUNT
                .global  TIME_SEC
TIME_SEC:       .word    0x0                // used for real-time clock (seconds)
                .global  TIME_HUNDRETH
TIME_HUNDRETH:   .word   0x0                // used for real-time clock (hundreds)
                .global  HEX_code
HEX_code:       .word    0x0

/* Configure the A9 Private Timer to create interrupts every 0.25 seconds */
CONFIG_PRIV_TIMER:
                LDR      R0, =0xFFFEC600         // R0 <- Address of Timer
                LDR      R1, =50000000          
                STR      R1, [R0]                // Load value for timer (0.25s)
                MOV      R1, #1                  // R1 <- 1
                STR      R1, [R0, #0xC]          // Avoid going straight to interrupt 
                MOV      R1, #0b111              // R1 <- ...111
                STR      R1, [R0, #0x8]          // Enable interrupt, Enable reload, Starts timer
                
                MOV      PC, LR
                   
/* Configure the FPGA interval timer to create interrupts at 0.01 second intervals */
CONFIG_TIMER:
                LDR      R0, =0xFF202000         // R0 <- Address of Interval Timer
                
                LDR      R1, =0x4240                     
                STR      R1, [R0, #8]           
                LDR      R1, =0xF                     
                STR      R1, [R0, #0xC]          // Load value for timer (0.01s)
                
                MOV      R1, #0b111             // R1 <- ...111
                STR      R1, [R0, #0x4]          // Starts timer, Enable reload, Enable interrupt
                MOV      PC, LR

/* Configure the pushbutton KEYS to generate interrupts */
CONFIG_KEYS:
                LDR      R0, =0xFF200058         // R0 <- Address of KEY Interupt Mask
                MOV      R1, #0b1111             // R1 <- ...1111 
                STR      R1, [R0]                // Enable KEY Interupt Mask
                MOV      PC, LR

/*--- IRQ ---------------------------------------------------------------------*/
IRQ_HANDLER:
                PUSH     {R0-R7, LR}
    
                /* Read the ICCIAR in the CPU interface */
                LDR      R4, =0xFFFEC100
                LDR      R5, [R4, #0x0C]         // read the interrupt ID

                /* Check which device caused interrupt and act accordingly */
                CMP      R5, #72
                BLEQ     TIMER_ISR
                CMP      R5, #29
                BLEQ     PRIV_TIMER_ISR
                CMP      R5, #73
                BLEQ     KEY_ISR

EXIT_IRQ:
                /* Write to the End of Interrupt Register (ICCEOIR) */
                STR      R5, [R4, #0x10]
    
                POP      {R0-R7, LR}
                SUBS     PC, LR, #4

/****************************************************************************************
 * Pushbutton - Interrupt Service Routine                                
 *                                                                          
 * This routine toggles the RUN global variable.
 ***************************************************************************************/
                .global  KEY_ISR
KEY_ISR:        
                PUSH     {LR}
                LDR      R0, =0xFF200050        // R0 holds address of KEY
                LDR      R1, [R0, #0x0C]        // R1 <- KEY Edgecapture
                
                // Check which KEY was pressed
                // and act accordingly
                CMP      R1, #KEY0
                BLEQ     ZERO
                CMP      R1, #KEY1
                BLEQ     ONE
                CMP      R1, #KEY2
                BLEQ     TWO
                CMP      R1, #KEY3
                BLEQ     THREE

                STR      R1, [R0, #0x0C]        // Reset KEY Edgecapture
                POP      {LR}
                MOV      PC, LR

ZERO:           // Toggle RUN between 0/1
                LDR      R2, RUN
                CMP      R2, #0
                MOVEQ    R2, #1
                MOVNE    R2, #0
                STR      R2, RUN
                MOV      PC, LR

ONE:            
                LDR      R2, =0xFFFEC600
                MOV      R3, #0b010          
                STR      R3, [R2, #0x8]     // Disable interrupt value, stops timer

                LDR      R3, [R2]
                LSR      R3, #2             // R3 / 2
                STR      R3, [R2]           // Double the speed of timer

                MOV      R3, #0b111
                STR      R3, [R2, #0x8]     // Restart timer

                MOV      PC, LR

TWO:            
                LDR      R2, =0xFFFEC600
                MOV      R3, #0b010          
                STR      R3, [R2, #0x8]     // Disable interrupt value, stops timer

                LDR      R3, [R2]
                LSL      R3, #1             // R3 x 2
                STR      R3, [R2]           // Halve the speed of timer

                MOV      R3, #0b111
                STR      R3, [R2, #0x8]     // Restart timer
                MOV      PC, LR

THREE:          LDR      R2, =0xFF202000    // Interval Timer address
                LDR      R3, [R2, #4]       // Read Interval timer
                
                CMP      R3, #0b1010
                MOVEQ    R3, #0b0111        // Restart timer if stopped
                MOVNE    R3, #0b1010        // Stop timer if running

                STR      R3, [R2, #4]       // Start/Stop Interval timer
                MOV      PC, LR

/******************************************************************************
 * A9 Private Timer interrupt service routine
 *                                                                          
 * This code toggles performs the operation COUNT = COUNT + RUN
 *****************************************************************************/
                .global  PRIV_TIMER_ISR
PRIV_TIMER_ISR:
                LDR      R0, =0xFFFEC60C
                MOV      R1, #1
                STR      R1, [R0]         // Resets timer interrupt status  
      
                LDR      R0, COUNT        // R0 <- COUNT
                LDR      R1, RUN          // R1 <- RUN
                
                ADD      R0, R1           // R0 <- R0 + R1
                STR      R0, COUNT        // R0 -> COUNT 
                MOV      PC, LR

/******************************************************************************
 * Interval timer interrupt service routine
 *                                                                          
 * This code performs the operation ++TIME, and produces HEX_code
 *****************************************************************************/
                .global  TIMER_ISR
TIMER_ISR:
                PUSH     {R0-R10, LR}
                LDR      R0, TIME_HUNDRETH
                LDR      R10, TIME_SEC

                // Compute and send hex code
                // Display R0
                MOV      R1, #10             
                BL       DIVIDE              // tens digit in R1, ones digit in R2
                MOV      R9, R1              // save the tens digit
                BL       SEG7_CODE           // Get bit code (R2 -> R1)
                MOV      R4, R1              // save bit code            (-> 000000xx)
                MOV      R2, R9              // retrieve the tens digit
                BL       SEG7_CODE           // Get bit code (R2 -> R1)
                LSL      R1, #8              // Shift left by 2 bytes    (-> 0000xx00)
                ORR      R4, R1              // Combine bit code
                // Display R10
                PUSH     {R0}
                MOV      R0, R10
                MOV      R1, #10             
                BL       DIVIDE              // tens digit in R1, ones digit in R2
                MOV      R9, R1              // save the tens digit
                BL       SEG7_CODE           // Get bit code (R2 -> R1)
                LSL      R1, #16             // Shift left by 3 bytes    (-> 00xx0000)           
                ORR      R4, R1              // Combine bit code
                MOV      R2, R9              // retrieve the tens digit
                BL       SEG7_CODE           // Get bit code (R2 -> R1)
                LSL      R1, #24             // Shift left by 4 bytes    (-> xx000000)
                ORR      R4, R1              // Combine bit code
                POP      {R0}

                STR      R4, HEX_code         // Send hexcode to HEX_code

                // Increment TIME_HUNDRETH or TIME_SEC
                CMP      R0, #99
                ADDNE    R0, #1
                BNE      END_TIMER

                CMP      R10, #59
                ADDNE    R10, #1
                MOVEQ    R10, #0
                MOV      R0, #0
                
END_TIMER:      STR      R0, TIME_HUNDRETH
                STR      R10, TIME_SEC
                // Restart timer interrupt status
                LDR      R0, =0xFF202000
                MOV      R1, #1
                STR      R1, [R0]

                POP      {R0-R10, LR}
                MOV      PC, LR

/* 
 * Configure the Generic Interrupt Controller (GIC)
*/
                .global  CONFIG_GIC
CONFIG_GIC:
                PUSH     {LR}
                /* Enable A9 Private Timer interrupts */
                MOV      R0, #29
                MOV      R1, #CPU0
                BL       CONFIG_INTERRUPT
                
                /* Enable FPGA Timer interrupts */
                MOV      R0, #72
                MOV      R1, #CPU0
                BL       CONFIG_INTERRUPT

                /* Enable KEYs interrupts */
                MOV      R0, #73
                MOV      R1, #CPU0
                /* CONFIG_INTERRUPT (int_ID (R0), CPU_target (R1)); */
                BL       CONFIG_INTERRUPT

                /* configure the GIC CPU interface */
                LDR      R0, =0xFFFEC100        // base address of CPU interface
                /* Set Interrupt Priority Mask Register (ICCPMR) */
                LDR      R1, =0xFFFF            // enable interrupts of all priorities levels
                STR      R1, [R0, #0x04]
                /* Set the enable bit in the CPU Interface Control Register (ICCICR). This bit
                 * allows interrupts to be forwarded to the CPU(s) */
                MOV      R1, #1
                STR      R1, [R0]
    
                /* Set the enable bit in the Distributor Control Register (ICDDCR). This bit
                 * allows the distributor to forward interrupts to the CPU interface(s) */
                LDR      R0, =0xFFFED000
                STR      R1, [R0]    
    
                POP      {PC}
/* 
 * Configure registers in the GIC for an individual interrupt ID
 * We configure only the Interrupt Set Enable Registers (ICDISERn) and Interrupt 
 * Processor Target Registers (ICDIPTRn). The default (reset) values are used for 
 * other registers in the GIC
 * Arguments: R0 = interrupt ID, N
 *            R1 = CPU target
*/
CONFIG_INTERRUPT:
                PUSH     {R4-R5, LR}
    
                /* Configure Interrupt Set-Enable Registers (ICDISERn). 
                 * reg_offset = (integer_div(N / 32) * 4
                 * value = 1 << (N mod 32) */
                LSR      R4, R0, #3               // calculate reg_offset
                BIC      R4, R4, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED100
                ADD      R4, R2, R4               // R4 = address of ICDISER
    
                AND      R2, R0, #0x1F            // N mod 32
                MOV      R5, #1                   // enable
                LSL      R2, R5, R2               // R2 = value

                /* now that we have the register address (R4) and value (R2), we need to set the
                 * correct bit in the GIC register */
                LDR      R3, [R4]                 // read current register value
                ORR      R3, R3, R2               // set the enable bit
                STR      R3, [R4]                 // store the new register value

                /* Configure Interrupt Processor Targets Register (ICDIPTRn)
                  * reg_offset = integer_div(N / 4) * 4
                  * index = N mod 4 */
                BIC      R4, R0, #3               // R4 = reg_offset
                LDR      R2, =0xFFFED800
                ADD      R4, R2, R4               // R4 = word address of ICDIPTR
                AND      R2, R0, #0x3             // N mod 4
                ADD      R4, R2, R4               // R4 = byte address in ICDIPTR

                /* now that we have the register address (R4) and value (R2), write to (only)
                 * the appropriate byte */
                STRB     R1, [R4]
    
                POP      {R4-R5, PC}

/* Subroutine to perform the integer division R0 / R1.
 *    Parameters: R0 = Dividend, R1 = Divisor
 *    Returns: quotient in R1 (tens), and remainder in R2 (digits)
 */
DIVIDE: 	  MOV    R3, #0
            MOV    R2, R0

CONT:       CMP    R2, R1
            BLT    DIV_END
            SUB    R2, R1
            ADD    R3, #1
            B      CONT

DIV_END:    MOV    R1, R3
            MOV    PC, LR

/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R2 = the decimal value of the digit to be displayed
 *    Returns: R1 = bit pattern to be written to the HEX display
 */
SEG7_CODE:  LDR     R3, =BIT_CODES  
            ADD     R3, R2         // index into the BIT_CODES "array"
            LDRB    R1, [R3]       // load the bit pattern (to be returned)
            MOV     PC, LR

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment
            .end   

