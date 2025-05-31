# ChatGPT FSM example

Simple state machine with one input 'in' to signal state changes.

# View waveforms with GTKWave

The following commands will compile the verilog and run a simulation.

```
iverilog -o gpt_fsm gpt_fsm.v gpt_fsm_tb.v 
vvd gpt_fsm
```

Then to display the waveforms run this.  After the first run of GTKWave, you can reload the same file without running this by choosing that option under the "File..." menu option.

```
gtkwave gpt_fsm.vcd
```

