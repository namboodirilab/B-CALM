%%
clf('reset');
% [behfile, behfilepath] = uigetfile('', 'Select file to upload');
% load(fullfile(behfilepath,behfile));


location = '/filepath/';
animal = 'animalname';
filename = 'filename';
load(strcat(location,animal,filename));

%%

licks = eventlog(eventlog(:,1)==5,2); % get lick times
rewards = eventlog(eventlog(:,1)==10 & eventlog(:,3)==0,2); % get reward times
omissions = eventlog(eventlog(:,1)==10 & eventlog(:,3)==1,2); % get omission times, third row==1

params = regexprep(params, '+', ' '); % get parameters
params = str2num(params);
triallength = params(50) + params(90);
triallength = triallength /2;

binsize = 500; % miliseconds
plotstart = -triallength + 500; % seconds before outcome
plotend = triallength + 500; % seconds after outcome
numbins = (plotend-plotstart)/binsize;
maxnumlickspertrial = (plotend-plotstart)*1E-3*20; % Maximum possible number of licks per trial period
%%
cb = cbrewer('qual','Set1',3);
plot_PSTH(rewards, licks, binsize, plotstart, plotend, cb(2,:), maxnumlickspertrial, [1,3], 'reward (s)');
plot_PSTH(omissions, licks, binsize, plotstart, plotend, cb(1,:), maxnumlickspertrial, [2,4], 'omission (s)');
% title(filename)
%%
function plot_PSTH(originevents, eventstoplot, binsize,...
                   plotstart, plotend, color, maxnumevents,...
                   subplotindex, outcometype)
               
    tempPSTH = NaN(numel(originevents), maxnumevents); %number of rewards and max number of licks in each trial 
    for i = 1:numel(originevents)    
        % get licks per trial, include everything between -7s and 8s of the
        % reward
        temp = eventstoplot(eventstoplot>(originevents(i)+plotstart) & eventstoplot<=(originevents(i)+plotend));
        tempPSTH(i,1:length(temp)) = temp-originevents(i); %subtract the reward delivery time to every lick in this trial 
    end

    bins = (plotstart):binsize:plotend; %subtracting bin size to make bin numbers equal
    nPSTH = histcounts(tempPSTH(~isnan(tempPSTH)),bins); %Count licks in tempPSTH into nPSTH using histcounts
    nPSTH = nPSTH/numel(originevents);
    
    subplot(2,2,subplotindex(1));
    x=[];
    y = [];
    for i = 1:numel(originevents)
        temp = tempPSTH(i,~isnan(tempPSTH(i,:)));
        temp = [temp;temp];
        x=[x temp];
        temp = [-(i-1)*ones(1,size(temp,2)); -(i)*ones(1,size(temp,2))];
        y = [y temp];
    end
    % Raster plot of licks for reward or omission trial
    plot(x,y,'k','LineWidth',0.5);hold on
    set(gca,'box','off');
%     xlabel(sprintf('Time from %s', outcometype));
    ylabel('Trial number');
    ticks = plotstart:1E3:plotend;
    labels = ticks'/1E3;                     % convert tick labels to seconds
    xticks(ticks(1):1500:ticks(end));
    xticklabels(labels(1):1.5:labels(end));     % convert to cell of strings      
    
    % Plot lick rate comparision for reward vs omission trials
    subplot(2,2,subplotindex(2));
    plot(bins(1:end-1),nPSTH/(binsize/1E3),'Marker','o','MarkerFaceColor',color,'Color',color); hold on
    set(gca,'box','off');
    xlabel(sprintf('Time from %s', outcometype));
    ylabel('Lick rate (Hz)');
    ticks = plotstart:1E3:plotend;
    labels = ticks'/1E3;                     % convert tick labels to seconds
    xticks(ticks(1):1500:ticks(end));
    xticklabels(labels(1):1.5:labels(end));     % convert to cell of strings    
end

