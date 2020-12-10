# FastReact
FastReact P4 Pipeline for Netronome smartNIC and T4P4S user-space soft switch. This directory contains the source code for a tool used to generate the P4 (and C) programs required for the FastReact switch. There are two variants of the tool, one for the Netronome switch, and one for the T4P4S switch. Please read the paper before attempting to use the tool. 

## Netronome Tool
To use, run `./autogen.py` and provide it with relevant parameters. Here is a list of all parameters: 

`--sensor-count`: The number of sensors/publishers in the network. 

`--max-disjunctive`: The maximum number of disjunctive expressions that the resulting switch program can support. 

`--disjunctive-rows`: The number of rows in the disjunctive table. 

`--max-conjunctive`: The maximum number of conjunctive expression that the resulting switch program can support. 

`--history-size`: Number of historical values to store per switch. 

`--output`: Where to put the switch program P4 file. 

`--p4-template`: Template file to use for the P4 part of the program. 

`--c-template`: Template to use for the C part of the program. 

Okay, so these are all the parameters that can be changed, but how do I produce a reasonable switch? A good way is just to leave most parameters out, which will default to a very simple switch. 

```
./autogen.py --p4-template fastreact.p4 --c-template logic.c --output output.p4
```

Here we supply the `fastreact.p4` template for the P4 code, and `logic.c` as the C code. See end of README for a list of all templates. The resulting files will be `output.p4` and `output.c`. Compile these into a switch program using the Netronome SDK. When the switch is loaded, you need to have a controller fill the register table, or do this manually using the SDK tools (or even better, automate it). 

## T4P4S Tool
This tool has the same parameters as the Netronome tool, and works essentially the same. One difference is that this tool generates a piece of P4 code which automatically fills the logic tables with control logic. This is done in the `genconfig` function, which you can modify to generate the logic that you require for your experiments. 

Take the resulting P4 file and compile it with the T4P4S toolchain. The toolchain has to be modified to support atomic operations, and for the best performance, a granular lock has to be implemented. 

## List of templates

`fastreact.p4`/`logic.c`: Netronome switch with logic performed in pure P4 code. 

`fastreact-ext.p4`/`logic-ext.c`: Netronome switch with logic performed in C externs. 

`fastreact-t4p4s.p4`: T4P4S switch, with logic performed in pure P4 code. 


