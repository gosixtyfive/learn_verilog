# Starter LCD Driver FSM 

State machine that will write bytes to a 4 bit LCD controller

# View waveforms with GTKWave

The following commands will compile the verilog and run a simulation.

```
iverilog -o lcd_ctrl.vvp lcd_ctrl.v lcd_ctrl_tb.v 
vvp lcd_ctrl.vvp
```

Then to display the waveforms run this.  After the first run of GTKWave, you can reload the same file without running this by choosing that option under the "File | Reload waveform" menu option.

```
gtkwave lcd_ctrl_tb.vcd
```

The `lcd_ctrl_tb.gtkw` file contains a saved waveform setup.  Read the save file after first opening gtkwave to get the saved waveform list and save time resetting the signals after every reload. If the signals in gtkwave are changed and you want to save those changes so they are re-loaded when waveforms are re-loaded, Re-save via the file menu in gtkwave.  You might want to do this so you can view the signals internal to the module under test.

# Current behavior

The state machine waits for a pulse on 'start', then it latches the inputs and starts the first part of the sequence to write or read the LCD. It currently only outputs the high order bits of the input data and pulse the enable signal high a single time.

# Next Steps

Add states and logic to complete the full 4-bit write sequence 

Add states and logic to do the following:
- Wait 2 clocks after enable goes low for the first 4 bits of dataout
- Add states and logic to 
    - Change the dataout to output the low 4 bits.
    - Wait 2 clocks 
    - Drive the enable signal high for 1 clock
    - Wait 2 clocks
    - Return to IDLE state

The current simulation file lcd_ctrl_tb.v is configred to start a "write" so all modifications can be made in the `lcd_ctrl.v` file.