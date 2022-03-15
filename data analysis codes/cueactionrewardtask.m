%% THIS SCRIPT IS FOR PLOTTING CAR TASK SINGLE ANIMAL
% clf('reset');
% [behfile, behfilepath] = uigetfile('', 'Select file to upload');
% load(fullfile(behfilepath,behfile));
% 
location = '/filepath/';
animal = 'animalname/';
filename = 'filename';
load(strcat(location,animal,filename)); % load file

lick3s = eventlog(eventlog(:,1)==5,2); % get consummatory lick times
lick1s = eventlog(eventlog(:,1)==1,2); % get operant lick times
cs1 = eventlog(eventlog(:,1)==15,2); % get CS1 times
cs2 = eventlog(eventlog(:,1)==16,2); % get CS2 times
rewards = eventlog(eventlog(:,1)==10 & eventlog(:,3)==0,2); % get reward times
omissions = eventlog(eventlog(:,1)==10 & eventlog(:,3)==1,2); % get omission times

binsize = 0.1E3; % seconds
plotstart = -3E3; % seconds before origin
plotend = 10E3; % seconds after origin
numbins = (plotend-plotstart)/binsize;
maxnumlickspertrial = (plotend-plotstart)*1E-3*20; % Maximum possible number of licks per trial period

eventsforrasters = {lick3s, lick1s, rewards}; % events for raster plot
plotPSTH = [1,1,0]; % flag for plotting PSTH for events
colorsforrasters = {[0, 0, 0], [0.6, 0.3, 0.1], [0.4, 0.6, 0.8]}; % color for raster plot
colorsforPSTH_cs1 = {[102/255,194/255,165/255], [0, 0, 0.8], [0.4, 0.6, 0.8]}; % color for PSTH for CS1
colorsforPSTH_cs2 = {[252/255,141/255,98/255], [0.8, 0, 0], [0.4, 0.6, 0.8]}; % color for PSTH for CS2
labelsforevents = ["Center licks", "Operant licks", "Rewards"]; % labels for events

% Figure setting
figure1 = figure;
set(figure1,'Position',[10 10 1000 250])
subplot1 = subplot(1,3,1);
title(['\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', colorsforrasters{2}) '}' char(labelsforevents(2)),...
       ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', colorsforrasters{1}) '}' char(labelsforevents(1)),...
       ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', colorsforrasters{3}) '}' char(labelsforevents(3))],...
       'fontsize',10, 'Interpreter', 'tex');    
hold(subplot1,'on');
subplot2 = subplot(1,3,2);
title(['\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', colorsforrasters{2}) '}' char(labelsforevents(2)),...
       ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', colorsforrasters{1}) '}' char(labelsforevents(1)),...
       ',\color[rgb]{' sprintf('%1.2f,%1.2f,%1.2f', colorsforrasters{3}) '}' char(labelsforevents(3))],...
       'fontsize',10, 'Interpreter', 'tex'); 
hold(subplot2,'on');
subplot3 = subplot(1,3,3);
title('PSTH','fontsize',10);
hold(subplot3,'on');

plot_PSTH(cs1, eventsforrasters, plotPSTH, binsize, plotstart,...
          plotend, colorsforrasters, colorsforPSTH_cs1, ...
          maxnumlickspertrial, subplot1, subplot3, 'CS1',...
          'cue', labelsforevents);
plot_PSTH(cs2, eventsforrasters, plotPSTH, binsize, plotstart,...
          plotend, colorsforrasters, colorsforPSTH_cs2, ...
          maxnumlickspertrial, subplot2, subplot3, 'CS2',...
          'cue', labelsforevents);

% temp = strsplit(behfile, '.');
% saveas(figure1,sprintf('%s_%s', fullfile(behfilepath,char(temp(1))), 'behavior'),'epsc');
% saveas(figure1,sprintf('%s_%s', fullfile(behfilepath,char(temp(1))), 'behavior'),'jpeg');

%% THIS SECTION IS FOR PLOTTING AVERAGE LICK RATE DS+ VS DS- FOR ALL ANIMALS FIRST DAY VS LAST DAY
clf('reset')
animals = ["Animal1" "Animal2" "Animal3" "Animal4" "Animal5" "Animal6"];
totalDSlickrate = zeros(2, 2, length(animals)*2); % initialize parameter based on # of animals

for p=1:length(animals)
    location = '/filepath/';
    if p>=5
        group = 'Pavlovian/'; % Pavlovian-trained animals in this folder
    else
        group = 'Operant/'; % Operant-trained animals in this folder
    end

    myFolder = strcat(location, group, animals(p),'/');
    filePattern = fullfile(myFolder, '*.mat');
    matFiles = dir(filePattern);
    
    binsize = 1E3; % seconds
    plotstart = 0; % seconds before origin
    plotend = 9E3; % seconds after origin
    numbins = (plotend-plotstart)/binsize;
    maxnumlickspertrial = (plotend-plotstart)*1E-3*20; % Maximum possible number of licks per trial period
    DSlickrate = zeros(2, 2, length(matFiles)); % DS lick rate parameter inilizaing

    for i=1:length(matFiles)
        baseFileName = matFiles(i).name;
        fullFileName = fullfile(myFolder, baseFileName);
        load(fullFileName); % load individual file
        

        params = regexprep(params, '+', ' '); % load parameters
        params = str2num(params);
        
        if params(14) == 100 & params(16) == 0
            CSplus = eventlog(eventlog(:,1)==15,2);  % CS1 is Cs+
            CSminus = eventlog(eventlog(:,1)==16,2);
        elseif params(16) == 100 & params(14) == 0
            CSplus = eventlog(eventlog(:,1)==16,2);  % CS2 is CS+
            CSminus = eventlog(eventlog(:,1)==15,2);
        end
        
        % Get event times
        lick3s = eventlog(eventlog(:,1)==5,2);
        lick1s = eventlog(eventlog(:,1)==1,2);
        rewards = eventlog(eventlog(:,1)==10 & eventlog(:,3)==0,2);
        omissions = eventlog(eventlog(:,1)==10 & eventlog(:,3)==1,2);
        
        % calculate DS+ DS- lick rate for operant licks
        [DSplusoperant, DSminusoperant] = calculate_DS_lickrate(CSplus, CSminus, lick1s, binsize,...
            plotstart, plotend, maxnumlickspertrial);
        DSlickrate(1, 1, i) = DSplusoperant(1);
        DSlickrate(2, 1, i) = DSminusoperant(1);
        % calculate DS+ Ds- lick rate for consummatory licks
        [DSplusconsummatory, DSminusconsummatory] = calculate_DS_lickrate(CSplus, CSminus, lick3s, binsize,...
            plotstart, plotend, maxnumlickspertrial);
        DSlickrate(1, 2, i) = DSplusconsummatory(1);
        DSlickrate(2, 2, i) = DSminusconsummatory(1);
    end
    totalDSlickrate(:, :, (p*2-1):p*2) = DSlickrate(:, :, :); % get total DS lick rate
end
%% For plotting total DS lick rate
clf('reset')
cb = cbrewer('qual', 'Dark2',4);

x1 = scatter(totalDSlickrate(1,1,1),totalDSlickrate(2,1,1), 120,cb(4,:)); hold on
x2 = scatter(totalDSlickrate(1,1,2),totalDSlickrate(2,1,2),120,cb(4,:), 'filled');
scatter(totalDSlickrate(1,1,3),totalDSlickrate(2,1,3),120, cb(4,:));
scatter(totalDSlickrate(1,1,4),totalDSlickrate(2,1,4),120,cb(4,:),'filled');
scatter(totalDSlickrate(1,1,5),totalDSlickrate(2,1,5),120,cb(4,:)); 
scatter(totalDSlickrate(1,1,6),totalDSlickrate(2,1,6),120,cb(4,:),'filled');
scatter(totalDSlickrate(1,1,7),totalDSlickrate(2,1,7),120,cb(4,:)); 
scatter(totalDSlickrate(1,1,8),totalDSlickrate(2,1,8),120,cb(4,:),'filled');
scatter(totalDSlickrate(1,1,9),totalDSlickrate(2,1,9),120,cb(4,:)); 
scatter(totalDSlickrate(1,1,10),totalDSlickrate(2,1,10),120,cb(4,:),'filled');
scatter(totalDSlickrate(1,1,11),totalDSlickrate(2,1,11),120,cb(4,:)); 
scatter(totalDSlickrate(1,1,12),totalDSlickrate(2,1,12),120,cb(4,:),'filled');

x3 = scatter(totalDSlickrate(1,2,1),totalDSlickrate(2,2,1),120,cb(3,:)); hold on
x4 = scatter(totalDSlickrate(1,2,2),totalDSlickrate(2,2,2), 120,cb(3,:),'filled');
scatter(totalDSlickrate(1,2,3),totalDSlickrate(2,2,3), 120,cb(3,:)); 
scatter(totalDSlickrate(1,2,4),totalDSlickrate(2,2,4),120,cb(3,:),'filled');
scatter(totalDSlickrate(1,2,5),totalDSlickrate(2,2,5),120,cb(3,:)); 
scatter(totalDSlickrate(1,2,6),totalDSlickrate(2,2,6),120,cb(3,:),'filled');
scatter(totalDSlickrate(1,2,7),totalDSlickrate(2,2,7),120,cb(3,:)); 
scatter(totalDSlickrate(1,2,8),totalDSlickrate(2,2,8),120,cb(3,:),'filled');
scatter(totalDSlickrate(1,2,9),totalDSlickrate(2,2,9),120,cb(3,:)); 
scatter(totalDSlickrate(1,2,10),totalDSlickrate(2,2,10),120,cb(3,:),'filled');
scatter(totalDSlickrate(1,2,11),totalDSlickrate(2,2,11),120,cb(3,:)); 
scatter(totalDSlickrate(1,2,12),totalDSlickrate(2,2,12),120,cb(3,:),'filled');

plot([0 11],[0 11], 'k--');

xlim([0 11])
ylim([0 11])
xticks(0:2:11)
yticks(0:2:11)
ylabel('Average DS- licks per trial')
xlabel('Average DS+ licks per trial')
legend([x1 x2 x3 x4], {'Operant licks first day','Operant licks last day','Anticipatory licks first day','Anticipatory licks last day'}, 'Location', 'northwest','NumColumns',2)

%% Statistics: get the t-test of operant licks for DS+ vs DS-
operantdsplus = squeeze(totalDSlickrate(1,1,2:2:12));
operantdsminus = squeeze(totalDSlickrate(2,1,2:2:12));
temp = (operantdsplus - operantdsminus) ./ (operantdsplus + operantdsminus)*2;
[hoperant,poperant, ~,stats] = ttest(temp)

%%
function plot_PSTH(originevents, eventsforrasters, plotPSTH, binsize,...
                   plotstart, plotend, colorsforrasters, colorsforPSTH,...
                   maxnumevents,axhandle, PSTHaxhandle, originname,...
                   originname_PSTH, labelsforevents)
    
    for j = 1:length(eventsforrasters)  
        eventforrasters = eventsforrasters{j};
        tempPSTH = NaN(numel(originevents), maxnumevents); 
        for i = 1:numel(originevents)        
            temp = eventforrasters(eventforrasters>(originevents(i)+plotstart) & eventforrasters<=(originevents(i)+plotend));
            tempPSTH(i,1:length(temp)) = temp-originevents(i);    
        end
        
        bins = (plotstart):binsize:plotend; %subtracting bin size to make bin numbers equal
        nPSTH = histcounts(tempPSTH(~isnan(tempPSTH)),bins);
        nPSTH = nPSTH/(numel(originevents)*binsize*1E-3); %lick rate in Hz
       
        
        x=[];
        y = [];
        
        for i = 1:numel(originevents)
            temp = tempPSTH(i,~isnan(tempPSTH(i,:)));
            temp = [temp;temp];
            x=[x temp];
            temp = [-(i-1)*ones(1,size(temp,2)); -(i)*ones(1,size(temp,2))];
            y = [y temp];
        end
        plot(x,y, 'Parent', axhandle, 'Color', colorsforrasters{j},...
            'LineWidth',0.5);hold on
        axhandle.XLabel.String = sprintf('Time from %s', originname);
        axhandle.YLabel.String = 'Trial number';
        ticks = plotstart:1E3:plotend;
        labels = ticks'/1E3;                     % convert tick labels to seconds
        set(axhandle, 'XTick', ticks(1):3000:ticks(end));
        set(axhandle, 'XTicklabel', labels(1):3:labels(end));% convert to cell of strings  
        set(axhandle, 'XLim', [plotstart, plotend]);
        set(axhandle, 'YLim', [-length(originevents) 0]);
        
    
        if plotPSTH(j)==1  
            plot(bins(1:end-1),nPSTH, 'Parent', PSTHaxhandle,'Marker','none',...
                 'Color',colorsforPSTH{j},'LineWidth',1,...
                 'DisplayName',sprintf('%s %s',...
                                       labelsforevents(j),originname));
            hold on
            PSTHaxhandle.XLabel.String = sprintf('Time from %s', originname_PSTH);
            PSTHaxhandle.YLabel.String = 'Lick rate (Hz)';
            ticks = plotstart:1E3:plotend;
            labels = ticks'/1E3;                     % convert tick labels to seconds
            set(PSTHaxhandle, 'XTick', ticks(1):3000:ticks(end));
            set(PSTHaxhandle, 'XTicklabel', labels(1):3:labels(end));% convert to cell of strings   
            set(PSTHaxhandle, 'XLim', [plotstart, plotend]);
        end
    end
    legend(PSTHaxhandle,'show', 'Location', 'northwest', 'Box', 'off');   
%     set(legend1, 'Location',[0.177 0.613 0.433 0.108]);
end
%%
function [DSplus, DSminus] = calculate_DS_lickrate(CSplus, CSminus, licks, binsize,...
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
    DSplus = nPSTHplus/numel(CSplus);
    
        tempPSTHminus = NaN(numel(CSminus), maxnumevents); %number of rewards and max number of licks in each trial 
    for i = 1:numel(CSminus)    
        % get licks per trial, include everything between -7s and 8s of the
        % reward
        temp = licks(licks>(CSminus(i)+plotstart) & licks<=(CSminus(i)+plotend));
        tempPSTHminus(i,1:length(temp)) = temp-CSminus(i); %subtract the reward delivery time to every lick in this trial 
    end

    bins = (plotstart):binsize:plotend; %subtracting bin size to make bin numbers equal
    nPSTHminus = histcounts(tempPSTHminus(~isnan(tempPSTHminus)),bins); %Count licks in tempPSTH into nPSTH using histcounts
    DSminus = nPSTHminus/numel(CSminus); %Lick rate in Hz
end     