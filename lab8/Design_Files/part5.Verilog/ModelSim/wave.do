onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -label Resetn /testbench/Resetn
add wave -noupdate -label Clock /testbench/CLOCK_50
add wave -noupdate -label KEY /testbench/KEY
add wave -noupdate -label SW /testbench/SW
add wave -noupdate -divider proc
add wave -noupdate -label Resetn /testbench/U1/U3/Resetn
add wave -noupdate -label Run /testbench/U1/U3/Run
add wave -noupdate -label Clock -radix hexadecimal /testbench/U1/U3/Clock
add wave -noupdate -label IR -radix hexadecimal /testbench/U1/U3/IR
add wave -noupdate -label W /testbench/U1/U3/W
add wave -noupdate -label Done /testbench/U1/U3/Done
add wave -noupdate -label pc -radix unsigned /testbench/U1/U3/pc
add wave -noupdate -label ADDR -radix hexadecimal /testbench/U1/U3/ADDR
add wave -noupdate -label inst_mem -radix hexadecimal /testbench/U1/inst_mem_q
add wave -noupdate -label DIN -radix hexadecimal /testbench/U1/U3/DIN
add wave -noupdate -label DOUT -radix hexadecimal -childformat {{{/testbench/U1/U3/DOUT[15]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[14]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[13]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[12]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[11]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[10]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[9]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[8]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[7]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[6]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[5]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[4]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[3]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[2]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[1]} -radix hexadecimal} {{/testbench/U1/U3/DOUT[0]} -radix hexadecimal}} -subitemconfig {{/testbench/U1/U3/DOUT[15]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[14]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[13]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[12]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[11]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[10]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[9]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[8]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[7]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[6]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[5]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[4]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[3]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[2]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[1]} {-height 15 -radix hexadecimal} {/testbench/U1/U3/DOUT[0]} {-height 15 -radix hexadecimal}} /testbench/U1/U3/DOUT
add wave -noupdate -label FSM -radix unsigned /testbench/U1/U3/Tstep_Q
add wave -noupdate -label r0 -radix hexadecimal /testbench/U1/U3/r0
add wave -noupdate -label Buswires -radix hexadecimal /testbench/U1/U3/BusWires
add wave -noupdate -label Select -radix unsigned /testbench/U1/U3/Select
add wave -noupdate -label F /testbench/U1/U3/F
add wave -noupdate -label C /testbench/U1/U3/C
add wave -noupdate -label N {/testbench/U1/U3/F[1]}
add wave -noupdate -label Z {/testbench/U1/U3/F[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {1826436 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 89
configure wave -valuecolwidth 64
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {1362978 ps}
