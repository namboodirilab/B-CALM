%% This section is for plotting pavlovian task for one single session for one animal. 
clf;
% [behfile, behfilepath] = uigetfile('', 'Select file to upload');
% load(fullfile(behfilepath,behfile));
location = '/filepath/'; %File path
animal = 'animalname'; %subfolders for animal name
filename = 'filename'; % file name
load(strcat(location,animal,filename));

params = regexprep(params, '+', ' '); % load parameters
params = str2num(params);

if params(14) == 100 % reward probability for CS1, if == 100, CS1 gets rewards while CS2 not; if == 0, vice versa
    CSplus = eventlog(eventlog(:,1)==15,2);  % CS1 is Cs+
    CSminus = eventlog(eventlog(:,1)==16,2);
else
    CSplus = eventlog(eventlog(:,1)==16,2);  % CS2 is CS+
    CSminus = eventlog(eventlog(:,1)==15,2);
end

lickthrees = eventlog(eventlog(:,1)==5,2); % get licks on lick tube three (reward lick tube)

binsize = 100; % ms
plotstart = -4E3; % relative plot start time tick
plotend = 9E3; % relative plot end time tick
numbins = (plotend-plotstart)/binsize; % number of bins for the plot
maxnumlickspertrial = (plotend-plotstart)*1E-3*20; % Maximum possible number of licks per trial period

fhandle = figure('PaperUnits','Centimeters','PaperPosition',[2 2 10 5]);
plot_lick_on_one(CSplus, CSminus, lickthrees, binsize,plotstart,plotend,[102/255,194/255,165/255],...
    [252/255,141/255,98/255],maxnumlickspertrial);



%% This section is for plotting pavlovian task for all files in a desginated folder. 
% Please place all files hope to plot into a desgianted folder and copy paste the
% foler path here in the myFolder variable.
clf('reset');
myFolder = '/filepath/';
filePattern = fullfile(myFolder, '*.mat'); % get all .mat files in this folder
matFiles = dir(filePattern);

binsize = 100; % seconds
plotstart = -4E3;
plotend = 9E3;
numbins = (plotend-plotstart)/binsize;
maxnumlickspertrial = (plotend-plotstart)*1E-3*20; % Maximum possible number of licks per trial period
totalnPSTHplus = zeros(length(matFiles),numbins); % total number of PSTH for CS+ trials 
totalnPSTHminus = zeros(length(matFiles),numbins); % total number of PSTH for CS- trials 

for i=1:length(matFiles)
    baseFileName = matFiles(i).name;
    fullFileName = fullfile(myFolder, baseFileName);
    load(fullFileName); % load individual files in this folder
        
    params = regexprep(params, '+', ' ');
    params = str2num(params);
    
    if params(14) == 100
        CSplus = eventlog(eventlog(:,1)==15,2);  % CS1 is Cs+
        CSminus = eventlog(eventlog(:,1)==16,2);
    else
        CSplus = eventlog(eventlog(:,1)==16,2);  % CS2 is CS+
        CSminus = eventlog(eventlog(:,1)==15,2);
    end
    
    lickthrees = eventlog(eventlog(:,1)==5,2); % get lick tube 3 lick times
    
    % Get the PSTH for CS+ and CS- licking on lick tube 3 licks
    [nPSTHplus, nPSTHminus] = get_lick_on_one(CSplus, CSminus, lickthrees, binsize,plotstart,plotend, maxnumlickspertrial);
    totalnPSTHplus(i,:) = nPSTHplus;
    totalnPSTHminus(i,:) = nPSTHminus;
end
color1 = cbrewer('seq','YlGn',6); % CS+ color scheme for each animal (n=5)
color2 = cbrewer('seq','Oranges',6); % CS- color scheme for each animal (n=5)
bins = (plotstart):binsize:plotend; %subtracting bin size to make bin numbers equal

h(3) = axes('Position',axpt(1,1,1,1,axpt(1,10,1,1:9),[0.1 0.05])); % setting figure 

% get the average PSTH for CS+ and CS-
avePSTHplus = sum(totalnPSTHplus)/length(matFiles);
avePSTHminus = sum(totalnPSTHminus)/length(matFiles);

% Plot average licking for CS+ and CS- 
p1 = plot(bins(1:end-1)/1E3, avePSTHplus,'LineWidth',3,'MarkerFaceColor',color1(6,:),'Color',color1(6,:),'DisplayName','CS+'); hold on
p2 = plot(bins(1:end-1)/1E3, avePSTHminus,'LineWidth',3,'MarkerFaceColor',color2(6,:),'Color',color2(6,:),'DisplayName','CS-'); hold on

% Plot individual animals licking rate for CS+ and CS-
plot(bins(1:end-1)/1E3, totalnPSTHplus(1,:),'LineWidth',1,'MarkerFaceColor',color1(1,:),'Color',color1(1,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHplus(2,:),'LineWidth',1,'MarkerFaceColor',color1(2,:),'Color',color1(2,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHplus(3,:),'LineWidth',1,'MarkerFaceColor',color1(3,:),'Color',color1(3,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHplus(4,:),'LineWidth',1,'MarkerFaceColor',color1(4,:),'Color',color1(4,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHplus(5,:),'LineWidth',1,'MarkerFaceColor',color1(5,:),'Color',color1(5,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHminus(1,:),'LineWidth',1,'MarkerFaceColor',color2(1,:),'Color',color2(1,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHminus(2,:),'LineWidth',1,'MarkerFaceColor',color2(2,:),'Color',color2(2,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHminus(3,:),'LineWidth',1,'MarkerFaceColor',color2(3,:),'Color',color2(3,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHminus(4,:),'LineWidth',1,'MarkerFaceColor',color2(4,:),'Color',color2(4,:)); 
plot(bins(1:end-1)/1E3, totalnPSTHminus(5,:),'LineWidth',1,'MarkerFaceColor',color2(5,:),'Color',color2(5,:)); 

% figure settings
set(h(3), 'box','off')
set(gca, 'FontName', 'Arial');
set(gca, 'FontSize',10);

% Add other components to the figure
cueonset = xline(0,'--'); hold on
cueonset.Annotation.LegendInformation.IconDisplayStyle = 'off';
cueoffset = xline(2,'--');hold on
cueoffset.Annotation.LegendInformation.IconDisplayStyle = 'off';
rewardtime = xline(3, '--'); hold on
rewardtime.Annotation.LegendInformation.IconDisplayStyle = 'off';
uistack(p1,'top');
uistack(p2,'top');
% xlabel('Time from Cue (s)');
ylabel('Average lick rate (Hz)');
ticks = plotstart:1E3:plotend;
labels = ticks'/1E3;                     % convert tick labels to seconds
xticks(labels(2):3:labels(end));
% legend
% legend boxoff
% print -painters -depsc output.eps
%%
function plot_lick_on_one(CSplus, CSminus, licks, binsize,...
                          plotstart, plotend,color1, color2, maxnumevents)
                      
        tempPSTHplus = NaN(numel(CSplus), maxnumevents); %number of rewards and max number of licks in each trial 
    for i = 1:numel(CSplus)    
        % get licks per trial, include everything between -7s and 8s of the
        % reward
        temp = licks(licks>(CSplus(i)+plotstart) & licks<=(CSplus(i)+plotend));
        tempPSTHplus(i,1:length(temp)) = temp-CSplus(i); %subtract the reward delivery time to every lick in this trial 
    end

    bins = (plotstart:binsize:plotend); %subtracting bin size to make bin numbers equal
    nPSTHplus = histcounts(tempPSTHplus(~isnan(tempPSTHplus)),bins); %Count licks in tempPSTH into nPSTH using histcounts
    nPSTHplus = nPSTHplus/numel(CSplus);
    
        tempPSTHminus = NaN(numel(CSminus), maxnumevents); %number of rewards and max number of licks in each trial 
    for i = 1:numel(CSminus)    
        % get licks per trial, include everything between -7s and 8s of the
        % reward
        temp = licks(licks>(CSminus(i)+plotstart) & licks<=(CSminus(i)+plotend));
        tempPSTHminus(i,1:length(temp)) = temp-CSminus(i); %subtract the reward delivery time to every lick in this trial 
    end

    bins = (plotstart:binsize:plotend); %subtracting bin size to make bin numbers equal
    nPSTHminus = histcounts(tempPSTHminus(~isnan(tempPSTHminus)),bins); %Count licks in tempPSTH into nPSTH using histcounts
    nPSTHminus = nPSTHminus/numel(CSminus);

    h(1) = axes('Position',axpt(3,1,2,1,axpt(1,10,1,1:9),[0.1 0.05]));
    plot(bins(1:end-1)/1E3,nPSTHplus/(binsize/1E3),'LineWidth',2,'MarkerFaceColor',color1,'Color',color1,'DisplayName','CS+'); hold on
    plot(bins(1:end-1)/1E3,nPSTHminus/(binsize/1E3),'LineWidth',2,'MarkerFaceColor',color2,'Color',color2,'DisplayName','CS-'); hold on
    set(h(1),'box','off');
    set(gca, 'FontName', 'Arial');
    set(gca, 'FontSize',10);

    % Here are for marking the cue and reward time
    cueonset = xline(0,'--'); hold on
    cueonset.Annotation.LegendInformation.IconDisplayStyle = 'off';
    cueoffset = xline(2,'--');hold on
    cueoffset.Annotation.LegendInformation.IconDisplayStyle = 'off';
    rewardtime = xline(3, '--'); hold on
    rewardtime.Annotation.LegendInformation.IconDisplayStyle = 'off';
    xlabel('Time from cue onset (s)');
    ylabel('Lick rate one animal(Hz)');
    ticks = plotstart:1E3:plotend;
    labels = ticks'/1E3;                     % convert tick labels to seconds   
    xticks(labels(2):3:labels(end));
%     title(animal)
%     legend
    
%     % Rsater Plot for licks
    h(2) = axes('Position',axpt(3,1,1,1,axpt(1,10,1,1:9),[0.1 0.05]));
    xplus=[];
    yplus=[];
    for i = 1:numel(CSplus)
        temp = tempPSTHplus(i,~isnan(tempPSTHplus(i,:)));
        temp = [temp;temp];
        xplus=[xplus temp];
        temp = [-(i-1)*ones(1,size(temp,2)); -(i)*ones(1,size(temp,2))];
        yplus = [yplus temp];
    end

    xminus=[];
    yminus=[];
    for i = 1:numel(CSminus)
        temp = tempPSTHminus(i,~isnan(tempPSTHminus(i,:)));
        temp = [temp;temp];
        xminus=[xminus temp];
        temp = [-(i-1)*ones(1,size(temp,2)); -(i)*ones(1,size(temp,2))];
        yminus = [yminus temp];
    end

    plot(xplus,yplus,'Color',color1,'LineWidth',0.5);hold on
    plot(xminus,yminus,'Color',color2,'LineWidth',0.5);hold on

    xline(0,'--'); hold on
    xline(2000, '--');hold on 
    xline(3000,'--');hold on
    set(h(2),'box','off');
    set(gca, 'FontName', 'Arial')
    set(gca, 'FontSize',10);
%     xlabel(sprintf('Time from Cue'));
    ylabel('Trial number');
    yticks([-50 0]);
    ticks = plotstart:1E3:plotend;
%     labels = ticks'/1E3;                     % convert tick labels to seconds
    xlim([-4000 8000]);
    xticks(ticks(2):3000:ticks(end));
    xticklabels(labels(2):3:labels(end));     % convert to cell of strings
end 


%%
function [nPSTHplus, nPSTHminus] = get_lick_on_one(CSplus, CSminus, licks, binsize,...
                          plotstart, plotend, maxnumevents)
    
    tempPSTHplus = NaN(numel(CSplus), maxnumevents); %number of rewards and max number of licks in each trial
    for i = 1:numel(CSplus)    
        % get licks per trial, include everything between -7s and 8s of the
        % reward
        temp = licks(licks>(CSplus(i)+plotstart) & licks<=(CSplus(i)+plotend));
        tempPSTHplus(i,1:length(temp)) = temp-CSplus(i); %subtract the reward delivery time to every lick in this trial 
    end

    bins = (plotstart):binsize:plotend; %subtracting bin size to make bin numbers equal
    nPSTHplus = histcounts(tempPSTHplus(~isnan(tempPSTHplus)),bins); %Count licks in tempPSTH into nPSTH using histcounts
    nPSTHplus = nPSTHplus/numel(CSplus);
    
        tempPSTHminus = NaN(numel(CSminus), maxnumevents); %number of rewards and max number of licks in each trial 
    for i = 1:numel(CSminus)    
        % get licks per trial, include everything between -7s and 8s of the
        % reward
        temp = licks(licks>(CSminus(i)+plotstart) & licks<=(CSminus(i)+plotend));
        tempPSTHminus(i,1:length(temp)) = temp-CSminus(i); %subtract the reward delivery time to every lick in this trial 
    end

    bins = (plotstart):binsize:plotend; %subtracting bin size to make bin numbers equal
    nPSTHminus = histcounts(tempPSTHminus(~isnan(tempPSTHminus)),bins); %Count licks in tempPSTH into nPSTH using histcounts
    nPSTHminus = nPSTHminus/numel(CSminus);
end