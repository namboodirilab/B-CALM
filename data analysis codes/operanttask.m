%% Plot single session in OPERANT TASK, analyzed based on the time difference between operant licks
clf('reset');
% [behfile, behfilepath] = uigetfile('', 'Select file to upload');
% load(fullfile(behfilepath,behfile));
myFolder = '/filepath'; % file path
filePattern = fullfile(myFolder, '*.mat');
matFiles = dir(filePattern);

% Initializing parameters 
timediffave = zeros(length(matFiles),1);
lick3betweenrewards = zeros(length(matFiles),1);
ratiocheck = strings(length(matFiles),1);
requiredlickones = zeros(length(matFiles),1);
cluster = zeros(2000,length(matFiles));
clusterave = zeros(length(matFiles),1);

for i=1:length(matFiles)
    baseFileName = matFiles(i).name;
    fullFileName = fullfile(myFolder, baseFileName);
    load(fullFileName); % load invididual files in the folder
        
    param = regexprep(params, '+', ' '); % get parameters
    param = str2num(param);
    
    lickones = eventlog(eventlog(:,1)==1,2); % get operant lick times from lick tube 1
    lickthrees = eventlog(eventlog(:,1)==5,2); % get consummatory lick times from lick tube 3
    rewards = eventlog(eventlog(:,1)==10 & eventlog(:,3)==0,2); % get reward times
    
    requiredlickones(i,1) = param(60); % get the required number of operant licks to get a reward, initiliazed before running the task

    % Task can be variable ratio or fixed ratio
    %     if param(94) == 1
    %         ratiocheck(i,1) = 'VR';
    %     else
    %         ratiocheck(i,1) = 'FR';
    %     end
    %     [lastlicks, lastlickidx] = intersect(lickones(:),rewards(:));

    lastlickidx = zeros(100,1); % initialize the last operant lick indexes
    lastlicks = zeros(100,1); % initialize the last operant lick times

    a = 1;
    for p=1:length(rewards)
        for b=1:length(lickones)
            if lickones(b,1) >= rewards(p,1)
                lastlicks(p,1) = lickones(b-1, 1);  % get lick times of last operant licks 
                lastlickidx(p,1) = b-1; % get corresponding index numbers
                break
            end
        end
    end   

    lastlickidx = lastlickidx(lastlickidx~=0); % get non-zero values 
    lastlicks = lastlicks(lastlicks~=0); % get non-zero values 
    firstlicks = lickones(lastlickidx-4); % first lick is 4 licks before last lick (based on FR5 ratio); can change according to the task schedule
   
    timediff = lastlicks - firstlicks; % time difference between last operant lick and first operant lick
    timediffave(i,1) = sum(timediff) / length(lastlicks); % time difference average per session
    
    % for calculating lick 3 between first and last operant licks
    for k=1:length(lastlicks)
        lick3betweenrewards(i,1) = lick3betweenrewards(i,1) + length(lickthrees(lickthrees(:)>=firstlicks(k) & lickthrees(:)<=lastlicks(k)));
    end
    
%     % for calculating lick 1 clusters 
%     eventlog(eventlog(:,1)==2,:) = [];
%     a = 1;
%     for p=1:length(eventlog)-1
%         if eventlog(p,1) == 1
%             cluster(a,i) = cluster(a,i) + 1;
%         elseif eventlog(p,1) ~= 1 && eventlog(p+1,1) == 1 
%             a = a+1;
%         end   
%     end
%    clusterave(i,1) = sum(cluster(:,i)) / sum(cluster(:,i)~=0);
end


% changingtoVR = find(ratiocheck=='VR', 1);
% requiredlickones = num2str(requiredlickones);
% datalabel = strcat(ratiocheck, requiredlickones);
% 
x = [1:1:length(matFiles)];
% x1 = x(1:changingtoVR-1);
% x2 = x(changingtoVR:end);
y = timediffave/1E3;
% y1 = y(1:changingtoVR-1);
% y2 = y(changingtoVR:end);
% b1 = bar(x1,y1, 'FaceColor','flat','DisplayName','FR5'); hold on
% b2 = bar(x2,y2,'FaceColor',[0 0.8 0.8], 'DisplayName','VR5');
bar(x, y);
% xticks(x);
xticklabels({'First Day', 'Last Day'});
ylabel('Time spent between rewards (s)');

%% Plot for multiple animals in fixed ratio 5 task. 
clf('reset');
animals = ["Animal1" "Animal2" "Animal3" "Animal4"]; % make folders for each animal under file path
totaltimediff = zeros(2, length(animals)); % initialize parameter based on # of animals

for h=1:length(animals)
    location = '/filepath/'; % main file path
    s1 = '/';
    myFolder = strcat(location, animals(h), s1);
    filePattern = fullfile(myFolder, '*.mat');
    matFiles = dir(filePattern);
    
    % Initialize empty parameters 
    timediffave = zeros(length(matFiles),1);
    lick3betweenrewards = zeros(length(matFiles),1);
    ratiocheck = strings(length(matFiles),1);
    requiredlickones = zeros(length(matFiles),1);
    cluster = zeros(2000,length(matFiles));
    clusterave = zeros(length(matFiles),1);
    
    for i=1:length(matFiles)
        baseFileName = matFiles(i).name;
        fullFileName = fullfile(myFolder, baseFileName);
        load(fullFileName); % load individual file
        
        param = regexprep(params, '+', ' '); % get parameters
        param = str2num(param);
        
        lickones = eventlog(eventlog(:,1)==1,2); % get lick1 times (operant)
        lickthrees = eventlog(eventlog(:,1)==5,2); % get lick3 times (consummatory)
        rewards = eventlog(eventlog(:,1)==10 & eventlog(:,3)==0,2); % get reward times
        requiredlickones(i,1) = param(60); % get required number of operant licks to obtain a reward (initialized before task)
        
        %     if param(94) == 1
        %         ratiocheck(i,1) = 'VR';
        %     else
        %         ratiocheck(i,1) = 'FR';
        %     end
        %     [lastlicks, lastlickidx] = intersect(lickones(:),rewards(:));
        
        lastlickidx = zeros(100,1); % initialize last operant lick in a cluster 
        lastlicks = zeros(100,1); % initialize last operant lick index 

        a = 1;
        for p=1:length(rewards)
            for b=1:length(lickones)
                if lickones(b,1) >= rewards(p,1)
                    lastlicks(p,1) = lickones(b-1, 1); % get last operant lick times
                    lastlickidx(p,1) = b-1; % get last operant lick indexes
                    break
                end
            end
        end
        lastlickidx = lastlickidx(lastlickidx~=0); % get non-zero values
        lastlicks = lastlicks(lastlicks~=0); % get non-zero values
        firstlicks = lickones(lastlickidx-4); % get first operant lick indexes for every cluster
        
        timediff = (lastlicks - firstlicks)/1E3; % get the time difference between last and first operant licks for each cluster, converts to seconds
        timediffave(i,1) = sum(timediff) / length(lastlicks); % get the average of it
        
        % for calculating lick 3 between first and last operant licks
%         for k=1:length(lastlicks)
%             lick3betweenrewards(i,1) = lick3betweenrewards(i,1) + length(lickthrees(lickthrees(:)>=firstlicks(k) & lickthrees(:)<=lastlicks(k)));
%         end
        
        %     % for calculating lick 1 clusters
        %     eventlog(eventlog(:,1)==2,:) = [];
        %     a = 1;
        %     for p=1:length(eventlog)-1
        %         if eventlog(p,1) == 1
        %             cluster(a,i) = cluster(a,i) + 1;
        %         elseif eventlog(p,1) ~= 1 && eventlog(p+1,1) == 1
        %             a = a+1;
        %         end
        %     end
        %    clusterave(i,1) = sum(cluster(:,i)) / sum(cluster(:,i)~=0);
    end
    totaltimediff(:,h) = timediffave(:,:); % store total time difference average in this variable
end
% 
% 
X = [1 2];
totaltimediffave = mean(totaltimediff'); % get average of the total time difference of all animals

cb = cbrewer('seq', 'PuBu',5); % color scheme of each animal
% Plot individual animal data points
scatter(1,totaltimediff(1,1),100,'filled','DisplayName','Animal 1','MarkerFaceColor',cb(1,:)); hold on 
plot(X, totaltimediff(:,1),'Color',cb(1,:))
scatter(1,totaltimediff(1,2),100,'filled','DisplayName','Animal 2','MarkerFaceColor',cb(2,:));
plot(X, totaltimediff(:,2),'Color',cb(2,:))
scatter(1,totaltimediff(1,3),100,'filled','DisplayName','Animal 3','MarkerFaceColor',cb(3,:)); 
plot(X, totaltimediff(:,3),'Color',cb(3,:))
scatter(1,totaltimediff(1,4),100,'filled','DisplayName','Animal 4','MarkerFaceColor',cb(4,:)); 
plot(X, totaltimediff(:,4),'Color',cb(4,:))
scatter(2,totaltimediff(2,1),100,'filled','DisplayName','Animal 1','MarkerFaceColor',cb(1,:)); 
scatter(2,totaltimediff(2,2),100,'filled','DisplayName','Animal 2','MarkerFaceColor',cb(2,:));
scatter(2,totaltimediff(2,3),100,'filled','DisplayName','Animal 3','MarkerFaceColor',cb(3,:)); 
scatter(2,totaltimediff(2,4),100,'filled','DisplayName','Animal 4','MarkerFaceColor',cb(4,:)); 

% plot bar graph for total average
b = bar(X,totaltimediffave,'FaceColor', cb(5,:));
uistack(b,'bottom');
set(gca, 'FontName', 'Arial');
set(gca, 'FontSize',15);
xticks([1 2])
xticklabels({'First Day', 'Last Day'});
ystr = "Ave time between" + "\n" + "first and last lick(s)";
ystr = compose(ystr);
newstr = splitlines(ystr);
ylabel(newstr);

% Calulate standard error of mean
SEM1 = std(totaltimediff(1,:)) / sqrt(length(animals));
SEM2 = std(totaltimediff(2,:)) / sqrt(length(animals));
SEM = [SEM1; SEM2];
er = errorbar(X,totaltimediffave,SEM,'Color',cb(5,:),'linestyle','none','LineWidth',1,'HandleVisibility','off'); 

% xticklabels({'Time (s)', 'Consummatory licks(#)'});
% ylabel('Unit amount between first and last operant lick');
% legend

%% Plot for multiple animals in variable ratio 5 task. (parameters are the same, refer to the previous section)
clf('reset');
animals = ["Animal1" "Animal2" "Animal3" "Animal4"];
totaltimediff = zeros(1, length(animals));

for h=1:length(animals)
    location = '/filepath/';
    s1 = '/';
    myFolder = strcat(location, animals(h), s1);
    filePattern = fullfile(myFolder, '*.mat');
    matFiles = dir(filePattern);
    
    timediffave = zeros(length(matFiles),1);
    lick3betweenrewards = zeros(length(matFiles),1);
    ratiocheck = strings(length(matFiles),1);
    requiredlickones = zeros(length(matFiles),1);
    cluster = zeros(2000,length(matFiles));
    clusterave = zeros(length(matFiles),1);
    
    for i=1:length(matFiles)
        baseFileName = matFiles(i).name;
        fullFileName = fullfile(myFolder, baseFileName);
        load(fullFileName);
        
        param = regexprep(params, '+', ' ');
        param = str2num(param);
        
        lickones = eventlog(eventlog(:,1)==1,2);
        lickthrees = eventlog(eventlog(:,1)==5,2);
        rewards = eventlog(eventlog(:,1)==10 & eventlog(:,3)==0,2);
        
        requiredlickones(i,1) = param(60);
        %     if param(94) == 1
        %         ratiocheck(i,1) = 'VR';
        %     else
        %         ratiocheck(i,1) = 'FR';
        %     end
        %     [lastlicks, lastlickidx] = intersect(lickones(:),rewards(:));
        lastlickidx = zeros(100,1);
        lastlicks = zeros(100,1);
        firstlicks = zeros(100,1);

        a = 1;
        for p=1:length(rewards)
            for b=1:length(lickones)
                if lickones(b,1) == rewards(p,1)
                    lastlicks(p,1) = lickones(b,1);
                    lastlickidx(p,1) = b;
                    break
                end
            end
        end
        lastlickidx = lastlickidx(lastlickidx~=0);
        lastlicks = lastlicks(lastlicks~=0);
        firstlickidx = lastlickidx + 1;
        firstlickidx = [1; firstlickidx(1:end-1)];
        firstlicks = lickones(firstlickidx);
        
        timediff = (lastlicks - firstlicks)/1E3; % converts to seconds
        timediffave(i,1) = sum(timediff) / length(lastlicks);
        
        % for calculating lick 3 between first and last operant licks
%         for k=1:length(lastlicks)
%             lick3betweenrewards(i,1) = lick3betweenrewards(i,1) + length(lickthrees(lickthrees(:)>=firstlicks(k) & lickthrees(:)<=lastlicks(k)));
%         end
        
        %     % for calculating lick 1 clusters
        %     eventlog(eventlog(:,1)==2,:) = [];
        %     a = 1;
        %     for p=1:length(eventlog)-1
        %         if eventlog(p,1) == 1
        %             cluster(a,i) = cluster(a,i) + 1;
        %         elseif eventlog(p,1) ~= 1 && eventlog(p+1,1) == 1
        %             a = a+1;
        %         end
        %     end
        %    clusterave(i,1) = sum(cluster(:,i)) / sum(cluster(:,i)~=0);
    end
    totaltimediff(:,h) = timediffave(:,:);
end
% 
% 
X = 1;
totaltimediffave = mean(totaltimediff'); 

cb = cbrewer('seq', 'PuBu',5);
scatter(1,totaltimediff(1,1),100,'filled','DisplayName','Animal 1','MarkerFaceColor',cb(1,:)); hold on 
plot(X, totaltimediff(:,1),'Color',cb(1,:))
scatter(1,totaltimediff(1,2),100,'filled','DisplayName','Animal 2','MarkerFaceColor',cb(2,:));
plot(X, totaltimediff(:,2),'Color',cb(2,:))
scatter(1,totaltimediff(1,3),100,'filled','DisplayName','Animal 3','MarkerFaceColor',cb(3,:)); 
plot(X, totaltimediff(:,3),'Color',cb(3,:))
scatter(1,totaltimediff(1,4),100,'filled','DisplayName','Animal 4','MarkerFaceColor',cb(4,:)); 
plot(X, totaltimediff(:,4),'Color',cb(4,:))

b = bar(X,totaltimediffave,'FaceColor', cb(5,:));
uistack(b,'bottom');
set(gca, 'FontName', 'Arial');
set(gca, 'FontSize',15);
xticks([1 2])
xticklabels({'First Day', 'Last Day'});
ystr = "Ave time between" + "\n" + "first and last lick(s)";
ystr = compose(ystr);
newstr = splitlines(ystr);
ylabel(newstr);


SEM = std(totaltimediff(1,:)) / sqrt(length(animals));
% SEM2 = std(totaltimediff(2,:)) / sqrt(length(animals));
er = errorbar(X,totaltimediffave,SEM,'Color',cb(5,:),'linestyle','none','LineWidth',1,'HandleVisibility','off'); 

% xticklabels({'Time (s)', 'Consummatory licks(#)'});
% ylabel('Unit amount between first and last operant lick');
% legend
