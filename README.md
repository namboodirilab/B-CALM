# Behavior Controller for Associative Learning and Memory (B-CALM): Software and Hardware Introduction 
This readme file briefly introduces the supplementary files for the Behavior controller system for assoctiative learning and memory (B-CALM). <br />
 <br />

### [CIRCUIT SCHEMATIC PDF FILE](https://github.com/namboodirilab/B-CALM/blob/main/circuit%20schematic.pdf)
- This file contains the circuit schematic, building instructions and parts purchase list for our electronic system used in B-CALM.  <br />

### [TASK RUNNING OVERVIEW PDF FILE](https://github.com/namboodirilab/B-CALM/blob/main/Task%20running%20overview.pdf)
- This file contains the **MATLAB code and GUI setup instructions**, **task running instructions**, **the graphical user interface (GUI) parameters full explanation**, and **possible future tasks and parameter setting explanation**.   <br />

### [TASK CODES FOLDER](https://github.com/namboodirilab/B-CALM/tree/main/task%20codes)
 The first part of this folder contains the **MATLAB GUI code**--[headfix_GUI.m](https://github.com/namboodirilab/B-CALM/blob/main/task%20codes/headfix_GUI.m), **the actual GUI figure file made in GUIDE**--[headfix_GUI.fig](https://github.com/namboodirilab/B-CALM/blob/main/task%20codes/headfix_GUI.fig),  and **the data saving and plotting file** for current experiment--[conditioning_prog.m](https://github.com/namboodirilab/B-CALM/blob/main/task%20codes/conditioning_prog.m).
  
  The second part of this folder contains five Arduino task scripts for running five different experiments. Task parameters and instructions of running each one are documented in the [Task running overview](https://github.com/namboodirilab/B-CALM/blob/main/Task%20running%20overview.pdf). <br />
  - [Namlab_behavior_cues.ino](https://github.com/namboodirilab/B-CALM/tree/main/task%20codes/Namlab_behavior_cues) - This is experiment mode one in the GUI setting. This is for cue triggered experiments (both Pavlovian and cue-action-reward). <br />
  - [Namlab_behavior_randomrewards.ino](https://github.com/namboodirilab/B-CALM/tree/main/task%20codes/Namlab_behavior_randomrewards) - This is experiment mode two in the GUI, for lick training animals with a poission distribution of rewards. <br />
  - [Namlab_behavior_lickforreward.ino](https://github.com/namboodirilab/B-CALM/tree/main/task%20codes/Namlab_behavior_lickforreward) - This is experiment mode three in the GUI, for operant/instrumental action-reward associated tasks. <br />
  - [Namlab_behavior_decisionmaking.ino](https://github.com/namboodirilab/B-CALM/tree/main/task%20codes/Namlab_behavior_decisionmaking) - This is experiment mode four in the GUI, mainly for decision making tasks with the possible implentation of different cues, reward magnitudes, and delays for either choices. <br />
  - [Namlab_behavior_ramptiming.ino](https://github.com/namboodirilab/B-CALM/tree/main/task%20codes/Namlab_behavior_ramptiming) - This is experiment mode six in the GUI, for studying a ramp timing task with reward magnitude varying based on the ramp (not part of the B-CALM paper). <br />
  
  (These five experiments include nearly all possible task combinations and setups for running common associative learning and memory tasks. Other experiment mode task files beyond the scope of the paper are not included here currently since they are being validated. <br />
  
### [DATA ANALYSIS CODES FOLDER](https://github.com/namboodirilab/B-CALM/tree/main/data%20analysis%20codes)  <br />
  This folder contains five MATLAB data analysis codes for analyzing the five different tasks we've demonstrated in the paper. All analysis codes are documented to guide users to understand the logic behind our analysis. 
  - [cueactionrewardtask.m](https://github.com/namboodirilab/B-CALM/blob/main/data%20analysis%20codes/cueactionrewardtask.m) - This file is for analyzing and plotting the Cue-action-reward task in the paper. <br />
  - [desisionmakingtask.m](https://github.com/namboodirilab/B-CALM/blob/main/data%20analysis%20codes/decisionmakingtask.m) - This file is for analyzing the decision-making task in the paper. <br />
  - [operanttask.m](https://github.com/namboodirilab/B-CALM/blob/main/data%20analysis%20codes/operanttask.m) This is for analyzing the operant conditioning task demonstrated in the paper. <br />
  - [pavloviantask.m](https://github.com/namboodirilab/B-CALM/blob/main/data%20analysis%20codes/pavloviantask.m) - This file is for analyzing the Pavlovian conditioning file shown in the paper. <br />
  - [timingtask.m](https://github.com/namboodirilab/B-CALM/blob/main/data%20analysis%20codes/timingtaskraster.m) - This file is for analyzing the interval timing task demonstrated in the paper. <br />
  
### [HEAD_FIXED_SETUP FOLDER](https://github.com/namboodirilab/B-CALM/tree/main/head_fixed_setup)  <br />
  This folder contains:
  - [head_fixed stage setup overview](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/Head-fixed%20stage%20setup%20overview.pdf) - this file explains the instructions for building our current head_fixed stage and the reward delivery system. It also contains the overview pictures for our 3D printing parts, lick tube positioning instructions and the head-fixed stage parts purchase information index.
  - [CAD files folder](https://github.com/namboodirilab/B-CALM/tree/main/head_fixed_setup/CAD%20files) - this folder contains the [head-fixed stage base design](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/CAD%20files/base%20design%20clean.step), the [head-fixed holder top piece](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/CAD%20files/Original_holdertop.SLDPRT), and the [head-fixed holder bottom piece](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/CAD%20files/Original_holderbottom_mod.SLDPRT). All three items were custom made through [eMachineShop](https://www.emachineshop.com/main/). (Orders require submiting quotes with those CAD files through the eMachineShop website. Please note that this is not to endorse eMachineShop. Any machine shop should be able to make these parts)
  - [3D printing files](https://github.com/namboodirilab/B-CALM/tree/main/head_fixed_setup/3D%20printing%20files) - this folder contains all the 3D printing files we utilized in the head-fixed stage setup.
    - [Final_2_lick_tube_holder_levelholes.stl](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/3D%20printing%20files/Final_2_lick_tube_holder_levelholes.stl) - this is the middle two lick tube holder piece.
    - [Final_retraction_solenoid_wing_holder.stl](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/3D%20printing%20files/Final_retraction_solenoid_wing_holder.stl) - this is the two retraction solenoid wing holder.
    - [Final_left_retraction_solenoid_attachment.stl](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/3D%20printing%20files/Final_left_retraction_solenoid_attachment.stl) - this is the left side retraction solenoid attachment piece. Left is relative to the mouse snout. 
    - [Final_right_retraction_solenoid_attachment_30mm.stl](https://github.com/namboodirilab/B-CALM/blob/main/head_fixed_setup/3D%20printing%20files/Final_right_retraction_solenoid_attachment_30mm.stl) - this is the right side retraction solenoid attachment piece.
