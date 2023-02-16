function behavior_GUI

global s running actvAx saveDir

mainPath = '/Users/mzhou/OneDrive - University of California, San Francisco';
addpath(mainPath)
saveDir = [mainPath '/data/'];          % where to save data


% Make figure
sz = get(0, 'ScreenSize'); % screen size
x = mean(sz([1, 3])); % center position
y = mean(sz([2, 4])); % center position
width = 1500;
height = 900;

fig = uifigure('Position', [x - width/2, y - height/2, width, height]);
fig.Units = 'normalized';
fig.Name = 'Behavior_GUI';


% Find available serial ports
availablePortslbl = uilabel(fig);
availablePortslbl.Text='Select Serial Port:';
% availablePortslbl.Units = 'normalized';
availablePortslbl.Position = [10 850 100 24];
availablePorts = uidropdown(fig);
availablePorts.Position = [110 850 170 24];    % Make serial port drop down
port = serialportlist("available");
if ~isempty(port)
    set(availablePorts,'Items',port)
end


%Connected to Field
connectlbl = uilabel(fig, 'Text', 'Connected to:', 'Position', [580 850 80 22]);
connectfield = uieditfield(fig,'text','Editable','off','Position', [670 850 150 22]);
filenamelbl = uilabel(fig, 'Text', 'Save file as:', 'Position', [580 820 70 22]);
filenamefield = uieditfield(fig,'text','Value','animal_name','Editable','on','Position', [670 820 150 22]);
starttimelbl = uilabel(fig, 'Text', 'Start Time:', 'Position', [580 790 70 22]);
starttimefield = uieditfield(fig,'text','Editable','off','Position', [670 790 150 22]);
refreshbutton = uibutton(fig, 'Position',[220 790 100 40], 'Text','Refresh','FontSize',11, 'ButtonPushedFcn', {@pushRefresh,availablePorts});
connectbutton = uibutton(fig, 'Position',[10 790 100 40], 'Text','Connect','FontSize',11, 'Enable','off','ButtonPushedFcn', {@pushConnect,connectfield,availablePorts});

% Select experiment mode 
experiments = uipanel(fig, 'Title', 'Experiment modes:', 'FontSize',12,'Units','normalized', 'Position', [0.23 0.86 0.15*.9 0.12]);
experimentmode = uidropdown('Parent',experiments,'Items',{'1: Cues with or without lick req','2: Random rewards','3: Lick for rewards','4: Decision making',...
    '5: Ramp timing task'}, 'ItemsData',[1 2 3 4 5 6], 'FontSize', 11);
experimentmode.Position = [12 50 170 24];

% uploadfield = uieditfield(fig,'text','Editable','off','Position', [100 170 150 22]);
uploadbutton = uibutton('Parent', experiments,'Text', 'Upload','FontSize', 11,...
    'Position', [30 18 140 24], 'ButtonPushedFcn', {@pushUpload,availablePorts,experimentmode,connectbutton});

% unittetx = uilabel(fig, 'Text', '* All time values are in units of ms', 'FontSize',11, 'Position', [570 830 190 30]);

% Buttons for disconnecting to arduino
disconnectbutton = uibutton(fig, 'Position',[115 790 100 40], 'Text','Disconnect','FontSize',11, 'Enable','off','ButtonPushedFcn', {@pushDisconnect,connectbutton,connectfield,uploadbutton,refreshbutton,availablePorts,experimentmode});

% Data for csproperties and lick properties
tempCS ={'Number of trials', 25, 25, 50, 0;
        'Frequency(kHz)', 12, 3, 5, 0;
        'Predicted solenoid', '5+3', '5+3', '1+3', '1+3';
        'Probability of solenoid', '0+100', '0+100', '0+0', '0+0';
        'Solenoid open time (ms)', '3000+40', '3000+40', '0+30', '0+40';
        'Cue duration (ms)', 1000, 1000, 1000, 1000;
        'Delay to solenoid (ms)', '0+3000', '0+3000', '0+3000', '0+3000';
        'Pulse tone (1) or not (0)', 0, 0, 1, 0;
        'Speaker number', 1, 2, 2, 2;
        'Light number', 1, 2, 1, 2;
        'Go lick requirement', 0, 0, 0, 0;
        'Go lick tube (or solenoid)', 1, 1, 3, 1;
        'Cue type: sound(1), light(2)', 1, 1, 1, 1;
        'Ramp max delay', 5000, 5000,1200, 5000;
        'Ramp exponent', 1, 1, 1, 1;
        'Increasing cue (1) or not(0)', 0, 0, 0, 0;
        'Delay to deliver the second cue if there is one', 0, 0, 0, 0;
        'Second cue type: sound(1) light(2) nocue(0)', 0, 0, 0, 0;
        'Second cue frequency', 5, 5, 5, 5;
        'Second cue speaker number', 1, 1, 2, 2;
        'Second cue light number', 1, 1, 1, 1};
cscolnames = {'Variables', 'CS1', 'CS2', 'CS3', 'CS4'};    
cstable = uitable(fig,'Data',tempCS);
set(cstable, 'columnname', cscolnames);
cstable.FontSize = 9;
% csproperties.Position(:) = [50 500 400 300];
cstable.Units = 'normalized';
cstable.Position = [0.005 0.47 0.32 0.38];
cstable.ColumnEditable = [false true true true true];
assignin('base','cstable',cstable);

templick = {'Number of licks required',  5, 5;
            'Fixed(0), variable(1), progressive(2) ratio',      0, 0;
            'Predicted solenoid',        3, 3;
            'Probability of solenoid', 100, 0;
            'Solenoid open time (ms)',  30, 30;
            'Delay to solenoid (ms)',    0, 0;
            'Delay to next lick (ms)',100, 100;
            'Fixed(0), variable(1), progressive(2) interval',      0, 0;                
            'Min number of rewards',    100, 0;
            'Sound(1), light(2) or both(3)' 1 1;
            'Pulse tone (1) or not (0)' 0 1;
            'Sound Frequency (kHz)' 12 3;
            'Sound Duration (ms)' 0 1000;
            'Speaker number' 1 2;
            'Light number' 1 2;
            'Fixed side check', 0, 0;
            'Progressive multiplier', 2, 2};
lickcolnames = {'Variables', 'Lick1', 'Lick2'};      
licktable = uitable(fig, 'Data', templick);
set(licktable, 'columnname', lickcolnames);
licktable.FontSize = 9;
% lickproperties.Position(:) = [500 600 300 200];
licktable.Units = 'normalized';
licktable.Position = [0.33 0.47 0.22 0.38];
licktable.ColumnEditable = [false true true];
assignin('base','licktable', licktable);


% Make panels
% Optogenetics panel
 Optopanel = uipanel(fig, 'Title','Optogenetics', 'FontSize',12,'FontWeight','bold',...
    'Units', 'normalized','Position',[0.555 0.74 0.165*.87 0.25]);
randomlaser = uicheckbox('Parent', Optopanel, 'Text', 'Random laser?','FontSize', 11,'Position', [15 175 120 22]);
trialbytriallaser = uicheckbox('Parent', Optopanel, 'Text', 'Trial-by-tiral?', 'FontSize',11,'Position', [130 175 150 22]);
laserwrtcuetext = uilabel('Parent', Optopanel, 'Text', 'Laser latency wrt cue', 'FontSize', 11, 'Position', [15 145 150 22]);
laserwrtcue = uieditfield('numeric','Parent',Optopanel,'Editable','on','Position', [160 145 40 20]);
laserdurationtext = uilabel('Parent',Optopanel,'Text','Laser duration', 'FontSize',11, 'Position', [15 115 100 22]);
laserduration = uieditfield('numeric','Parent', Optopanel,'Editable', 'on', 'Position',[160 115 40 20]);
laserpulseontext = uilabel('Parent',Optopanel,'Text','Laser pulse ON period', 'FontSize',11, 'Position', [15 85 130 22]);
laserpulseon = uieditfield('numeric','Parent', Optopanel,'Editable', 'on', 'Position',[160 85 40 20]);
laserpulseofftext = uilabel('Parent',Optopanel,'Text','Laser pulse OFF period', 'FontSize',11, 'Position', [15 55 130 22]);
laserpulseoff = uieditfield('numeric','Parent', Optopanel,'Editable', 'on', 'Position',[160 55 40 20]);
laserchecktext = uilabel('Parent',Optopanel, 'Text', 'Check laser or not', 'FontSize', 11, 'Position', [15 30 120 20]);
Rewardlasercheck = uicheckbox('Parent',Optopanel, 'Text', 'Reward', 'FontSize',11, 'Position',[140 30 70 20]);
CS1lasercheck = uicheckbox('Parent', Optopanel, 'Text', 'CS1', 'FontSize',11, 'Position', [15 5 50 20]);
CS2lasercheck = uicheckbox('Parent', Optopanel, 'Text', 'CS2', 'FontSize',11, 'Position', [60 5 50 20]);
CS3lasercheck = uicheckbox('Parent', Optopanel, 'Text', 'CS3', 'FontSize',11, 'Position', [115 5 50 20]);
CS4lasercheck = uicheckbox('Parent', Optopanel, 'Text', 'CS4', 'FontSize',11, 'Position', [170 5 50 20]);
laserfunctions = [randomlaser, laserwrtcue, laserduration, laserpulseon, laserpulseoff, Rewardlasercheck,...
    CS1lasercheck, CS2lasercheck, CS3lasercheck, CS4lasercheck, trialbytriallaser];

% ITI panel
ITIpanel = uipanel(fig, 'Title', 'ITI', 'FontSize', 12, 'FontWeight','bold','Units', 'normalized',...
    'Position', [0.7 0.74 0.165*.87 .25]);
Intervaldistributiontext = uilabel('Parent',ITIpanel,'Text','Interval distribution', 'FontSize',11, 'Position', [15 170 110 20]);
intervaldistribution = uidropdown('Parent',ITIpanel, 'Items', {'1. exponential ITI','2. uniform ITI', '3. poisson CS',...
    '4. poisson CS & Rw', '5. poisson Rw-CS'}, 'ItemsData',[1 2 3 4 5], 'FontSize', 11, 'Position', [120 170 90 20]);
maxdelaycuetovacuumtext = uilabel('Parent', ITIpanel, 'Text', 'max delay b/w cue and vacuum', 'FontSize', 11,'Position', [5 140 160 20]);
maxdelaycuetovacuum = uieditfield('numeric','Parent',ITIpanel,'Editable','on','Position', [160 140 50 20], 'Value', 6000);
meanITItext = uilabel('Parent', ITIpanel, 'Text', 'mean IIT (if same with', 'FontSize', 11,'Position', [20 110 150 20]);
meanITItextline2 = uilabel('Parent', ITIpanel, 'Text', 'maxITI use fixed ITI)', 'FontSize', 11, 'Position', [20 90 150 20]);
meanITI = uieditfield('numeric','Parent',ITIpanel,'Editable','on','Position', [160 100 50 20], 'Value', 5000);
minITItext = uilabel('Parent', ITIpanel, 'Text', 'minITI', 'FontSize', 11, 'Position', [55 60 120 20]);
minITI = uieditfield('numeric','Parent',ITIpanel,'Editable','on','Position', [160 60 50 20]);
maxITItext = uilabel('Parent', ITIpanel, 'Text', 'maxITI truncation of ITI - ',...
    'FontSize', 11, 'Position', [25 30 180 20]);
maxITItextline2 = uilabel('Parent',ITIpanel, 'Text', 'min(maxITI, 3*meanITI)', 'FontSize', 11, 'Position', [25 10 140 20]);
maxITI = uieditfield('numeric','Parent',ITIpanel,'Editable','on','Position', [160 20 50 20], 'Value', 10000);
ITIfunctions = [intervaldistribution, maxdelaycuetovacuum, meanITI, minITI, maxITI];

% Background rewards panel
bgdrpanel =  uipanel(fig, 'Title', 'Background rewards', 'FontSize', 12, 'FontWeight','bold',...
    'Units', 'normalized','Position', [0.845 0.74 0.171*0.9 0.25]);
bgdsolenoidtext = uilabel('Parent', bgdrpanel, 'Text', 'bgd solenoid #', 'FontSize', 11, 'Position', [15 175 100 20]);
bgdsolenoid = uieditfield('numeric','Parent', bgdrpanel, 'Editable','on', 'Position', [90 175 40 20],'Value',3);
r_bgdtext = uilabel('Parent', bgdrpanel, 'Text', 'open time', 'FontSize', 11, 'Position', [135 175 50 20]);
r_bgd = uieditfield('numeric','Parent', bgdrpanel, 'Editable','on', 'Position', [190 175 30 20],'Value',0);
bgdperiodtext = uilabel('Parent', bgdrpanel, 'Text','Background period T_bgd', 'FontSize',11, 'Position', [15 145 170 20]);
T_bgd = uieditfield('numeric','Parent', bgdrpanel, 'Position', [180 145 40 20],'Value',12000); 
mindelaybgdtocuetext = uilabel('Parent', bgdrpanel, 'Text','Min delay between bgd', 'FontSize',11, 'Position', [15 115 170 20]);
mindelaybgdtocuetext2 = uilabel('Parent', bgdrpanel, 'Text','reward to cue', 'FontSize',11, 'Position', [15 105 170 20]);
mindelaybgdtocue = uieditfield('numeric','Parent', bgdrpanel, 'Position', [180 112.5 40 20],'Value',3000); 
mindelayfxdtobgdtext = uilabel('Parent', bgdrpanel, 'Text','Min delay between bgd', 'FontSize',11, 'Position', [15 80 140 20]);
mindelayfxdtobgdtextline2 = uilabel('Parent', bgdrpanel, 'Text',' and fxd reward', 'FontSize',11, 'Position', [15 70 100 20]);
mindelayfxdtobgd = uieditfield('numeric','Parent', bgdrpanel, 'Position', [180 80 40 20],'Value',3000); 
totPoisssolenoidtext = uilabel('Parent', bgdrpanel, 'Text','Total# background rewards', 'FontSize',11, 'Position', [15 50 160 20]);
totPoisssolenoid = uieditfield('numeric','Parent', bgdrpanel, 'Position', [180 50 40 20],'Value',100); 
trialbytrialbgdsolenoidflag = uicheckbox('Parent',bgdrpanel, 'Text', 'Run trial-by-trial bgd rewards experiment?',...
    'FontSize', 11, 'Position', [5 20 250 20]);
bgdsolfunctions = [bgdsolenoid, r_bgd, T_bgd, mindelaybgdtocue, mindelayfxdtobgd, totPoisssolenoid, trialbytrialbgdsolenoidflag];


% Test buttons 
testCS1 = uibutton(fig, 'Text', 'Test CS1', 'FontSize',11, 'Position',[840 610 100 40], 'Enable','off','ButtonPushedFcn', {@testCS1_fcn});
testCS2 = uibutton(fig, 'Text', 'Test CS2', 'FontSize',11, 'Position',[950 610 100 40], 'Enable','off','ButtonPushedFcn', {@testCS2_fcn});
testCS3 = uibutton(fig, 'Text', 'Test CS3', 'FontSize',11, 'Position',[1060 610 100 40], 'Enable','off','ButtonPushedFcn', {@testCS3_fcn});
testCS4 = uibutton(fig, 'Text', 'Test CS4', 'FontSize',11, 'Position',[1170 610 100 40], 'Enable','off','ButtonPushedFcn', {@testCS4_fcn});
testlaser = uibutton(fig, 'Text', 'Test Laser', 'FontSize',11, 'Position',[1280 610 100 40], 'Enable','off','ButtonPushedFcn', {@testlaser_fcn});
testvacuum = uibutton(fig, 'Text', 'Test Vacuum', 'FontSize',11, 'Position',[1390 610 100 40], 'Enable','off','ButtonPushedFcn', {@testvacuum_fcn});

solenoid1panel = uipanel(fig, 'Title', 'Solenoid 1','Units','normalized', 'Position', [0.56 0.58 0.105 0.08]);
manualsolenoid1 = uibutton(solenoid1panel, 'Text','Manual', 'FontSize', 11, 'Enable','off','Position', [15 28 120 20],'ButtonPushedFcn', {@manualsolenoid1_fcn});
primesolenoid1 = uibutton(solenoid1panel, 'state', 'Text','Prime', 'Value', false, 'FontSize',11, 'Enable','off','Position',[15 5 120 20], 'ValueChangedFcn', {@primesolenoid1_fcn});
solenoid2panel = uipanel(fig, 'Title', 'Solenoid 2','Units','normalized','Position', [0.56 0.48 0.105 0.08]);
manualsolenoid2 = uibutton('Parent', solenoid2panel, 'Text','Manual', 'FontSize', 11, 'Enable','off','Position', [15 28 120 20],'ButtonPushedFcn', {@manualsolenoid2_fcn});
primesolenoid2 = uibutton(solenoid2panel, 'state','Text','prime', 'Value', false, 'FontSize',11, 'Enable','off','Position',[15 5 120 20], 'ValueChangedFcn', {@primesolenoid2_fcn});
solenoid3panel = uipanel(fig, 'Title', 'Solenoid 3','Units','normalized','Position', [0.675 0.58 0.105 0.08]);
manualsolenoid3 = uibutton('Parent', solenoid3panel, 'Text','Manual', 'FontSize', 11, 'Enable','off','Position', [15 28 120 20],'ButtonPushedFcn', {@manualsolenoid3_fcn});
primesolenoid3 = uibutton(solenoid3panel, 'state','Text','prime', 'Value', false, 'FontSize',11, 'Enable','off','Position',[15 5 120 20], 'ValueChangedFcn', {@primesolenoid3_fcn});
solenoid4panel = uipanel(fig, 'Title', 'Solenoid 4','Units','normalized','Position', [0.675 0.48 0.105 0.08]);
manualsolenoid4 = uibutton('Parent', solenoid4panel, 'Text','Manual', 'FontSize', 11, 'Enable','off','Position', [15 28 120 20],'ButtonPushedFcn', {@manualsolenoid4_fcn});
primesolenoid4 = uibutton(solenoid4panel, 'state','Text','prime', 'Value', false, 'FontSize',11, 'Enable','off','Position',[15 5 120 20], 'ValueChangedFcn', {@primesolenoid4_fcn});

lickretractsolenoid1panel = uipanel(fig, 'Title', 'Lick retract solenoid 1','Units','normalized','Position', [0.79 0.58 0.105 0.08]);
manuallickretractsolenoid1 = uibutton('Parent', lickretractsolenoid1panel, 'Text','Manual', 'FontSize', 11, 'Enable','off','Position', [15 28 120 20],'ButtonPushedFcn', {@manuallickretractsolenoid1_fcn});
primelickretractsolenoid1 = uibutton(lickretractsolenoid1panel,'state', 'Text','prime', 'Value', false, 'Enable','off','FontSize',11,'Position',[15 5 120 20], 'ValueChangedFcn', {@primelickretractsolenoid1_fcn});
lickretractsolenoid2panel = uipanel(fig, 'Title', 'Lick retract solenoid 2','Units','normalized','Position', [0.79 0.48 0.105 0.08]);
manuallickretractsolenoid2 = uibutton('Parent', lickretractsolenoid2panel, 'Text','Manual', 'FontSize', 11, 'Enable','off','Position', [15 28 120 20],'ButtonPushedFcn', {@manuallickretractsolenoid2_fcn});
primelickretractsolenoid2 = uibutton(lickretractsolenoid2panel, 'state','Text','prime', 'Enable','off', 'Value', false, 'FontSize',11, 'Position',[15 5 120 20], 'ValueChangedFcn', {@primelickretractsolenoid2_fcn});

vacuumpanel = uipanel(fig, 'Title', 'Vacuum','Units','normalized','Position', [0.90 0.58 0.095 0.08]);
manualvacuum = uibutton(vacuumpanel, 'Text', 'Manual', 'FontSize', 11, 'Enable','off','Position', [15 12 120 30]);


% Test buttons
testbuttons = [testCS1,testCS2,testCS3,testCS4,testlaser,testvacuum,manualsolenoid1,manualsolenoid2,manualsolenoid3,manualsolenoid4,...
    primesolenoid1,primesolenoid2,primesolenoid3,primesolenoid4,manuallickretractsolenoid1,manuallickretractsolenoid2,...
    primelickretractsolenoid1, primelickretractsolenoid2, manualvacuum];

% Make plot
ax = uiaxes(fig, 'Units','normalized','Position', [0.01 0.02 0.55 0.45]);
actvAx = ax;    % set as global so conditiong_prog can plot

lick1text = uilabel(fig, 'Text', 'Lick1s', 'FontColor', [0.2 0.6 1],'FontWeight','bold', 'FontSize', 12, 'Position', [870 280 40 20]);
lick1s = uieditfield(fig, 'numeric','Position', [920 280 60 30], 'Value',0);
lick2text = uilabel(fig, 'Text', 'Lick2s', 'FontColor', 0.65*[1, 1, 1],'FontWeight','bold', 'FontSize', 12, 'Position', [870 240 40 20]);
lick2s = uieditfield(fig, 'numeric','Position', [920 240 60 30], 'Value',0);
lick3text = uilabel(fig, 'Text', 'Lick3s', 'FontColor', [0.3 0 0],'FontWeight','bold', 'FontSize', 12, 'Position', [870 200 40 20]);
lick3s = uieditfield(fig, 'numeric','Position', [920 200 60 30], 'Value',0);
bgdsolenoidtext = uilabel(fig, 'Text', 'bgd solenoid', 'FontColor', 'k','FontWeight','bold', 'FontSize', 12, 'Position', [840 160 80 20]);
bgdsolenoids = uieditfield(fig, 'numeric','Position', [920 160 60 30], 'Value',0);
CS1soundtext = uilabel(fig, 'Text', 'CS1 sounds', 'FontColor', 'g','FontWeight','bold', 'FontSize', 12, 'Position', [985 280 80 20]);
CS1sounds = uieditfield(fig, 'numeric','Position', [1060 280 60 30], 'Value',0);
CS2soundtext = uilabel(fig, 'Text', 'CS2 sounds', 'FontColor', 'r','FontWeight','bold', 'FontSize', 12, 'Position', [985 240 80 20]);
CS2sounds = uieditfield(fig, 'numeric','Position', [1060 240 60 30], 'Value',0);
CS3soundtext = uilabel(fig, 'Text', 'CS3 sounds', 'FontColor', 'b','FontWeight','bold', 'FontSize', 12, 'Position', [985 200 80 20]);
CS3sounds = uieditfield(fig, 'numeric','Position', [1060 200 60 30], 'Value',0);
CS4soundtext = uilabel(fig, 'Text', 'CS4 sounds', 'FontColor', [0.49 0.18 0.56],'FontWeight','bold', 'FontSize', 12, 'Position', [985 160 80 20]);
CS4sounds = uieditfield(fig, 'numeric','Position', [1060 160 60 30], 'Value',0);

CS1lighttext = uilabel(fig, 'Text', 'CS1 lights', 'FontColor', [0 0.45 0.74], 'FontWeight','bold', 'FontSize', 12, 'Position', [1135 280 80 20]);
CS1lights = uieditfield(fig, 'numeric','Position', [1200 280 60 30], 'Value',0);
CS2lighttext = uilabel(fig, 'Text', 'CS2 lights', 'FontColor', [0.93 0.69 0.13], 'FontWeight','bold', 'FontSize', 12, 'Position', [1135 240 80 20]);
CS2lights = uieditfield(fig, 'numeric','Position', [1200 240 60 30], 'Value',0);
CS3lighttext = uilabel(fig, 'Text', 'CS3 lights', 'FontColor', [0.85 0.33 0.1], 'FontWeight','bold', 'FontSize', 12, 'Position', [1135 200 80 20]);
CS3lights = uieditfield(fig, 'numeric','Position', [1200 200 60 30], 'Value',0);
CS4lighttext = uilabel(fig, 'Text', 'CS4 lights', 'FontColor', [0.43 0.68 0.1],'FontWeight','bold', 'FontSize', 12, 'Position', [1135 160 80 20]);
CS4lights = uieditfield(fig, 'numeric','Position', [1200 160 60 30], 'Value',0);

solenoid1text = uilabel(fig, 'Text', 'Solenoid 1', 'FontColor', 'c','FontWeight','bold', 'FontSize', 12, 'Position', [1270 280 80 20]);
solenoid1s = uieditfield(fig, 'numeric','Position', [1340 280 60 30], 'Value',0);
solenoid2text = uilabel(fig, 'Text', 'Solenoid 2', 'FontColor', [0.64 0.08 0.18],'FontWeight','bold', 'FontSize', 12, 'Position', [1270 240 80 20]);
solenoid2s = uieditfield(fig, 'numeric','Position', [1340 240 60 30], 'Value',0);
solenoid3text = uilabel(fig, 'Text', 'Solenoid 3', 'FontColor', [1 0.5 0], 'FontWeight','bold', 'FontSize', 12, 'Position', [1270 200 80 20]);
solenoid3s = uieditfield(fig, 'numeric','Position', [1340 200 60 30], 'Value',0);
solenoid4text = uilabel(fig, 'Text', 'Solenoid 4', 'FontColor', [0.72 0.27 1],'FontWeight','bold', 'FontSize', 12, 'Position', [1270 160 80 20]);
solenoid4s = uieditfield(fig, 'numeric','Position', [1340 160 60 30], 'Value',0);
lickretractsolenoid1text = uilabel(fig, 'Text', 'Lick retract solenoid 1', 'FontColor', [0.3 0.75 0.93], 'FontWeight','bold', 'FontSize', 12, 'Position', [930 120 130 20]);
lickretractsolenoid1s = uieditfield(fig, 'numeric','Position', [1060 120 60 30], 'Value',0);
lickretractsolenoid2text = uilabel(fig, 'Text', 'Lick retract solenoid 2', 'FontColor',[0.97 0.28 0.18], 'FontWeight','bold', 'FontSize', 12, 'Position', [1210 120 130 20]);
lickretractsolenoid2s = uieditfield(fig, 'numeric','Position', [1340 120 60 30], 'Value',0);

textfield = struct( ...
    'lick1s', lick1s, ...
    'lick2s', lick2s, ...
    'lick3s', lick3s, ...
    'bgdsolenoids', bgdsolenoids, ...
    'CS1sounds', CS1sounds, ...
    'CS2sounds', CS2sounds, ...
    'CS3sounds', CS3sounds, ...
    'CS4sounds', CS4sounds, ...
    'CS1lights', CS1lights, ...
    'CS2lights', CS2lights, ...
    'CS3lights', CS3lights, ...
    'CS4lights', CS4lights, ...
    'solenoid1s',solenoid1s,...
    'solenoid2s',solenoid2s,...
    'solenoid3s',solenoid3s,...
    'solenoid4s',solenoid4s,...
    'lickretractsolenoid1s',lickretractsolenoid1s,...
    'lickretractsolenoid2s',lickretractsolenoid2s);

% Send, Start and Stop buttons
stopbutton = uibutton(fig,'Text','Stop','FontSize', 12,'Position',[1180 350 120 50],'Enable','off','ButtonPushedFcn', {@pushStop});
startbutton = uibutton(fig,'Text','Start','FontSize', 12,'Position',[1040 350 120 50],'Enable','off','ButtonPushedFcn', {@pushStart,testbuttons, ...
    stopbutton,filenamefield,experimentmode,laserfunctions,ITIfunctions,bgdsolfunctions,starttimefield, cstable, licktable});
sendbutton = uibutton(fig,'Text','Send','FontSize', 12,'Position',[900 350 120 50],'Enable','off','ButtonPushedFcn', {@pushSend,...
    disconnectbutton,refreshbutton,startbutton,testbuttons, cstable, licktable, experimentmode,...
    laserfunctions,ITIfunctions,bgdsolfunctions, Optopanel, ITIpanel, bgdrpanel});

set(uploadbutton,'ButtonPushedFcn', {@pushUpload,availablePorts,uploadbutton,experimentmode,connectbutton});
set(connectbutton,'ButtonPushedFcn', {@pushConnect,connectbutton,availablePorts,connectfield,disconnectbutton,refreshbutton,sendbutton});
set(disconnectbutton,'ButtonPushedFcn', {@pushDisconnect,connectbutton,connectfield,uploadbutton,refreshbutton,availablePorts,experimentmode,sendbutton,startbutton});
set(sendbutton, 'ButtonPushedFcn', {@pushSend,disconnectbutton,refreshbutton,startbutton, testbuttons, cstable, licktable, experimentmode,...
  laserfunctions, ITIfunctions, bgdsolfunctions, Optopanel, ITIpanel, bgdrpanel});
set(stopbutton, 'ButtonPushedFcn', {@pushStop, filenamefield, disconnectbutton});
set(startbutton, 'ButtonPushedFcn', {@pushStart,testbuttons,stopbutton,filenamefield,experimentmode,...
    laserfunctions,ITIfunctions,bgdsolfunctions,starttimefield,cstable, licktable});
end

function pushUpload(source, eventdata, availablePorts,uploadbutton,experimentmode,connectbutton)%,pushSolenoid3,primeSolenoid3on,primeSolenoid3off,testVacuum,testLaser,testSerialPort,testCue1,testCue2,testCue3,testCue4,testCue5)   
    
    port = get(availablePorts,'Value');        % find which is selected
    basecmd = strcat('"C:\Program Files (x86)\Arduino\hardware\tools\avr/bin/avrdude" -C"C:\Program Files (x86)\Arduino\hardware\tools\avr/etc/avrdude.conf" -v -patmega2560 -cwiring -P',port,' -b115200 -D -Uflash:w:');
    selectedmode = get(experimentmode, 'Value');
    
    if selectedmode == 1
        [status,cmdout] = dos(strcat(basecmd,'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Namlab_behavior_cues.ino.hex',':i'));
    elseif selectedmode == 2
        [status,cmdout] = dos(strcat(basecmd,'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Namlab_behavior_randomrewards.ino.hex',':i'));
    elseif selectedmode == 3
        [status,cmdout] = dos(strcat(basecmd,'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Namlab_behavior_lickforreward.ino.hex',':i'));
    elseif selectedmode == 4
        [status,cmdout] = dos(strcat(basecmd, 'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Namlab_behavior_decisionmaking.ino.hex',':i'));
    elseif selectedmode == 5
        [status,cmdout] = dos(strcat(basecmd,'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Namlab_behavior_delaydiscounting_automated.ino.hex',':i'));    
%     elseif selectedmode == 5
%         [status,cmdout] = dos(strcat(basecmd,'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Serial_port_testing.ino.hex',':i'));
    elseif selectedmode == 6
        [status,cmdout] = dos(strcat(basecmd,'C:\Users\mzhou9\Desktop\Behavioral_acquisition_and_analysis_old\uploads\Namlab_behavior_ramptiming.ino.hex',':i'));    
    end

    if contains(cmdout, 'avrdude done.') && status==0
        set(uploadbutton, 'Text', 'Successfully uploaded');
        set(experimentmode, 'Enable', 'off');
        set(uploadbutton, 'Enable','off');
        set(connectbutton, 'Enable','on');
    else
        set(uploadbutton, 'Text', 'Unable to upload');
        pause(5);
        set(uploadbutton, 'Text', 'Upload');
    end
end

function pushConnect(source,eventdata,connectbutton,availablePorts,connectfield,disconnectbutton,refreshbutton,sendbutton) 

    global s

    portList = get(availablePorts,'Items');    % get list from popup menu
    port = get(availablePorts,'Value');         % find which is selected

    s = serial(port,57600,'Timeout',1);      % setup serial port with arduino, specify the terminator as a LF ('\n' in Arduino)
    fopen(s)                                            % open serial port with arduino
    
    set(connectfield,'Value',port);                     % write out port selected in menu
    set(availablePorts,'Enable','off');                 % Disable drop down menu of ports
    set(source,'Enable','off');
    set(connectbutton, 'Enable','off');
    set(disconnectbutton,'Enable','on');
    set(refreshbutton,'Enable','off');
    set(sendbutton, 'Enable', 'on');
    
    selectedmode = get(experimentmode,'Value');

    if selectedmode == 1 || selectedmode == 4 || selectedmode == 6   
        set(cstable,'Enable','on','ColumnEditable',true); %Make table uneditable
        set(randomlaser, 'Enable', 'on');
        set(trialbytriallaser, 'Enable', 'on');
        set(laserwrtcue, 'Enable', 'on');
        set(laserduration, 'Enable', 'on');
        set(laserpulseon, 'Enable', 'on');
        set(laserpulseoff, 'Enable', 'on');
        set(Rewardlasercheck, 'Enable', 'on');
        set(CS1lasercheck, 'Enable', 'on');
        set(CS2lasercheck, 'Enable', 'on');
        set(CS3lasercheck, 'Enable', 'on');
        set(CS4lasercheck, 'Enable', 'on');
        set(intervaldistribution, 'Enable', 'on');
        set(maxdelaycuetovacuum, 'Enable', 'on');
        set(meanITI, 'Enable', 'on');
        set(minITI, 'Enable', 'on');
        set(maxITI, 'Enable', 'on');
        set(bgdsolenoid, 'Enable', 'on');
        set(r_bgd, 'Enable', 'on');
        set(T_bgd, 'Enable', 'on');
        set(mindelaybgdtocue, 'Enable', 'on');
        set(mindelayfxdtobgd, 'Enable', 'on');
        set(totPoisssolenoid, 'Enable', 'on');
        set(trialbytrialbgdsolenoidflag, 'Enable', 'on');
    elseif selectedmode == 2
        set(bgdsolenoid, 'Enable', 'on');
        set(r_bgd, 'Enable', 'on');
        set(T_bgd, 'Enable', 'on');
        set(mindelaybgdtocue, 'Enable', 'on');
        set(mindelayfxdtobgd, 'Enable', 'on');
        set(totPoisssolenoid, 'Enable', 'on');
        set(trialbytrialbgdsolenoidflag, 'Enable', 'on');
    elseif selectedmode == 3 || selectedmode == 5
        set(licktable,'Enable','on','ColumnEditable',true);
    end
end

function pushDisconnect(source, eventdata, connectbutton,connectfield,uploadbutton,refreshbutton,availablePorts,experimentmode,sendbutton,startbutton)
    global s
    fclose(s);
    delete(s);

    set(source,'Enable','off');
    set(connectfield,'Value','Disconnected');
    set(connectbutton,'Enable','on');
    set(refreshbutton,'Enable','on');
    set(availablePorts,'Enable','on');
    set(uploadbutton, 'Enable', 'on');
    set(experimentmode, 'Enable', 'on');
    set(sendbutton, 'Enable', 'off');
    set(startbutton, 'Enable', 'off');

end

% --- Executes on button press in refreshButton.
function pushRefresh(source, eventdata, availablePorts)

%     serialInfo = serialportlist(ports);                             % get info on connected serial ports
    port = serialportlist("available");

    % get names of ports
    if ~isempty(port)
        set(availablePorts,'Items',port)                            % update list of ports available
    else
        set(availablePorts,'Items', ...
            'none found, please check connection and refresh')      % if none, indicate so
    end
end


%Send button callback
function pushSend(source,eventdata,disconnectbutton,refreshbutton,startbutton, testbuttons, cstable, licktable, experimentmode,...
  laserfunctions, ITIfunctions, bgdsolfunctions,Optopanel, ITIpanel, bgdrpanel)

    global s
    numtrials    = cell2mat(cstable.Data(1,2:end));
    CSfreq       = cell2mat(cstable.Data(2,2:end));
    CSsolenoid   = [str2double(split(cstable.Data(3,2),'+'))',...
                    str2double(split(cstable.Data(3,3),'+'))',...
                    str2double(split(cstable.Data(3,4),'+'))',...
                    str2double(split(cstable.Data(3,5),'+'))'];
    CSprob       = [str2double(split(cstable.Data(4,2),'+'))',...
                    str2double(split(cstable.Data(4,3),'+'))',...
                    str2double(split(cstable.Data(4,4),'+'))',...
                    str2double(split(cstable.Data(4,5),'+'))'];
    CSopentime   = [str2double(split(cstable.Data(5,2),'+'))',...
                    str2double(split(cstable.Data(5,3),'+'))',...
                    str2double(split(cstable.Data(5,4),'+'))',...
                    str2double(split(cstable.Data(5,5),'+'))'];
    CSdur        = cell2mat(cstable.Data(6,2:end));
    CS_t_fxd     = [str2double(split(cstable.Data(7,2),'+'))',...
                    str2double(split(cstable.Data(7,3),'+'))',...
                    str2double(split(cstable.Data(7,4),'+'))',...
                    str2double(split(cstable.Data(7,5),'+'))'];
    CSpulse      = cell2mat(cstable.Data(8,2:end));
    CSspeaker    = cell2mat(cstable.Data(9,2:end));
    CSlight      = cell2mat(cstable.Data(10,2:end));
    golickreq    = cell2mat(cstable.Data(11,2:end));
    golicktube   = cell2mat(cstable.Data(12,2:end));
    CSsignal     = cell2mat(cstable.Data(13, 2:end));
    CSrampmaxdelay = cell2mat(cstable.Data(14, 2:end));
    CSrampexp    = cell2mat(cstable.Data(15,2:end));
    CSincrease = cell2mat(cstable.Data(16, 2:end));
    delayforsecondcue = cell2mat(cstable.Data(17, 2:end));
    secondcuetype = cell2mat(cstable.Data(18, 2:end));
    secondcuefreq = cell2mat(cstable.Data(19, 2:end));
    secondcuespeaker = cell2mat(cstable.Data(20, 2:end));
    secondcuelight = cell2mat(cstable.Data(21,2:end));
    
    reqlicknum      = cell2mat(licktable.Data(1,2:end));
    ratioschedule = cell2mat(licktable.Data(2,2:end));
    licksolenoid    = cell2mat(licktable.Data(3,2:end));
    lickprob        = cell2mat(licktable.Data(4,2:end));
    lickopentime    = cell2mat(licktable.Data(5,2:end));
    delaytoreward   = cell2mat(licktable.Data(6,2:end));
    delaytolick     = cell2mat(licktable.Data(7,2:end));
    intervalschedule = cell2mat(licktable.Data(8,2:end));
    minrewards      = cell2mat(licktable.Data(9,2:end));
    signaltolickreq = cell2mat(licktable.Data(10,2:end));
    soundsignalpulse   = cell2mat(licktable.Data(11,2:end));
    soundfreq       = cell2mat(licktable.Data(12,2:end));
    sounddur        = cell2mat(licktable.Data(13,2:end));
    lickspeaker     = cell2mat(licktable.Data(14,2:end));
    licklight       = cell2mat(licktable.Data(15,2:end));
    fixedsidecheck  = cell2mat(licktable.Data(16,2:end));
    progressivemultiplier = cell2mat(licktable.Data(17,2:end));

    experimentmode = get(experimentmode, 'Value');
    
    % Lasers 
    randomlaser = get(laserfunctions(1), 'Value');
    laserwrtcue = get(laserfunctions(2), 'Value');
    laserduration = get(laserfunctions(3), 'Value');
    laserpulseon = get(laserfunctions(4), 'Value');
    laserpulseoff = get(laserfunctions(5), 'Value');
    Rewardlasercheck = get(laserfunctions(6), 'Value');
    CS1lasercheck = get(laserfunctions(7), 'Value');
    CS2lasercheck = get(laserfunctions(8), 'Value');
    CS3lasercheck = get(laserfunctions(9), 'Value');
    CS4lasercheck = get(laserfunctions(10), 'Value');
    trialbytriallaser = get(laserfunctions(11), 'Value');

    % ITIs
    intervaldistribution = get(ITIfunctions(1), 'Value');
    maxdelaycuetovacuum = get(ITIfunctions(2), 'Value');
    meanITI = get(ITIfunctions(3), 'Value');
    minITI = get(ITIfunctions(4), 'Value');
    maxITI = get(ITIfunctions(5), 'Value');

    % bgd rewards
    bgdsolenoid = get(bgdsolfunctions(1), 'Value');
    r_bgd = get(bgdsolfunctions(2), 'Value');
    T_bgd = get(bgdsolfunctions(3), 'Value');
    mindelaybgdtocue = get(bgdsolfunctions(4), 'Value');
    mindelayfxdtobgd = get(bgdsolfunctions(5), 'Value');
    totPoisssolenoid = get(bgdsolfunctions(6), 'Value');
    trialbytrialbgdsolenoidflag = get(bgdsolfunctions(7), 'Value');

    % Validate inputs
    inputs = [numtrials, CSfreq, CSsolenoid, CSprob, CSopentime, CSdur, CS_t_fxd,...
        CSpulse, CSspeaker, golickreq, golicktube, CSsignal, meanITI, maxITI, minITI, intervaldistribution,...
        bgdsolenoid, T_bgd, r_bgd, mindelaybgdtocue, mindelayfxdtobgd,...
        experimentmode, trialbytrialbgdsolenoidflag, totPoisssolenoid,...
        reqlicknum, licksolenoid, lickprob, lickopentime, delaytoreward, delaytolick,...
        minrewards, signaltolickreq, soundsignalpulse, soundfreq, sounddur, lickspeaker,...
        laserwrtcue, laserduration, randomlaser, laserpulseon, laserpulseoff,...
        trialbytriallaser, maxdelaycuetovacuum, CSlight,ratioschedule, intervalschedule,...
        licklight, CS1lasercheck, CS2lasercheck, CS3lasercheck, CS4lasercheck,...
        fixedsidecheck, Rewardlasercheck, CSrampmaxdelay, CSrampexp, CSincrease,delayforsecondcue,...
        secondcuetype, secondcuefreq, secondcuespeaker, secondcuelight, progressivemultiplier]; % collect all inputs into array

    negIn  = inputs < 0;
    intIn  = inputs - fix(inputs);
    negIn(53) = 0;
    negIn(54) = 0;
    negIn(55) = 0;
    negIn(56) = 0; % Go lick requirement can be negative for no go task

    if any([negIn intIn])
        errordlg('Invalid inputs')
        error('Invalid inputs')
    end
    if (inputs(37)>0 && inputs(37) < inputs(137)) || inputs(38) < inputs(137)
        errordlg('Invalid inputs')
        error('Invalid inputs: delay to solenoids must be bigger or same with delay to second cue')
    end
    if (inputs(39)>0 && inputs(39) < inputs(138)) || inputs(40) < inputs(138)
        errordlg('Invalid inputs')
        error('Invalid inputs: delay to solenoids must be bigger or same with delay to second cue')
    end
    if (inputs(41)>0 && inputs(41) < inputs(139)) || inputs(42) < inputs(139)
        errordlg('Invalid inputs')
        error('Invalid inputs: delay to solenoids must be bigger or same with delay to second cue')
    end
    if (inputs(43)>0 && inputs(43) < inputs(140)) || inputs(44) < inputs(140)
        errordlg('Invalid inputs')
        error('Invalid inputs: delay to solenoids must be bigger or same with delay to second cue')
    end


    params = sprintf('%G+',numtrials, CSfreq, CSsolenoid, CSprob, CSopentime, CSdur, CS_t_fxd,...
          CSpulse, CSspeaker, golickreq, golicktube, CSsignal, meanITI, maxITI, minITI, intervaldistribution,...
          bgdsolenoid, T_bgd, r_bgd, mindelaybgdtocue, mindelayfxdtobgd,...
          experimentmode, trialbytrialbgdsolenoidflag, totPoisssolenoid,...
          reqlicknum, licksolenoid, lickprob, lickopentime, delaytoreward, delaytolick,...
          minrewards, signaltolickreq, soundsignalpulse, soundfreq, sounddur, lickspeaker,...
          laserwrtcue, laserduration, randomlaser, laserpulseon, laserpulseoff,...
          trialbytriallaser, maxdelaycuetovacuum, CSlight,ratioschedule, intervalschedule,...
          licklight, CS1lasercheck, CS2lasercheck, CS3lasercheck, CS4lasercheck,...
          fixedsidecheck, Rewardlasercheck, CSrampmaxdelay, CSrampexp, CSincrease,delayforsecondcue,...
          secondcuetype, secondcuefreq, secondcuespeaker, secondcuelight, progressivemultiplier);

    params = params(1:end-1);
    
    
    %Send params to arduino
    fprintf(s,params);  % send info to arduino
    flushinput(s)
    
    %Make params uneditable
    set(source,'Enable','off');     %Disable Send button
    set(startbutton,'Enable','on'); %Enable start button
    set(disconnectbutton,'Enable','on');
    set(refreshbutton,'Enable','off');
    
    set(cstable,'Enable','off','ColumnEditable',false); %Make table uneditable
    set(licktable,'Enable','off','ColumnEditable',false); %Make table uneditable
    set(Optopanel, 'Enable', 'off');
    set(ITIpanel, 'Enable', 'off');
    set(bgdrpanel, 'Enable','off');

    %Turn on testing buttons
    for btn = testbuttons
        set(btn,'Enable','on');
    end  
end


function pushStart(source,eventdata,testbuttons,stopbutton,filenamefield,experimentmode,...
    laserfunctions,ITIfunctions,bgdsolfunctions,starttimefield,cstable, licktable)
    
    global s running actvAx saveDir textfield
    numtrials    = cell2mat(cstable.Data(1,2:end));
    CSfreq       = cell2mat(cstable.Data(2,2:end));
    CSsolenoid   = [str2double(split(cstable.Data(3,2),'+'))',...
                    str2double(split(cstable.Data(3,3),'+'))',...
                    str2double(split(cstable.Data(3,4),'+'))',...
                    str2double(split(cstable.Data(3,5),'+'))'];
    CSprob       = [str2double(split(cstable.Data(4,2),'+'))',...
                    str2double(split(cstable.Data(4,3),'+'))',...
                    str2double(split(cstable.Data(4,4),'+'))',...
                    str2double(split(cstable.Data(4,5),'+'))'];
    CSopentime   = [str2double(split(cstable.Data(5,2),'+'))',...
                    str2double(split(cstable.Data(5,3),'+'))',...
                    str2double(split(cstable.Data(5,4),'+'))',...
                    str2double(split(cstable.Data(5,5),'+'))'];
    CSdur        = cell2mat(cstable.Data(6,2:end));
    CS_t_fxd     = [str2double(split(cstable.Data(7,2),'+'))',...
                    str2double(split(cstable.Data(7,3),'+'))',...
                    str2double(split(cstable.Data(7,4),'+'))',...
                    str2double(split(cstable.Data(7,5),'+'))'];
    CSpulse      = cell2mat(cstable.Data(8,2:end));
    CSspeaker    = cell2mat(cstable.Data(9,2:end));
    CSlight      = cell2mat(cstable.Data(10,2:end));
    golickreq    = cell2mat(cstable.Data(11,2:end));
    golicktube   = cell2mat(cstable.Data(12,2:end));
    CSsignal     = cell2mat(cstable.Data(13, 2:end));
    CSrampmaxdelay = cell2mat(cstable.Data(14, 2:end));
    CSrampexp    = cell2mat(cstable.Data(15,2:end));
    CSincrease = cell2mat(cstable.Data(16, 2:end));
    delayforsecondcue = cell2mat(cstable.Data(17, 2:end));
    secondcuetype = cell2mat(cstable.Data(18, 2:end));
    secondcuefreq = cell2mat(cstable.Data(19, 2:end));
    secondcuespeaker = cell2mat(cstable.Data(20, 2:end));
    secondcuelight = cell2mat(cstable.Data(21,2:end));
    
    reqlicknum      = cell2mat(licktable.Data(1,2:end));
    ratioschedule = cell2mat(licktable.Data(2,2:end));
    licksolenoid    = cell2mat(licktable.Data(3,2:end));
    lickprob        = cell2mat(licktable.Data(4,2:end));
    lickopentime    = cell2mat(licktable.Data(5,2:end));
    delaytoreward   = cell2mat(licktable.Data(6,2:end));
    delaytolick     = cell2mat(licktable.Data(7,2:end));
    intervalschedule = cell2mat(licktable.Data(8,2:end));
    minrewards      = cell2mat(licktable.Data(9,2:end));
    signaltolickreq = cell2mat(licktable.Data(10,2:end));
    soundsignalpulse   = cell2mat(licktable.Data(11,2:end));
    soundfreq       = cell2mat(licktable.Data(12,2:end));
    sounddur        = cell2mat(licktable.Data(13,2:end));
    lickspeaker     = cell2mat(licktable.Data(14,2:end));
    licklight       = cell2mat(licktable.Data(15,2:end));
    fixedsidecheck  = cell2mat(licktable.Data(16,2:end));
    progressivemultiplier = cell2mat(licktable.Data(17,2:end));

    experimentmode = get(experimentmode, 'Value');
     
    % Lasers 
    randomlaser = get(laserfunctions(1), 'Value');
    laserwrtcue = get(laserfunctions(2), 'Value');
    laserduration = get(laserfunctions(3), 'Value');
    laserpulseon = get(laserfunctions(4), 'Value');
    laserpulseoff = get(laserfunctions(5), 'Value');
    Rewardlasercheck = get(laserfunctions(6), 'Value');
    CS1lasercheck = get(laserfunctions(7), 'Value');
    CS2lasercheck = get(laserfunctions(8), 'Value');
    CS3lasercheck = get(laserfunctions(9), 'Value');
    CS4lasercheck = get(laserfunctions(10), 'Value');
    trialbytriallaser = get(laserfunctions(11), 'Value');

    % ITIs
    intervaldistribution = get(ITIfunctions(1), 'Value');
    maxdelaycuetovacuum = get(ITIfunctions(2), 'Value');
    meanITI = get(ITIfunctions(3), 'Value');
    minITI = get(ITIfunctions(4), 'Value');
    maxITI = get(ITIfunctions(5), 'Value');

    % bgd rewards
    bgdsolenoid = get(bgdsolfunctions(1), 'Value');
    r_bgd = get(bgdsolfunctions(2), 'Value');
    T_bgd = get(bgdsolfunctions(3), 'Value');
    mindelaybgdtocue = get(bgdsolfunctions(4), 'Value');
    mindelayfxdtobgd = get(bgdsolfunctions(5), 'Value');
    totPoisssolenoid = get(bgdsolfunctions(6), 'Value');
    trialbytrialbgdsolenoidflag = get(bgdsolfunctions(7), 'Value');


    params = sprintf('%G+',numtrials, CSfreq, CSsolenoid, CSprob, CSopentime, CSdur, CS_t_fxd,...
          CSpulse, CSspeaker, golickreq, golicktube, CSsignal, meanITI, maxITI, minITI, intervaldistribution,...
          bgdsolenoid, T_bgd, r_bgd, mindelaybgdtocue, mindelayfxdtobgd,...
          experimentmode, trialbytrialbgdsolenoidflag, totPoisssolenoid,...
          reqlicknum, licksolenoid, lickprob, lickopentime, delaytoreward, delaytolick,...
          minrewards, signaltolickreq, soundsignalpulse, soundfreq, sounddur, lickspeaker,...
          laserwrtcue, laserduration, randomlaser, laserpulseon, laserpulseoff,...
          trialbytriallaser, maxdelaycuetovacuum, CSlight,ratioschedule, intervalschedule,...
          licklight, CS1lasercheck, CS2lasercheck, CS3lasercheck, CS4lasercheck,...
          fixedsidecheck, Rewardlasercheck, CSrampmaxdelay, CSrampexp, CSincrease,delayforsecondcue,...
          secondcuetype, secondcuefreq, secondcuespeaker, secondcuelight, progressivemultiplier);

    params = params(1:end-1);
    
    fname = get(filenamefield,'Value');

    set(source,'Enable','off');             %Disable start button
    set(stopbutton,'Enable','on');
    %Turn off testing buttons
    for btn = testbuttons
        set(btn,'Enable','off');
    end
    
    % Run arduino code
    fprintf(s,'0');                          % Signals to Arduino to start the experiment\
    behavior_prog

    flushinput(s);                                  % clear serial input buffer 
end

function pushStop(source,eventdata,filenamefield,disconnectbutton) 
    global s running
    running = false;            % Stop running MATLAB code for monitoring arduino
    fprintf(s,'1');             % Send stop signal to arduino; 49 in the Arduino is the ASCII code for 1

    set(source,'Enable','off');
    %set(resetbutton,'Enable','on');
    set(filenamefield,'Enable','on','Editable','on');
    set(disconnectbutton,'Enable','on');
    %Close Serial Port
    fclose(s)
    clear("serialport");                                          % "closes serial"
%     delete(s);                                      % "closes serial"
end

% Test buttons for cues and laser 
function testCS1_fcn(source, eventdata)
    global s 
    fprintf(s,'2');              % Send CS2 signal to arduino; 51 in the Arduino is the ASCII code for 3
    flushinput(s)
end
function testCS2_fcn(source, eventdata)
    global s 
    fprintf(s,'3');              % Send CS2 signal to arduino; 51 in the Arduino is the ASCII code for 3
    flushinput(s)
end
function testCS3_fcn(source, eventdata)
    global s 
    fprintf(s,'4');              % Send CS2 signal to arduino; 51 in the Arduino is the ASCII code for 3
    flushinput(s)
end
function testCS4_fcn(source, eventdata)
    global s 
    fprintf(s,'5');              % Send CS2 signal to arduino; 51 in the Arduino is the ASCII code for 3
    flushinput(s)
end
function testlaser_fcn(source, eventdata)
    global s 
    fprintf(s,'8');              % Send CS2 signal to arduino; 51 in the Arduino is the ASCII code for 3
    flushinput(s)
end
function testvacuum_fcn(source, eventdata)
    global s
    fprintf(s, '9');
    flushinput(s);
end

% Test buttons for solenoids
function manualsolenoid1_fcn(source, eventdata)
    global s
    fprintf(s, 'A');
end
function primesolenoid1_fcn(source, eventdata)
    global s
    
    if source.Value == 1
        fprintf(s,'B');              % Send prime solenoid signal to arduino; 66 in the Arduino is the ASCII code for B
    else
        fprintf(s,'C');              % Send stop solenoid signal to arduino; 67 in the Arduino is the ASCII code for C
    end
end

function manualsolenoid2_fcn(source, eventdata)
    global s
    fprintf(s, 'D');
end
function primesolenoid2_fcn(source, eventdata)
    global s
    if source.Value == 1
        fprintf(s,'E');              % Send prime solenoid signal to arduino; 69 in the Arduino is the ASCII code for E
    else
        fprintf(s,'F');              % Send stop solenoid signal to arduino; 70 in the Arduino is the ASCII code for F
    end
end

function manualsolenoid3_fcn(source, eventdata)
    global s
    fprintf(s, 'G');
end
function primesolenoid3_fcn(source, eventdata)
    global s
    if source.Value == 1
        fprintf(s,'H');              % Send prime solenoid signal to arduino; 69 in the Arduino is the ASCII code for E
    else
        fprintf(s,'I');              % Send stop solenoid signal to arduino; 70 in the Arduino is the ASCII code for F
    end
end

function manualsolenoid4_fcn(source, eventdata)
    global s
    fprintf(s, 'J');
end
function primesolenoid4_fcn(source, eventdata)
    global s
    if source.Value == 1
        fprintf(s,'K');              % Send prime solenoid signal to arduino; 69 in the Arduino is the ASCII code for E
    else
        fprintf(s,'L');              % Send stop solenoid signal to arduino; 70 in the Arduino is the ASCII code for F
    end
end

function manuallickretractsolenoid1_fcn(source, eventdata)
    global s
    fprintf(s, 'M');
end
function primelickretractsolenoid1_fcn(source, eventdata)
    global s
    if source.Value == 1
        fprintf(s,'N');              % Send prime solenoid signal to arduino; 69 in the Arduino is the ASCII code for E
    else
        fprintf(s,'O');              % Send stop solenoid signal to arduino; 70 in the Arduino is the ASCII code for F
    end
end

function manuallickretractsolenoid2_fcn(source, eventdata)
    global s
    fprintf(s, 'P');
end
function primelickretractsolenoid2_fcn(source, eventdata)
    global s
    if source.Value == 1
        fprintf(s,'Q');              % Send prime solenoid signal to arduino; 69 in the Arduino is the ASCII code for E
    else
        fprintf(s,'R');              % Send stop solenoid signal to arduino; 70 in the Arduino is the ASCII code for F
    end
end

