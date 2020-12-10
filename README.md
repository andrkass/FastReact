# FastReact
FastReact P4 Pipeline for Netronome smartNIC and T4P4S user-space soft switch. This is the source code for the python tools and switch programs used in the paper "Towards In-Network Event Detection and Filtering for Publish/Subscribe Communication using Programmable Data Planes". The paper is available here: https://doi.org/10.1109/TNSM.2020.3040011

This project contains the following directories: 
p4-generator: This is the python generator which generates FastReact-PS P4 code based on a few parameters. 
packet\_traces: This a python generator for packet traces which can be used to benchmark the switch. It can also easily be modified to generate traces that test the logic capabilities of the switch. 
examples: Pre-generated FastReact-PS switch programs for use in the Netronome Agilio or t4p4s platform. 

# Usage 
There are four steps that needs to be done in order to test the switch. 

1. Generate a P4 program (or use one of the pre-generated examples). 
2. Compile it for your platform of choice. 
3. Generate the packet traces. 
4. Run the packets through the switch. 

## Generate P4 Program
Check out the documentation in the `p4-generator` directory for information on how to do this. You may also feel free to use the examples from the examples directory. You can look at the `create-examples.sh` script for information on how they were generated. These examples use mostly default parameters, which works for simple experiments. However, if you need to perform more complex control logic, have a network with many publishers or need to store more history, please read the documentation for the generator. 

## Compile Program
Now you need to compile the program for your platform. For Netronome Agilio, you can either use their development studio, or use the Linux command line tools. For the experiments in the paper, we used the development environment for testing and debugging, while the command line tools were used for the final switch programs. One important thing to note, is that you need to disable the flow cache in the build settings, otherwise the Netronome Switch will cache actions, and skip the control logic. We used the NFP4000 platform for testing, but feel free to try out other platforms. 

For the t4p4s switch, you can simply check out the latest version and provide it with the generated program. This should work out of the box, unless there have been major changes to the switch. The granular lock (for highest performance) requires some modifications to the switch. There is an @atomic block covering a potentially large chunk of code in the generated switch program, and if there is only a single global lock, many processor cores may be stuck waiting for the lock to clear. Since publisher messages from different publishers can be processed in parallel, we want an individual lock for each publisher id. How I solved this was simply altering the t4p4s compiler to produce the appropriate C code, which performs the lock on a per-publisher-id (hdr.sensor.sensorid). 

I modified the t4p4s/src/utils/codegen.py like this (around line 382): 

```
elif stmt.node_type == 'BlockStatement': ## src/utils/codegen.sugar.py 323
	is_atomic = is_atomic_block(stmt) ## src/utils/codegen.sugar.py 324
	if is_atomic: ## src/utils/codegen.sugar.py 325
	   generated_code += indent() + "LOCK(&" + str(enclosing_control.type.name) + "_lock[GET_INT32_AUTO_PACKET(pd, header_instance_sensor, field_sensor_header_sensorId)])" + sugar("codegen.sugar.py", 326) + "" ## src/utils/codegen.sugar.py 326
	for c in stmt.components: ## src/utils/codegen.sugar.py 327
		generated_code += str( format_statement(c)) # codegen@328 ## src/utils/codegen.sugar.py 328
	if is_atomic: ## src/utils/codegen.sugar.py 329
	   generated_code += indent() + "UNLOCK(&" + str(enclosing_control.type.name) + "_lock[GET_INT32_AUTO_PACKET(pd, header_instance_sensor, field_sensor_header_sensorId)])" + sugar("codegen.sugar.py", 330) + "" ## src/utils/codegen.sugar.py 330
```

## Generate Packet Traces
The samples directory contains a build script for building the samples. This script requires scapy to be installed. The final generated traces follow this pattern: sensor-<count>-<size>.cap, where <count> is the number of different sensors, and <size> is the packet size of each sensor message. A larger number of sensors will provide better performance provided a granular lock is installed (messages from different sensors can be processed in parallel, but messages from the same sensor can not). Two test traces are also generated, which are not used for anything in particular. Feel free to modify them to experiment with different switch control logic. 

## Run Traffic Through Switch
We used the OSNT traffic generator to generate the traffic, with the help of 10G NetFPGA-SUME FPGAs/NICs. OSNT is available here: http://osnt.org/

The `osnt-extmem` variant was used, and for most experiments, we sent traffic through port 2 and 3, using a custom made CLI tool. As I'm not sure to the license of OSNT/SUME internals, I will not distribute the tool. However OSNT comes with a set of CLI tools which will work fine, we just modified them to fully automate testing. 

### A note on publisher and sensor
We use the terms publisher and sensor interchangeably throughout the code and documentation. The same is true for subscriber and actuator. This is because in its inception, FastReact was made for the industrial automation use-case, but with later versions, we have expanded this into pubsub, but some old variable names and documentation still remains. 

Good luck! 

