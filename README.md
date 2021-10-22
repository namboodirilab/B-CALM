# Behavior Controller for Associative Learning and Memory Software and Hardware Introduction 
This readme file briefly introduces the current established behaviorial task scripts, graphical user interface(GUI) system, circuit and behavioral box layout. 


### MATLAB and GUI
  [headfix_GUI.m](B-CALM/headfix_GUI.m) - This file is the main MATLAB script for the GUI. <br />
  [headfix_GUI.fig](B-CALM/headfix_GUI.fig) - This is the actual GUI figure. <br />
  [conditioning_prog.m](B-CALM/conditioning_prog.m) - This is a data saving file for current experiments.<br />
  [GUI.png](B-CALM/GUI.png) - This is an example GUI figure. 
### Arduino scripts for behavioral tasks
  [Namlab_behavior_cues.ino](B-CALM/Namlab_behavior_cues.ino) - This is experiment one in the GUI, for Pavlovain cue-reward associated experiments. <br />
  [Namlab_behavior_randomrewards.ino](B-CALM/Namlab_behavior_randomrewards.ino) - This is experiment two in the GUI, for lick training animals with a poission distribution of rewards. <br />
  [Namlab_behavior_lickforreward.ino](B-CALM/Namlab_behavior_lickforreward.ino) - This is experiment three in the GUI, for operant/instrumental action-reward associated tasks. <br />
  [Namlab_behavior_decisionmaking.ino](B-CALM/Namlab_behavior_decisionmaking.ino) - This is experiment four in the GUI, mainly for decision making tasks with the possible implentation of different cues, reward magnitudes, and delays for either choices. <br />
  [Namlab_behavior_ramptiming.ino](B-CALM/Namlab_behavior_ramptiming.ino) - This is experiment six in the GUI, for studying a ramp timing task with reward magnitude varying based on the ramp. <br />
###
  [circuit setup](B-CALM/circuit_setup.pdf) - This is a schematic circuit diagram containing a breadboard and hardwares pins interacting with the arduino mega board 2560. <br />
  [circuit example](B-CALM/circuit_example.pdf) - This is a complete circuit example including the breadboard, arduino board, breakout boards, wire wrapping, and the plastic box setup. <br />
