%% Runs session
% This function is called upon clicking the Start button in the GUI
% Requires variables param and s (serial object).

cla;                                    % Clear the axes before starting
%% Parameters
truncITI = min(maxITI,3*meanITI);                     % minITI is really the mean ITI for exponential dbn

licksinit = ceil(sum(numtrials)*(truncITI+max(CS_t_fxd))*10/1E3);  % number of licks to initialize = number of trials*max time per trial in s*10Hz (of licking)
cuesinit = sum(numtrials);                               % number of cues to initialize
logInit = 10^6;                                      % Log of all serial input events from the Arduino
bgdsolenoidsinit = ceil(sum(numtrials)*truncITI*3/T_bgd);      % number of background solenoids to initialize = total time spent in ITI*rate of rewards*3. It won't be more than 3 times the expected rate

xWindow = [-(truncITI+1000) maxdelaycuetovacuum];  % Defines x-axis limits for the plot.
fractionPSTHdisplay = 0.15;             % What fraction of the display is the PSTH?
yOffset = ceil(fractionPSTHdisplay*sum(numtrials)/(1-fractionPSTHdisplay));% amount by which the y-axis extends beyond trials so as to plot the PSTH of licks
binSize = 1000;                         % in ms
xbins = xWindow(1):binSize:xWindow(2);  % Bins in x-axis for PSTH

ticks = -(truncITI+1000):10000:maxdelaycuetovacuum;% tick marks for x-axis of raster plot. moves through by 2s
labels = ticks'/1000;                     % convert tick labels to seconds
labelsStr = cellstr(num2str(labels));     % convert to cell of strings

durationtrialpartitionnocues = 20E3;      % When experimentmode=2 or 3, how long should a single row for raster plot be?
%% Prep work
% initialize arrays for licks and cues
lickct = [0, 0, 0];% Counter for licks
bgdus = 0;% Counter for background solenoids
fxdus1 = 0;% Counter for fixed solenoid 1s
fxdus2 = 0;% Counter for fixed solenoid 2s
fxdus3 = 0;% Counter for fixed solenoid 3s
fxdus4 = 0;% counter for fixed solenoid 4s
lickretractsolenoid1 = 0;
lickretractsolenoid2 = 0;
vacuum = 0;% Counter for vacuums
cs1 = 0;% Counter for cue 1's
cs2 = 0;% Counter for cue 2's
cs3 = 0;% Counter for cue 3's
cs4 = 0;% Counter for cue 4's
light1 = 0;% Counter for light 1's
light2 = 0;% Counter for light 2's
light3 = 0;% Counter for light 3's
light4 = 0;% Counter for light 4's
both1 = 0;% Counter for both light and cue 1's
both2 = 0;% Counter for both light and cue 2's
both3 = 0;% Counter for both light and cue 3's
both4 = 0;% Counter for both light and cue 4's
eventlog = zeros(logInit,3);% empty event log for all events 
l = 0;% Counter for logged events
fisrtcueonset = NaN;

% The following variables are declared because they are stored in the
% buffer until a trial ends. This is done so that the plot can be aligned
% to the cue for all trials. Real time plotting cannot work in this case
% since there is variability in intercue interval.
templicks = NaN(ceil(licksinit/sum(numtrials)), 3); % 3 licktubes
templicksct = [0, 0, 0];                                                % count of temp licks. Calculated explicitly to speed up indexing
if numtrials(1)~=0
templicksPSTH1 = NaN(ceil(licksinit/(numtrials(1))),numtrials(1),4); % Array in which all CS1 licks are stored for calculating PSTH 
elseif numtrials(1)==0
    templicksPSTH1 = [];
end
if numtrials(2)~=0
    templicksPSTH2 = NaN(ceil(licksinit/numtrials(2)),numtrials(2),4); % Array in which all CS2 licks are stored for calculating PSTH 
elseif numtrials(2)==0
    templicksPSTH2 = [];
end
if numtrials(3)~=0
    templicksPSTH3 = NaN(ceil(licksinit/numtrials(3)),numtrials(3),4); % Array in which all CS3 licks are stored for calculating PSTH 
elseif numtrials(3)==0
    templicksPSTH3 = [];
end
if numtrials(4)~=0
    templicksPSTH4 = NaN(ceil(licksinit/numtrials(4)),numtrials(4),4); % Array in which all CS4 licks are stored for calculating PSTH 
elseif numtrials(4)==0
    templicksPSTH4 = [];
end

hPSTH1 = [];                                                % Handle to lick1 PSTH plot on CS1 trials
hPSTH2 = [];                                                % Handle to lick1 PSTH plot on CS2 trials
hPSTH3 = [];                                                % Handle to lick1 PSTH plot on CS3 trials
hPSTH4 = [];                                                % Handle to lick1 PSTH plot on CS4 trials
hPSTH5 = [];                                                % Handle to lick2 PSTH plot on CS1 trials
hPSTH6 = [];                                                % Handle to lick2 PSTH plot on CS2 trials
hPSTH7 = [];                                                % Handle to lick2 PSTH plot on CS3 trials
hPSTH8 = [];                                                % Handle to lick2 PSTH plot on CS4 trials
hPSTH9 = [];                                                % Handle to lick3 PSTH plot on CS1 trials
hPSTH10 = [];                                                % Handle to lick3 PSTH plot on CS2 trials
hPSTH11 = [];                                                % Handle to lick3 PSTH plot on CS3 trials
hPSTH12 = [];                                                % Handle to lick3 PSTH plot on CS4 trials


tempsolenoids = NaN(ceil((bgdsolenoidsinit+cuesinit)/sum(numtrials)),6); % 6 solenoids
tempsolenoidsct = [0 0 0 0 0 0];

tempcue1 = NaN(1,1);
tempcue2 = NaN(1,1);
tempcue3 = NaN(1,1);
tempcue4 = NaN(1,1);
templight1 = NaN(1,1); 
templight2 = NaN(1,1);
templight3 = NaN(1,1);
templight4 = NaN(1,1);
tempsecondcue1 = NaN(1,1);
tempsecondcue2 = NaN(1,1);
tempsecondcue3 = NaN(1,1);
tempsecondcue4 = NaN(1,1);
tempsecondlight1 = NaN(1,1);
tempsecondlight2 = NaN(1,1);
tempsecondlight3 = NaN(1,1);
tempsecondlight4 = NaN(1,1);

lick1s = textfield.lick1s;
lick2s = textfield.lick2s;
lick3s = textfield.lick3s;
bgdsolenoids = textfield.bgdsolenoids;
CS1sounds = textfield.CS1sounds;
CS2sounds = textfield.CS2sounds;
CS3sounds = textfield.CS3sounds;
CS4sounds = textfield.CS4sounds;
CS1lights = textfield.CS1lights;
CS2lights = textfield.CS2lights;
CS3lights = textfield.CS3lights;
CS4lights = textfield.CS4lights;
solenoid1s = textfield.solenoid1s;
solenoid2s = textfield.solenoid2s;
solenoid3s = textfield.solenoid3s;
solenoid4s = textfield.solenoid4s;
lickretractsolenoid1s = textfield.lickretractsolenoid1s;
lickretractsolenoid2s = textfield.lickretractsolenoid2s;

set(lick1s,'Value',0)
set(lick2s,'Value',0)
set(lick3s,'Value',0)
set(bgdsolenoids,'Value',0)
set(CS1sounds,'Value',0)
set(CS2sounds,'Value',0)
set(CS3sounds,'Value',0)
set(CS4sounds,'Value',0)
set(CS1lights,'Value',0)
set(CS2lights,'Value',0)
set(CS3lights,'Value',0)
set(CS4lights,'Value',0)
set(solenoid1s,'Value',0)
set(solenoid2s,'Value',0)
set(solenoid3s,'Value',0)
set(solenoid4s,'Value',0)
set(lickretractsolenoid1s,'Value',0)
set(lickretractsolenoid2s,'Value',0)


% setup plot
axes(actvAx)
h1 = gcf;
set(h1, 'Visible', 'off');
if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6 || experimentmode == 7
    plot(actvAx, xWindow,[0 0],'k','LineWidth',2);hold(actvAx,'on')                   % start figure for plots
    set(actvAx,'ytick',[], ...
               'ylim',[-sum(numtrials) yOffset+1], ...
               'ytick',[], ...
               'xlim',xWindow, ...
               'xtick',ticks, ...
               'xticklabel',labelsStr');        % set labels: Raster plot with y-axis containing trials. Chronological order = going from top to bottom
    xlabel(actvAx,'time (s)');
    ylabel(actvAx,'Trials');
elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 2 || experimentmode == 3
    plot(actvAx, [0 0;0 0],[0 0;-1 -1],'w');hold(actvAx,'on')
    xlabel(actvAx, 'time (s)');
    ylabel(actvAx,' ');
    xlim(actvAx,[-1000 durationtrialpartitionnocues+1000]);
    set(actvAx,'ytick',[],...
               'xtick',0:2000:durationtrialpartitionnocues,...
               'XTickLabel',num2str((0:2000:durationtrialpartitionnocues)'/1000));
end
drawnow;
%% Load to arduino

startT = clock;                                     % find time of start
startTStr = sprintf('%d:%d:%02.0f', ...
                    startT(4),startT(5),startT(6)); % format time
set(starttimefield,'Value',startTStr)           % display time
drawnow;

wID = 'MATLAB:serial:fscanf:unsuccessfulRead';      % warning id for serial read timeout
warning('off',wID)                                  % suppress warning

running = true;                                     % variable to control program
%%
try
    
%% Collect data from arduino
    while running
        read = [];
        if s.BytesAvailable > 0 % is data available to read? This avoids the timeout problem
            read = fscanf(s,'%f'); % scan for data sent only when data is available
        end
        if isempty(read) | length(read)<3
            drawnow
            continue
        end

        l = l + 1;
        eventlog(l,:) = read;                      % maps three things from read (code/time/nosolenoidflag)
        time = read(2);                             % record timestamp
        
        itemflag = read(3);                     % Indicates solenoid omission: if =1, no solenoid was actually given. Or cue identity: 0=first cue, 1=second cue
        
        code = read(1);                             % read identifier for data
        if code == 0                                % signifies "end of session"
            break
        end

        % Inputs from Arduino along with their "code" (defined below)
        %   0 = session end time
        %   1 = Lick1 onset
        %   2 = Lick1 offset
        %   3 = Lick2 onset
        %   4 = Lick2 offset                  
        %   5 = Lick3 onset
        %   6 = Lick3 offset
        %   7 = Background solenoid
        %   8 = Fixed solenoid 1
        %   9 = Fixed solenoid 2                
        %   10 = Fixed solenoid 3
        %   11 = Fixed solenoid 4
        %   12 = Lick retract solenoid 1
        %   13 = Lick retract solenoid 2
        %   14 = Vacuum   
        %   15 = sound 1
        %   16 = sound 2
        %   17 = sound 3                    % leave room for possible cues 
        %   18 = sound 4
        %   21 = light 1
        %   22 = light 2
        %   23 = light 3
        %   24 = light 4
        %   30 = frame
        %   31 = laser
        %   35 = lick retract solenoid 1 and 2
        

        
        if code == 1                                % Lick1 onset; BLUE
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6                  % Store lick1 timestamp for later plotting after trial ends
                lickct(1) = lickct(1) + 1;
                set(lick1s,'Value',(lickct(1)))  % change the gui input
                templicksct(1) = templicksct(1)+1;         % keep track of temp licktube number
                templicks(templicksct(1),1) = time;       % keep track of temporary licks timestamp
            elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 2 || experimentmode == 3 || experimentmode == 7    %If only Poisson solenoids are given or lick for rewards, plot when lick occurs in real time
                lickct(1) = lickct(1) + 1;
                set(lick1s,'Value',(lickct(1)))
                trial = floor(time/durationtrialpartitionnocues);
                temptrialdur = trial*durationtrialpartitionnocues;                
                plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'color',[0.2 0.6 1],'LineWidth',1);hold(actvAx,'on')
            end
        elseif code == 3                            % Lick2 onset; GREY
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6                      % Store lick1 timestamp for later plotting after trial ends
                lickct(2) = lickct(2) + 1;
                set(lick2s,'Value',(lickct(2)))
                templicksct(2) = templicksct(2)+1;
                templicks(templicksct(2),2) = time;
            elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 2 || experimentmode == 3 || experimentmode == 7    %If only Poisson solenoids are given or lick for rewards, plot when lick occurs in real time
                lickct(2) = lickct(2) + 1;
                set(lick2s,'Value',(lickct(2)))
                trial = floor(time/durationtrialpartitionnocues);
                temptrialdur = trial*durationtrialpartitionnocues;                
                plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',0.65*[1, 1, 1],'LineWidth',1);hold(actvAx,'on')
            end
        elseif code == 5                                % Lick3 onset; BROWN
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6                       % Store lick3 timestamp for later plotting after trial ends
                lickct(3) = lickct(3) + 1;
                set(lick3s,'Value',(lickct(3)))  % change the gui input
                templicksct(3) = templicksct(3)+1;         % keep track of temp licktube number
                templicks(templicksct(3),3) = time;       % keep track of temporary licks timestamp
            elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 2 || experimentmode == 3 || experimentmode == 7    %If only Poisson solenoids are given or lick for rewards, plot when lick occurs in real time
                lickct(3) = lickct(3) + 1;
                set(lick3s,'Value',(lickct(3)))
                trial = floor(time/durationtrialpartitionnocues);
                temptrialdur = trial*durationtrialpartitionnocues;                
                plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.3 0 0],'LineWidth',1);hold(actvAx,'on')
            end
        elseif code == 7                            
            % Background solenoid; cyan (solenoid1) [0.64, 0.08, 0.18] (solenoid2)
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6   
                bgdus = bgdus + 1;
                set(bgdsolenoids,'Value',(bgdus))    % change the gui background solenoid info
                for i = 1:4
                    if backgroundsolenoid == i
                        tempsolenoidsct(i) = tempsolenoidsct(i)+1;       % keep track of solenoid number
                        tempsolenoids(tempsolenoidsct(i),i) = time;     % keep track of tempsolenoid timestamp
                    end
                end
            elseif experimentmode == 2 %If only Poisson solenoids are given, plot when solenoid occurs
                bgdus = bgdus + 1;            
%                   bgdsolenoids(bgdus,1) = time;
                set(bgdsolenoids,'Value',(bgdus))
                trial = floor(time/durationtrialpartitionnocues);
                temptrialdur = trial*durationtrialpartitionnocues;
                if backgroundsolenoid == 1
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],...
                    [-trial;-trial-1],'c','LineWidth',2);hold(actvAx,'on')
                elseif backgroundsolenoid == 2
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],...
                    [-trial;-trial-1],'Color',[0.64, 0.08, 0.18],'LineWidth',2);hold(actvAx,'on')
                elseif backgroundsolenoid == 3
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],...
                    [-trial;-trial-1],'Color',[1 0.5 0],'LineWidth',2);hold(actvAx,'on')
                end                
            end
        elseif code == 8                            % Fixed solenoid 1; cyan, 'c'
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6
                if itemflag == 0                      % Indicates trial with solenoid
                    fxdus1 = fxdus1 + 1;            
                    set(solenoid1s,'Value',(fxdus1))
                    tempsolenoidsct(1) = tempsolenoidsct(1)+1;      % keep track of solenoid1 count
                    tempsolenoids(tempsolenoidsct(1), 1) = time;   % keep track of solenoid1 timestamp
                end
            elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                if itemflag == 0
                    fxdus1 = fxdus1 + 1;
                    set(solenoid1s,'Value',(fxdus1))
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'c','LineWidth',2);hold(actvAx,'on')
                end
            end
        elseif code == 9                            % Fixed solenoid 2; [0.64, 0.08, 0.18]
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6
                if itemflag == 0                      % Indicates trial with solenoid
                    fxdus2 = fxdus2 + 1;            
                    set(solenoid2s,'Value',(fxdus2))
                    tempsolenoidsct(2) = tempsolenoidsct(2)+1;      % keep track of solenoid2 count
                    tempsolenoids(tempsolenoidsct(2), 2) = time;   % keep track of solenoid2 timestamp
                end
             elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                 if itemflag == 0
                     fxdus2 = fxdus2 + 1;
                     set(solenoid2s,'Value',(fxdus2))
                     trial = floor(time/durationtrialpartitionnocues);
                     temptrialdur = trial*durationtrialpartitionnocues;
                     plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.64 0.08 0.18],'LineWidth',2);hold(actvAx,'on')
                 end
            end      
        elseif code == 10                            % Fixed solenoid 3; orange [1 0.5 0]
             if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6  
                if itemflag == 0                      % Indicates trial with solenoid
                    fxdus3 = fxdus3 + 1;            
                    set(solenoid3s,'Value',(fxdus3))
                    tempsolenoidsct(3) = tempsolenoidsct(3)+1;      % keep track of solenoid3 count
                    tempsolenoids(tempsolenoidsct(3), 3) = time;   % keep track of solenoid3 timestamp
                end 
             elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                 if itemflag == 0
                     fxdus3 = fxdus3 + 1;
                     set(solenoid3s,'Value',(fxdus3))
                     trial = floor(time/durationtrialpartitionnocues);
                     temptrialdur = trial*durationtrialpartitionnocues;
                     plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[1 0.5 0],'LineWidth',2);hold(actvAx,'on')
                 end
            end 
        elseif code == 11                            % Fixed solenoid 4; [0.72 0.27 1]
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6
                if itemflag == 0                      % Indicates trial with solenoid
                    fxdus4 = fxdus4 + 1;            
                    set(solenoid4s,'Value',(fxdus4))
                    tempsolenoidsct(4) = tempsolenoidsct(4)+1;      % keep track of solenoid4 count
                    tempsolenoids(tempsolenoidsct(4), 4) = time;   % keep track of solenoid4 timestamp
                end 
             elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                 if itemflag == 0
                     fxdus4 = fxdus4 + 1;
                     set(solenoid4s,'Value',(fxdus4))
                     trial = floor(time/durationtrialpartitionnocues);
                     temptrialdur = trial*durationtrialpartitionnocues;
                     plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.72 0.27 1],'LineWidth',2);hold(actvAx,'on')
                 end
            end 
        elseif code == 12                            % Lick retraction solenoid1; [0.3 0.75 0.93]
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode    
                if itemflag == 0                      % Indicates trial with solenoid
                    lickretractsolenoid1 = lickretractsolenoid1 + 1;            
                    set(lickretractsolenoid1s,'Value',(lickretractsolenoid1))
                    tempsolenoidsct(5) = tempsolenoidsct(5)+1;      % keep track of solenoid4 count
                    tempsolenoids(tempsolenoidsct(5), 5) = time;   % keep track of solenoid4 timestamp
                end 
             elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                 if itemflag == 0
                     lickretractsolenoid1 = lickretractsolenoid1 + 1;
                     set(lickretractsolenoid1s,'Value',(lickretractsolenoid1))
                     trial = floor(time/durationtrialpartitionnocues);
                     temptrialdur = trial*durationtrialpartitionnocues;
                     plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.3 0.75 0.93],'LineWidth',2);hold(actvAx,'on')
                 end
            end 
        elseif code == 13                            % Lick retraction solenoid2; [0.97 0.28 0.18]
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6   
                if itemflag == 0                      % Indicates trial with solenoid
                    lickretractsolenoid2 = lickretractsolenoid2 + 1;            
                    set(lickretractsolenoid2s,'Value',(lickretractsolenoid2))
                    tempsolenoidsct(6) = tempsolenoidsct(6)+1;      % keep track of solenoid4 count
                    tempsolenoids(tempsolenoidsct(6), 6) = time;   % keep track of solenoid4 timestamp
                end 
             elseif (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                 if itemflag == 0
                     lickretractsolenoid2 = lickretractsolenoid2 + 1;
                     set(lickretractsolenoid2s,'Value',(lickretractsolenoid2))
                     trial = floor(time/durationtrialpartitionnocues);
                     temptrialdur = trial*durationtrialpartitionnocues;
                     plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.97 0.28 0.18],'LineWidth',2);hold(actvAx,'on')
                 end
            end 
        elseif code == 14                            % Vaccum;            
            if (experimentmode == 1 && intervaldistribution<3) || experimentmode == 4 || experimentmode == 6  
                tempcuetovacuumdelay = NaN;
                if ~isnan(tempsecondcue1)
                    tempsecondcue1 = tempsecondcue1 - firstcueonset;
                elseif ~isnan(tempsecondcue2)
                    tempsecondcue2 = tempsecondcue2 - firstcueonset;
                elseif ~isnan(tempsecondcue3)
                    tempsecondcue3 = tempsecondcue3 - firstcueonset;
                elseif ~isnan(tempsecondcue4)
                    tempsecondcue4 = tempsecondcue4 - firstcueonset;
                elseif ~isnan(tempsecondlight1)
                    tempsecondlight1 = tempsecondlight1 - firstcueonset;
                elseif ~isnan(tempsecondlight2)
                    tempsecondlight2 = tempsecondlight2 - firstcueonset;
                elseif ~isnan(tempsecondlight3)
                    tempsecondlight3 = tempsecondlight3 - firstcueonset;
                elseif ~isnan(tempsecondlight4)
                    tempsecondlight4 = tempsecondlight4 - firstcueonset;
                end
                if ~isnan(tempcue1)                      % indicates there is cue1
                    tempcuetovacuumdelay = time - tempcue1;      
                    for i=1:3
                        templicksPSTH1(1:length(templicks(:,i)),cs1,i) = templicks(:,i)-time+tempcuetovacuumdelay; % run over each licktube
                    end                
                    tempcue1 = 0;
                elseif ~isnan(tempcue2)
                    tempcuetovacuumdelay = time - tempcue2;
                    for i=1:3
                        templicksPSTH2(1:length(templicks(:,i)),cs2,i) = templicks(:,i)-time+tempcuetovacuumdelay;
                    end
                    tempcue2 = 0;
                elseif ~isnan(tempcue3)
                    tempcuetovacuumdelay = time - tempcue3;
                    for i=1:3
                        templicksPSTH3(1:length(templicks(:,i)),cs3,i) = templicks(:,i)-time+tempcuetovacuumdelay;
                    end
                    tempcue3 = 0;
                elseif ~isnan(tempcue4)
                    tempcuetovacuumdelay = time - tempcue4;
                    for i=1:3
                        templicksPSTH4(1:length(templicks(:,i)),cs4,i) = templicks(:,i)-time+tempcuetovacuumdelay;
                    end
                    tempcue4 = 0;
                end
                if ~isnan(templight1)                      % indicates there is light1
                    tempcuetovacuumdelay = time - templight1;      
                    for i=1:3
                        templicksPSTH1(1:length(templicks(:,i)),light1,i) = templicks(:,i)-time+tempcuetovacuumdelay; % run over each licktube
                    end                
                    templight1 = 0;
                elseif ~isnan(templight2)
                    tempcuetovacuumdelay = time - templight2;
                    for i=1:3
                        templicksPSTH2(1:length(templicks(:,i)),light2,i) = templicks(:,i)-time+tempcuetovacuumdelay;
                    end
                    templight2 = 0;
                elseif ~isnan(templight3)
                    tempcuetovacuumdelay = time - templight3;
                    for i=1:3
                        templicksPSTH3(1:length(templicks(:,i)),light3,i) = templicks(:,i)-time+tempcuetovacuumdelay;
                    end
                    templight3 = 0;
                elseif ~isnan(templight4)
                    tempcuetovacuumdelay = time - templight4;
                    for i=1:3
                        templicksPSTH4(1:length(templicks(:,i)),light4,i) = templicks(:,i)-time+tempcuetovacuumdelay;
                    end
                    templight4 = 0;
                end

                tempsolenoids = tempsolenoids-time+tempcuetovacuumdelay; %find timestamps wrt vacuum         
                templicks = templicks-time+tempcuetovacuumdelay;

                % Raster plot
                cs = cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4;

                plot(actvAx,[templicks(:,1) templicks(:,1)],[-(cs-1) -cs],'color',[0.2 0.6 1],'LineWidth',1);hold(actvAx,'on')    % lick1            
                plot(actvAx,[templicks(:,2) templicks(:,2)],[-(cs-1) -cs],'Color',0.65*[1, 1, 1],'LineWidth',1);hold(actvAx,'on')   %lick2            
                plot(actvAx,[templicks(:,3) templicks(:,3)],[-(cs-1) -cs],'Color',[0.3 0 0],'LineWidth',1);hold(actvAx,'on')   % lick3            

                plot(actvAx,[tempsolenoids(:,1) tempsolenoids(:,1)],[-(cs-1) -cs],'c','LineWidth',2);hold(actvAx,'on')      % solenoid1
                plot(actvAx,[tempsolenoids(:,2) tempsolenoids(:,2)],[-(cs-1) -cs],'Color',[0.64, 0.08, 0.18],'LineWidth',2);hold(actvAx,'on')    % solenoid2
                plot(actvAx,[tempsolenoids(:,3) tempsolenoids(:,3)],[-(cs-1) -cs],'Color',[1 0.5 0],'LineWidth',2);hold(actvAx,'on')      % solenoid3
                plot(actvAx,[tempsolenoids(:,4) tempsolenoids(:,4)],[-(cs-1) -cs],'Color',[0.72, 0.27, 1],'LineWidth',2);hold(actvAx,'on')      % solenoid4
                plot(actvAx,[tempsolenoids(:,5) tempsolenoids(:,5)],[-(cs-1) -cs],'Color',[0.3 0.75 0.93],'LineWidth',2);hold(actvAx,'on')     % lickretractsolenoid1 
                plot(actvAx,[tempsolenoids(:,6) tempsolenoids(:,6)],[-(cs-1) -cs],'Color',[0.97 0.28 0.18],'LineWidth',2);hold(actvAx,'on')       % lickretractsolenoid2
                
                plot(actvAx,[tempcue1 tempcue1],[-(cs-1) -cs],'g','LineWidth',2);hold(actvAx,'on')       % cue1
                plot(actvAx,[tempcue2 tempcue2],[-(cs-1) -cs],'r','LineWidth',2);hold(actvAx,'on')       % cue2
                plot(actvAx,[tempcue3 tempcue3],[-(cs-1) -cs],'b','LineWidth',2);hold(actvAx,'on')       % cue3
                plot(actvAx,[tempcue4 tempcue4],[-(cs-1) -cs],'Color',[0.49 0.18 0.56],'LineWidth',2); hold(actvAx,'on')       % cue 4
                plot(actvAx,[templight1 templight1],[-(cs-1) -cs],'Color',[0 0.45 0.74],'LineWidth',2);hold(actvAx,'on')       % light1
                plot(actvAx,[templight2 templight2],[-(cs-1) -cs],'Color',[0.93 0.69 0.13],'LineWidth',2);hold(actvAx,'on')    % light2
                plot(actvAx,[templight3 templight3],[-(cs-1) -cs],'Color',[0.85 0.33 0.1],'LineWidth',2);hold(actvAx,'on')    % light3
                plot(actvAx,[templight4 templight4],[-(cs-1) -cs],'Color',[0.43 0.68 0.1],'LineWidth',2);hold(actvAx,'on')     % light4

                plot(actvAx,[tempsecondcue1 tempsecondcue1],[-(cs-1) -cs],'g','LineWidth',2);hold(actvAx,'on')       % second cue1
                plot(actvAx,[tempsecondcue2 tempsecondcue2],[-(cs-1) -cs],'r','LineWidth',2);hold(actvAx,'on')      % second cue2
                plot(actvAx,[tempsecondcue3 tempsecondcue3],[-(cs-1) -cs],'b','LineWidth',2);hold(actvAx,'on')       % second cue3
                plot(actvAx,[tempsecondcue4 tempsecondcue4],[-(cs-1) -cs],'Color',[0.49 0.18 0.56],'LineWidth',2); hold(actvAx,'on')       % second cue 4
                plot(actvAx,[tempsecondlight1 tempsecondlight1],[-(cs-1) -cs],'Color',[0 0.45 0.74],'LineWidth',2);hold(actvAx,'on')       % second light1
                plot(actvAx,[tempsecondlight2 tempsecondlight2],[-(cs-1) -cs],'Color',[0.93 0.69 0.13],'LineWidth',2);hold(actvAx,'on')    % second light2
                plot(actvAx,[tempsecondlight3 tempsecondlight3],[-(cs-1) -cs],'Color',[0.85 0.33 0.1],'LineWidth',2);hold(actvAx,'on')     % second light3
                plot(actvAx,[tempsecondlight4 tempsecondlight4],[-(cs-1) -cs],'Color',[0.43 0.68 0.1],'LineWidth',2);hold(actvAx,'on')     % second light4


                % Begin PSTH plotting
                delete(hPSTH1);delete(hPSTH2);delete(hPSTH3);delete(hPSTH4); %Clear previous PSTH plots  
                delete(hPSTH5);delete(hPSTH6);delete(hPSTH7);delete(hPSTH8); %Clear previous PSTH plots  
                delete(hPSTH9);delete(hPSTH10);delete(hPSTH11); delete(hPSTH12);%Clear previous PSTH plots      

                if ~isempty(templicksPSTH1)
                    if sum(~isnan(templicksPSTH1(:,:,1)), 'all')>0
                        temp = templicksPSTH1(:,:,1);
                        nPSTH1 = histc(temp(~isnan(temp)),xbins); % Count licks1 in each bin for all trials until now
                        nPSTH1 = nPSTH1/max(nPSTH1); % Plot PSTH for CS1 scaled to the available range on the y-axis 
                        hPSTH1 = plot(actvAx,xbins,nPSTH1*yOffset,'Marker','o','MarkerFaceColor',[0.47 0.67 0.19],'Color',[0.47 0.67 0.19]);
                        hold(actvAx,'on');
                    end
                    if sum(~isnan(templicksPSTH1(:,:,2)), 'all')>0
                        assignin('base','templicksPSTH1',templicksPSTH1);
                        assignin('base','xbins',xbins);
                        temp = templicksPSTH1(:,:,2);
                        nPSTH1 = histc(temp(~isnan(temp)),xbins); % Count licks2 in each bin for all trials until now
                        nPSTH1 = nPSTH1/max(nPSTH1); % Plot PSTH for CS1 scaled to the available range on the y-axis            
                        hPSTH5 = plot(actvAx,xbins,nPSTH1*yOffset,'Marker','o','MarkerFaceColor',[0.27 0.67 0.19],'Color',[0.27 0.67 0.19]);
    %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH1(:,:,3)), 'all')>0
                        assignin('base','templicksPSTH1',templicksPSTH1);
                        assignin('base','xbins',xbins);
                        temp = templicksPSTH1(:,:,3);
                        nPSTH1 = histc(temp(~isnan(temp)),xbins); % Count licks3 in each bin for all trials until now
                        nPSTH1 = nPSTH1/max(nPSTH1); % Plot PSTH for CS1 scaled to the available range on the y-axis            
                        hPSTH9 = plot(actvAx,xbins,nPSTH1*yOffset,'Marker','o','MarkerFaceColor',[0.09 0.43 0.02],'Color',[0.09 0.43 0.02]);
    %                     hold on;
                    end
                end
                if ~isempty(templicksPSTH2)
                    if sum(~isnan(templicksPSTH2(:,:,1)), 'all')>0
                        temp = templicksPSTH2(:,:,1);
                        nPSTH2 = histc(temp(~isnan(temp)),xbins); % Count licks1 in each bin for all trials until now
                        nPSTH2 = nPSTH2/max(nPSTH2); % Plot PSTH for CS2 scaled to the available range on the y-axis
                        hPSTH2 = plot(actvAx,xbins,nPSTH2*yOffset,'Marker','o','MarkerFaceColor',[1 0.6 0.78],'Color',[1 0.6 0.78]);
    %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH2(:,:,2)), 'all')>0
                        temp = templicksPSTH2(:,:,2);
                        nPSTH2 = histc(temp(~isnan(temp)),xbins); % Count licks2 in each bin for all trials until now
                        nPSTH2 = nPSTH2/max(nPSTH2); % Plot PSTH for CS2 scaled to the available range on the y-axis
                        hPSTH6 = plot(actvAx,xbins,nPSTH2*yOffset,'Marker','o','MarkerFaceColor',[1 0.35 0.78],'Color',[1 0.35 0.78]);
    %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH2(:,:,3)), 'all')>0
                        temp = templicksPSTH2(:,:,3);
                        nPSTH2 = histc(temp(~isnan(temp)),xbins); % Count licks3 in each bin for all trials until now
                        nPSTH2 = nPSTH2/max(nPSTH2); % Plot PSTH for CS2 scaled to the available range on the y-axis
                        hPSTH10 = plot(actvAx,xbins,nPSTH2*yOffset,'Marker','o','MarkerFaceColor',[0.79 0.03 0.56],'Color',[0.79 0.03 0.56]);
    %                     hold on;
                    end
                end
                if ~isempty(templicksPSTH3)
                    if sum(~isnan(templicksPSTH3(:,:,1)), 'all')>0
                        temp = templicksPSTH3(:,:,1);
                        nPSTH3 = histc(temp(~isnan(temp)),xbins); % Count licks1 in each bin for all trials until now
                        nPSTH3 = nPSTH3/max(nPSTH3); % Plot PSTH for CS3 scaled to the available range on the y-axis
                        hPSTH3 = plot(actvAx,xbins,nPSTH3*yOffset,'Marker','o','MarkerFaceColor',[0.2 0.6 1],'Color',[0.2 0.6 1]);
    %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH3(:,:,2)), 'all')>0
                        temp = templicksPSTH3(:,:,2);
                        nPSTH3 = histc(temp(~isnan(temp)),xbins); % Count licks2 in each bin for all trials until now
                        nPSTH3 = nPSTH3/max(nPSTH3); % Plot PSTH for CS3 scaled to the available range on the y-axis
                        hPSTH7 = plot(actvAx,xbins,nPSTH3*yOffset,'Marker','o','MarkerFaceColor',[0.2 0.35 1],'Color',[0.2 0.35 1]);
    %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH3(:,:,3)), 'all')>0
                        temp = templicksPSTH3(:,:,3);
                        nPSTH3 = histc(temp(~isnan(temp)),xbins); % Count licks3 in each bin for all trials until now
                        nPSTH3 = nPSTH3/max(nPSTH3); % Plot PSTH for CS3 scaled to the available range on the y-axis
                        hPSTH11 = plot(actvAx,xbins,nPSTH3*yOffset,'Marker','o','MarkerFaceColor',[0.03 0.14 0.69],'Color',[0.03 0.14 0.69]);
    %                     hold on;
                    end
                end
                if ~isempty(templicksPSTH4)
                    if sum(~isnan(templicksPSTH4(:,:,1)), 'all')>0
                        temp = templicksPSTH4(:,:,1);
                        nPSTH4 = histc(temp(~isnan(temp)),xbins); % Count licks1 in each bin for all trials until now
                        nPSTH4 = nPSTH4/max(nPSTH4); % Plot PSTH for CS3 scaled to the available range on the y-axis
                        hPSTH4 = plot(actvAx,xbins,nPSTH4*yOffset,'Marker','o','MarkerFaceColor',[0.88 0.88 0.49],'Color',[0.97 0.97 0.47]);
                        %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH4(:,:,2)), 'all')>0
                        temp = templicksPSTH4(:,:,2);
                        nPSTH4 = histc(temp(~isnan(temp)),xbins); % Count licks2 in each bin for all trials until now
                        nPSTH4 = nPSTH4/max(nPSTH4); % Plot PSTH for CS3 scaled to the available range on the y-axis
                        hPSTH8 = plot(actvAx,xbins,nPSTH4*yOffset,'Marker','o','MarkerFaceColor',[0.79 0.79 0.05],'Color',[0.79 0.79 0.05]);
                        %                     hold on;
                    end
                    if sum(~isnan(templicksPSTH4(:,:,3)), 'all')>0
                        temp = templicksPSTH4(:,:,3);
                        nPSTH4 = histc(temp(~isnan(temp)),xbins); % Count licks3 in each bin for all trials until now
                        nPSTH4 = nPSTH4/max(nPSTH4); % Plot PSTH for CS3 scaled to the available range on the y-axis
                        hPSTH12 = plot(actvAx,xbins,nPSTH4*yOffset,'Marker','o','MarkerFaceColor',[0.69 0.69 0.08],'Color',[0.69 0.69 0.08]);
    %                     hold on;
                    end
                end
                drawnow
                % End PSTH plotting

                % Re-initialize the temp variables
                templicks = NaN(ceil(licksinit/sum(numtrials)),3);
                templicksct = [0, 0, 0]; %count of temp licks. Calculated explicitly to speed up indexing
                tempsolenoid1s = NaN(ceil((bgdsolenoidsinit+cuesinit)/sum(numtrials)),1);
                tempsolenoid2s = NaN(ceil((bgdsolenoidsinit+cuesinit)/sum(numtrials)),1);
                tempsolenoid3s = NaN(ceil((bgdsolenoidsinit+cuesinit)/sum(numtrials)),1);
                tempsolenoid4s = NaN(ceil((bgdsolenoidsinit+cuesinit)/sum(numtrials)),1);            
                tempsolenoid1sct = 0;
                tempsolenoid2sct = 0;
                tempsolenoid3sct = 0;
                tempsolenoid4sct = 0;
                tempcue1 = NaN;
                tempcue2 = NaN;
                tempcue3 = NaN;  
                tempcue4 = NaN;
                tempsecondcue1 = NaN;
                tempsecondcue2 = NaN;
                tempsecondcue3 = NaN;
                tempseconccue4 = NaN;
                templight1 = NaN; 
                templight2 = NaN;
                templight3 = NaN;
                templight4 = NaN;
                tempsecondlight1 = NaN;
                tempsecondlight2 = NaN;
                tempsecondlight3 = NaN;
                tempsecondlight4 = NaN;
                firstcueonset = NaN;

            end
        elseif code == 15                            % CS1 sound cue onset; GREEN
            if itemflag == 0
                cs1 = cs1 + 1;
                set(CS1sounds,'Value',(cs1))
                tempcue1 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3  || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'g','LineWidth',2);hold(actvAx,'on')
                end
                firstcueonset = time;
            elseif itemflag == 1
                cs1 = cs1 + 1;
                both1 = both1 + 1;
                tempsecondcue1 = time;
                set(CS1sounds,'Value',(cs1))
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'g','LineWidth',2);hold on
            end
        elseif code == 16                            % CS2 sound cue onset; RED
            if itemflag == 0
                cs2 = cs2 + 1;
                set(CS2sounds,'Value',(cs2))
                tempcue2 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'r','LineWidth',2);hold(actvAx,'on')
                end
                firstcueonset = time;
            elseif itemflag == 1
                cs2 = cs2 + 1;
                both2 = both2 +1;
                set(CS2sounds,'Value',(cs2))
                tempsecondcue2 = time;
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'r','LineWidth',2);hold on
            end
        elseif code == 17                            % CS3 sound cue onset; BLUE
            if itemflag == 0
                cs3 = cs3 + 1;
                set(CS3sounds,'Value',(cs3))
                tempcue3 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'b','LineWidth',2);hold(actvAx,'on')
                end
                firstcueonset = time;
            elseif itemflag == 1
                cs3 = cs3 + 1;
                both3 = both3 +1;
                set(CS3sounds,'Value',(cs3))
                tempsecondcue3 = time;
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'b','LineWidth',2);hold on
            end
        elseif code == 18                            % CS4 sound cue onset;
            if itemflag == 0
                cs4 = cs4 + 1;
                set(CS4sounds,'Value',(cs4))
                tempcue4 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.49 0.18 0.56],'LineWidth',2);hold(actvAx,'on')
                end
                firstcueonset = time;
            elseif itemflag == 1
                cs4 = cs4 + 1;
                both4 = both4 +1;
                set(CS4sounds,'Value',(cs4))
                tempsecondcue4 = time;
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'b','LineWidth',2);hold on
            end
        elseif code == 21                            % CS1 light onset;
            if itemflag == 0
                light1 = light1 + 1;
                set(CS1lights,'Value',(light1))
                templight1 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0 0.45 0.74],'LineWidth',2);hold(actvAx,'on')
                end
                firstcueonset = time;
            elseif itemflag == 1
                light1 = light1 +1;
                both1 = both1 +1;
                tempsecondlight1 = time;
                set(CS1lights,'Value',(light1))
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;                
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0 0.45 0.74],'LineWidth',2);hold on
            end
        elseif code == 22                            % CS2 light onset;
            if itemflag == 0
                light2 = light2 + 1;
                set(CS2lights,'Value',(light2))
                templight2 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.93 0.69 0.13],'LineWidth',2);hold(actvAx,'on')
                end
                firstcueonset = time;
            elseif itemflag == 1
                light2 = light2 + 1;
                both2 = both2 +1;
                tempsecondlight2 = time;
                set(CS2lights,'Value',(light2))
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.93 0.69 0.13],'LineWidth',2);hold on
            end
        elseif code == 23                            % CS3 light onset;
            if itemflag == 0
                light3 = light3 + 1;
                set(CS3lights,'Value',(light3))
                templight3 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.85 0.33 0.1],'LineWidth',2);hold(actvAx,'on') %light cue3
                end
                firstcueonset = time;
            elseif itemflag == 1
                light3 = light3 + 1;
                both3 = both3 + 1;
                tempsecondlight3 = time;
                set(CS3lights,'Value',(light3))
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.85 0.33 0.1],'LineWidth',2);hold on %light cue3
            end
        elseif code == 24                            % CS4 light onset;
            if itemflag == 0
                light4 = light4 + 1;
                set(CS4lights,'Value',(light4))
                templight4 = time;
                if cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4<sum(numtrials)
                    fprintf('Executing trial %d\n',cs1+cs2+cs3+cs4+light1+light2+light3+light4-both1-both2-both3-both4);
                end
                if (experimentmode == 1 && intervaldistribution>2) || experimentmode == 3 || experimentmode == 7
                    trial = floor(time/durationtrialpartitionnocues);
                    temptrialdur = trial*durationtrialpartitionnocues;
                    plot(actvAx,[time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.43 0.68 0.1],'LineWidth',2);hold(actvAx,'on') %light cue4
                end
                firstcueonset = time;
            elseif itemflag == 1
                light4 = light4 + 1;
                both4 = both4 + 1;
                tempsecondlight4 = time;
                set(CS4lights,'Value',(light4))
%                 trial = floor(time/durationtrialpartitionnocues);
%                 temptrialdur = trial*durationtrialpartitionnocues;
%                 plot([time-temptrialdur;time-temptrialdur],[-trial;-trial-1],'Color',[0.85 0.33 0.1],'LineWidth',2);hold on %light cue3
            end
        end
    end
    
    if l < logInit
        eventlog = eventlog(1:l,:);   % smaller eventlog
    end
    

%% Save data

    format = 'yymmdd-HHMMSS';
    date = datestr(now,format);
    
    if experimentmode == 1
        str = 'cues_';
    elseif experimentmode == 2
        str = 'randomrewards_';
    elseif experimentmode == 3
        str = 'lickforreward_';
    elseif experimentmode == 4
        str = 'decisionmaking_';
    elseif experimentmode == 5
        str = 'serialporttest_';
    elseif experimentmode == 6
        str = 'ramptiming_';
    elseif experimentmode == 7
        str = 'delaydiscounting_';
    end
    
%     if randlaserflag==0 && laserlatency==0 && laserduration==CS_t_fxd(1)
%         laserstr = 'lasercue_';
%     elseif randlaserflag==0 && laserlatency==CS_t_fxd(1) && laserduration==CS_t_fxd(1)
%         laserstr = 'lasersolenoid_';
%     elseif randlaserflag==0 && laserlatency==0 && laserduration==1000
%         laserstr = 'lasercueonset_';
%     elseif randlaserflag==0 && laserlatency==2000 && laserduration==1000
%         laserstr = 'lasercuetrace_';
%     elseif randlaserflag ==1
%         laserstr = 'randlaser_';
%     else
%         laserstr = [];
%     end
%     if lasertrialbytrialflag==1 && laserduration > 0
%         laserstr = [laserstr 'trialbytriallaser_'];
%     end
%     
%     if trialbytrialbgdsolenoidflag == 1
%         bgdsolenoidstr = 'trialbytrialbgd_';
%     else
%         bgdsolenoidstr = [];
%     end
%     
%     if sum(CSopentime) == 0
%         extinctionstr = 'extinction_';
%     else
%         extinctionstr = [];
%     end
%     
%     probstr = ['CSprob' sprintf('_%u', CSprob)];

    param = regexprep(params, '+', ' ');
    param = str2num(param);
    
    params = struct();
    paramnames = string(["numtrials"; "CSfreq"; "CSsolenoid"; "CSprob"; "CSopentime";...
                 "CSdur"; "CS_t_fxd"; "CSpulse"; "CSspeaker"; "golickreq"; "golicktube"; "CSsignal";...
                 "meanITI"; "maxITI"; "minITI"; "intervaldistribution"; "backgroundsolenoid"; "T_bgd"; "r_bgd"; ...
                 "mindelaybgdtocue"; "mindelayfxdtobgd"; "experimentmode"; ...
                 "trialbytrialbgdsolenoidflag"; "totPoisssolenoid"; "reqlicknum";...
                 "licksolenoid"; "lickprob"; "lickopentime"; "delaytoreward"; "delaytolick";...
                 "minrewards"; "signaltolickreq"; "soundsignalpulse"; "soundfreq"; "sounddur"; "lickspeaker";...
                 "laserlatency"; "laserduration"; "randlaserflag"; "laserpulseperiod"; "laserpulseoffperiod";...
                 "lasertrialbytrialflag"; "maxdelaycuetovacuum"; "CSlight"; "ratioschedule";...
                 "intervalschedule"; "licklight"; "CS1lasercheck";...
                 "CS2lasercheck"; "CS3lasercheck"; "CS4lasercheck";"fixedsidecheck"; "Rewardlasercheck";...
                 "CSrampmaxdelay"; "CSrampexp"; "CSincrease"; "delaybetweensoundandlight";...
                 "CSsecondcue";"CSsecondcuefreq";"CSsecondcuespeaker";"CSsecondcuelight"; ...
                 "progressivemultiplier"]);

        params.(paramnames(1)) = param(1:4);                        % numtrials (3)
        params.(paramnames(2)) = param(5:8);                        % CS frequency (3)
        params.(paramnames(3)) = param(9:16);                       % CS solenoids (6)
        params.(paramnames(4)) = param(17:24);                      % CS probability (6)
        params.(paramnames(5)) = param(25:32);                      % CS opentime (6)
        params.(paramnames(6)) = param(33:36);                      % CS duration (6)
        params.(paramnames(7)) = param(37:44);                      % CS delay to fxd reward (6)
        params.(paramnames(8)) = param(45:48);                      % CS pulse or not(3)
        params.(paramnames(9)) = param(49:52);                      % CS speaker number (3)
        params.(paramnames(10)) = param(53:56);                     % CS go lick requiremet number (3)
        params.(paramnames(11)) = param(57:60);                     % go lick tube (3)
        params.(paramnames(12)) = param(61:64);                     % CS signal type (3)
        params.(paramnames(13)) = param(65);                        % mean ITI
        params.(paramnames(14)) = param(66);                        % max ITI 
        params.(paramnames(15)) = param(67);                        % min ITI 
        params.(paramnames(16)) = param(68);                        % exponential ITI flag
        params.(paramnames(17)) = param(69);                        % background solenoid number
        params.(paramnames(18)) = param(70);                        % background solenoid period 
        params.(paramnames(19)) = param(71);                        % background solenoid magnitude
        params.(paramnames(20)) = param(72);                        % min delay background solenoid to cue
        params.(paramnames(21)) = param(73);                        % min delay background solenoid to fixed solenoid
        params.(paramnames(22)) = param(74);                        % experiment mode
        params.(paramnames(23)) = param(75);                        % trial by trial bgd solenoid flag
        params.(paramnames(24)) = param(76);                        % total bgd rewards
        params.(paramnames(25)) = param(77:78);                     % number of required licks (2)
        params.(paramnames(26)) = param(79:80);                     % lick solenoid number (2)
        params.(paramnames(27)) = param(81:82);                     % lick to reward probability (2)
        params.(paramnames(28)) = param(83:84);                     % lick reward open time (2)
        params.(paramnames(29)) = param(85:86);                     % lick delay to reward (2)
        params.(paramnames(30)) = param(87:88);                     % delay to next lick (2)
        params.(paramnames(31)) = param(89:90);                     % min number of rewards on each lick tube
        params.(paramnames(32)) = param(91:92);                     % signal type to lick requirement (2)
        params.(paramnames(33)) = param(93:94);                     % signal pulse or not
        params.(paramnames(34)) = param(95:96);                     % sound cue frequency (2)
        params.(paramnames(35)) = param(97:98);                     % signal duration (2)
        params.(paramnames(36)) = param(99:100);                     % lick speaker number (2)
        params.(paramnames(37)) = param(101);                        % laser latency wrt cue
        params.(paramnames(38)) = param(102);                        % laser duration
        params.(paramnames(39)) = param(103);                        % random laser flag
        params.(paramnames(40)) = param(104);                        % laser pulse period
        params.(paramnames(41)) = param(105);                        % laser pulse off period
        params.(paramnames(42)) = param(106);                        % laser trial by trialflag
        params.(paramnames(43)) = param(107);                        % max delay cue to vacuum
        params.(paramnames(44)) = param(108:111);                     % CS light number (3)
        params.(paramnames(45)) = param(112:113);                     % lick ratio schedule indicator: 0=fixed,1=variable,2=progressive (2)
        params.(paramnames(46)) = param(114:115);                     % lick interval schedule indicator: 0=fixed,1=variable,2=progressive (2)
        params.(paramnames(47)) = param(116:117);                    % lick light number (2)
        params.(paramnames(48)) = param(118);                       % CS1 laser check flag
        params.(paramnames(49)) = param(119);                       % CS2 laser check flag
        params.(paramnames(50)) = param(120);                       % CS3 laser check flag
        params.(paramnames(51)) = param(121);                       % CS4 laser check flag
        params.(paramnames(52)) = param(122:123);                   % lick fixed side check (2)
        params.(paramnames(53)) = param(124);                       % Reward laser check flag
        params.(paramnames(54)) = param(125:128);                   % CS max ramp delay 
        params.(paramnames(55)) = param(129:132);                   % CS ramp exponential factor
        params.(paramnames(56)) = param(133:136);                   % CS increase
        params.(paramnames(57)) = param(137:140);                   % delay between sound and light cue if both are present 
        params.(paramnames(58)) = param(141:144);                   % CS second cue typessss
        params.(paramnames(59)) = param(145:148);                   % CS second cue frequency 
        params.(paramnames(60)) = param(149:152);                   % CS second cue speaker number
        params.(paramnames(61)) = param(153:156);                   % CS second cue light number
        params.(paramnames(62)) = param(157:158);                   % progressive ratio or interval multiplier (2)
  
    assignin('base','eventlog',eventlog);
%     file = [saveDir fname '_' num2str(r_bgd) '_' num2str(T_bgd) '_'  str probstr laserstr bgdsolenoidstr extinctionstr date '.mat'];
    file = [saveDir fname '_' str date '.mat'];
    save(file, 'eventlog', 'params')

    % camera: make this part unable if you don't use a camera
%     [frames,time] = getdata(cam, get(cam,'FramesAvailable'));
%     video.frames = squeeze(frames);
%     video.times = time;
%     save(file,'video','-append')
    
catch exception
    if l < logInit
        eventlog = eventlog(1:l,:);
    end
    
    fprintf(s,'1');                                  % send stop signal to arduino; 49 in Arduino is the ASCII code for 1
    disp('Error running program.')
    format = 'yymmdd-HHMMSS';
    date = datestr(now,format);
    
    
    if experimentmode == 1
        str = 'cues_';
    elseif experimentmode == 2
        str = 'randomrewards_';
    elseif experimentmode == 3
        str = 'lickforreward_';
    elseif experimentmode == 4
        str = 'decisionmaking_';
    elseif experimentmode == 5
        str = 'serialporttest_';
    elseif experimentmode == 6
        str = 'ramptiming_';
    elseif experimentmode == 7
        str = 'delaydiscounting_';
    end
    
%     if randlaserflag==0 && laserlatency==0 && laserduration==CS_t_fxd(1)
%         laserstr = 'lasercue_';
%     elseif randlaserflag==0 && laserlatency==CS_t_fxd(1) && laserduration==CS_t_fxd(1)
%         laserstr = 'lasersolenoid_';
%     elseif randlaserflag==0 && laserlatency==0 && laserduration==1000
%         laserstr = 'lasercueonset_';
%     elseif randlaserflag==0 && laserlatency==2000 && laserduration==1000
%         laserstr = 'lasercuetrace_';
%     elseif randlaserflag ==1
%         laserstr = 'randlaser_';
%     else
%         laserstr = [];
%     end
%     
%     if lasertrialbytrialflag==1 && laserduration > 0
%         laserstr = [laserstr 'trialbytriallaser_'];
%     end
%     
%     if trialbytrialbgdsolenoidflag == 1
%         bgdsolenoidstr = 'trialbytrialbgd_';
%     else
%         bgdsolenoidstr = [];
%     end
%     
%     if sum(CSopentime) == 0
%         extinctionstr = 'extinction_';
%     else
%         extinctionstr = [];
%     end
%     
%     probstr = ['CSprob' sprintf('_%u', CSprob)];
    
    assignin('base','eventlog',eventlog);
    
%     file = [saveDir fname '_' num2str(r_bgd) '_' num2str(T_bgd) '_'  str probstr laserstr bgdsolenoidstr extinctionstr date '.mat'];
    file = [saveDir '_error_' fname '_' str date '.mat'];
    if ~isstruct(params)
    param = regexprep(params, '+', ' '); 
    param = str2num(param);

    params = struct();
    paramnames = string(["numtrials"; "CSfreq"; "CSsolenoid"; "CSprob"; "CSopentime";...
                 "CSdur"; "CS_t_fxd"; "CSpulse"; "CSspeaker"; "golickreq"; "golicktube"; "CSsignal";...
                 "meanITI"; "maxITI"; "minITI"; "intervaldistribution"; "backgroundsolenoid"; "T_bgd"; "r_bgd"; ...
                 "mindelaybgdtocue"; "mindelayfxdtobgd"; "experimentmode"; ...
                 "trialbytrialbgdsolenoidflag"; "totPoisssolenoid"; "reqlicknum";...
                 "licksolenoid"; "lickprob"; "lickopentime"; "delaytoreward"; "delaytolick";...
                 "minrewards"; "signaltolickreq"; "soundsignalpulse"; "soundfreq"; "sounddur"; "lickspeaker";...
                 "laserlatency"; "laserduration"; "randlaserflag"; "laserpulseperiod"; "laserpulseoffperiod";...
                 "lasertrialbytrialflag"; "maxdelaycuetovacuum"; "CSlight"; "ratioschedule";...
                 "intervalschedule"; "licklight"; "CS1lasercheck";...
                 "CS2lasercheck"; "CS3lasercheck"; "CS4lasercheck";"fixedsidecheck"; "Rewardlasercheck";...
                 "CSrampmaxdelay"; "CSrampexp"; "CSincrease"; "delaybetweensoundandlight";...
                 "CSsecondcue";"CSsecondcuefreq";"CSsecondcuespeaker";"CSsecondcuelight"; ...
                 "progressivemultiplier"]);

        params.(paramnames(1)) = param(1:4);                        % numtrials (3)
        params.(paramnames(2)) = param(5:8);                        % CS frequency (3)
        params.(paramnames(3)) = param(9:16);                       % CS solenoids (6)
        params.(paramnames(4)) = param(17:24);                      % CS probability (6)
        params.(paramnames(5)) = param(25:32);                      % CS opentime (6)
        params.(paramnames(6)) = param(33:36);                      % CS duration (6)
        params.(paramnames(7)) = param(37:44);                      % CS delay to fxd reward (6)
        params.(paramnames(8)) = param(45:48);                      % CS pulse or not(3)
        params.(paramnames(9)) = param(49:52);                      % CS speaker number (3)
        params.(paramnames(10)) = param(53:56);                     % CS go lick requiremet number (3)
        params.(paramnames(11)) = param(57:60);                     % go lick tube (3)
        params.(paramnames(12)) = param(61:64);                     % CS signal type (3)
        params.(paramnames(13)) = param(65);                        % mean ITI
        params.(paramnames(14)) = param(66);                        % max ITI 
        params.(paramnames(15)) = param(67);                        % min ITI 
        params.(paramnames(16)) = param(68);                        % exponential ITI flag
        params.(paramnames(17)) = param(69);                        % background solenoid number
        params.(paramnames(18)) = param(70);                        % background solenoid period 
        params.(paramnames(19)) = param(71);                        % background solenoid magnitude
        params.(paramnames(20)) = param(72);                        % min delay background solenoid to cue
        params.(paramnames(21)) = param(73);                        % min delay background solenoid to fixed solenoid
        params.(paramnames(22)) = param(74);                        % experiment mode
        params.(paramnames(23)) = param(75);                        % trial by trial bgd solenoid flag
        params.(paramnames(24)) = param(76);                        % total bgd rewards
        params.(paramnames(25)) = param(77:78);                     % number of required licks (2)
        params.(paramnames(26)) = param(79:80);                     % lick solenoid number (2)
        params.(paramnames(27)) = param(81:82);                     % lick to reward probability (2)
        params.(paramnames(28)) = param(83:84);                     % lick reward open time (2)
        params.(paramnames(29)) = param(85:86);                     % lick delay to reward (2)
        params.(paramnames(30)) = param(87:88);                     % delay to next lick (2)
        params.(paramnames(31)) = param(89:90);                     % min number of rewards on each lick tube
        params.(paramnames(32)) = param(91:92);                     % signal type to lick requirement (2)
        params.(paramnames(33)) = param(93:94);                     % signal pulse or not
        params.(paramnames(34)) = param(95:96);                     % sound cue frequency (2)
        params.(paramnames(35)) = param(97:98);                     % signal duration (2)
        params.(paramnames(36)) = param(99:100);                     % lick speaker number (2)
        params.(paramnames(37)) = param(101);                        % laser latency wrt cue
        params.(paramnames(38)) = param(102);                        % laser duration
        params.(paramnames(39)) = param(103);                        % random laser flag
        params.(paramnames(40)) = param(104);                        % laser pulse period
        params.(paramnames(41)) = param(105);                        % laser pulse off period
        params.(paramnames(42)) = param(106);                        % laser trial by trialflag
        params.(paramnames(43)) = param(107);                        % max delay cue to vacuum
        params.(paramnames(44)) = param(108:111);                     % CS light number (3)
        params.(paramnames(45)) = param(112:113);                     % lick ratio schedule indicator: 0=fixed,1=variable,2=progressive (2)
        params.(paramnames(46)) = param(114:115);                     % lick interval schedule indicator: 0=fixed,1=variable,2=progressive (2)
        params.(paramnames(47)) = param(116:117);                    % lick light number (2)
        params.(paramnames(48)) = param(118);                       % CS1 laser check flag
        params.(paramnames(49)) = param(119);                       % CS2 laser check flag
        params.(paramnames(50)) = param(120);                       % CS3 laser check flag
        params.(paramnames(51)) = param(121);                       % CS4 laser check flag
        params.(paramnames(52)) = param(122:123);                   % lick fixed side check (2)
        params.(paramnames(53)) = param(124);                       % Reward laser check flag
        params.(paramnames(54)) = param(125:128);                   % CS max ramp delay 
        params.(paramnames(55)) = param(129:132);                   % CS ramp exponential factor
        params.(paramnames(56)) = param(133:136);                   % CS increase
        params.(paramnames(57)) = param(137:140);                   % delay between sound and light cue if both are present 
        params.(paramnames(58)) = param(141:144);                   % CS second cue type
        params.(paramnames(59)) = param(145:148);                   % CS second cue frequency 
        params.(paramnames(60)) = param(149:152);                   % CS second cue speaker number
        params.(paramnames(61)) = param(153:156);                   % CS second cue light number
        params.(paramnames(62)) = param(157:158);                   % progressive ratio/interval multiplier (2)
    
    save(file, 'eventlog', 'params','exception')
    end 
    % make this part unable if you don't use camera
%     [frames,time] = getdata(cam, get(cam,'FramesAvailable'));
%     video.frames = squeeze(frames);
%     video.times = time;
%     save(file, 'video','-append')
end
