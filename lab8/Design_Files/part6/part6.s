.define LED_ADDRESS 0x10
.define HEX_ADDRESS 0x20

// Binary counter on the LED port

        mv      r0, #0              // r0 is counter, initialized to 0
        mvt     r1, LED_ADDRESS     // r1 holds address of LEDR
        // Outer loop
MAIN:   st      r0, [r1]           
        add     r0, #1
        // Inner loop
        mv      r2, =20000
LOOP:   sub     r2, #1
        bne     LOOP
        b       MAIN
