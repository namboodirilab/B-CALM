%%

% plot average left lick perference for all animals
animals = ['Animal1';'Animal2';'Animal3';'Animal4']; % define animals (subfolders)
animalnum = size(animals, 1);
Side_reward_proportion = zeros(animalnum, 7); % initialize parameter
side = 'right'; % define the unchanged side
type = 'manual_round1'; % subfolder, can be removed

Y = zeros(1, 7);
for k = 1:animalnum
    Side_reward_proportion(k, :) = proportionoflickononeside(animals(k, :), side, type); % get the side preference on opposite side with varying rewards for each animal
    Y = Y + Side_reward_proportion(k, :); % store in the Y variable

end

Y = Y/size(animals, 1);
SEM = std(Side_reward_proportion, 0, 1) / sqrt(animalnum); % 

X = [0:0.83:5];
cb1 = cbrewer('seq','Oranges', 5);
cb2 = cbrewer('seq','Purples',5);
if strcmp(side, 'left')
    subplot(1,2,1);
    errorbar(X, Y, SEM, 'Color',cb1(5,:),'LineStyle','-','Marker','o', 'LineWidth', 3, 'MarkerFaceColor', cb1(5,:), 'DisplayName', 'Reward on left side = 2.5ul'); hold on 
elseif strcmp(side, 'right')
    subplot(1,2,2);
    errorbar(X, Y, SEM, 'Color',cb2(5,:),'LineStyle','-', 'Marker','o','LineWidth', 3, 'MarkerFaceColor', cb2(5,:),'DisplayName','Reward on right side = 2.5ul'); hold on
end
set(gca, 'box','off');
xlabel('Reward on varying side (ul)');
ylabel('Percentage of getting reward on varying side');
title('Average of side preferences' )
grid on;
legend boxoff

%%
%plot individual animal's lick perference 
if strcmp(side,'left')
    subplot(1,2,1)
    plot(X, Side_reward_proportion(1, :),'Color',cb1(1,:),'LineStyle','-.',...
        'Marker','d','MarkerSize',10,'LineWidth', 1.5, 'DisplayName','F11'); hold on 
    plot(X, Side_reward_proportion(2, :), 'Color', cb1(2,:),'LineStyle','-.',...
        'Marker','*','MarkerSize',10,'LineWidth', 1.5, 'DisplayName','F12');  
    plot(X, Side_reward_proportion(3, :), 'Color', cb1(3,:),'LineStyle','-.',...
        'Marker','o','MarkerSize',10,'LineWidth', 1.5, 'DisplayName','F14'); 
    plot(X, Side_reward_proportion(4, :), 'Color', cb1(4,:),'LineStyle','-.',...
        'Marker','s','MarkerSize',10,'LineWidth', 1.5, 'DisplayName','F15');  
elseif strcmp(side,'right')
    subplot(1,2,2)
    plot(X, Side_reward_proportion(1, :),'Color',cb2(1,:), 'LineStyle','--',...
        'Marker','d','MarkerSize',10,'LineWidth', 1.5,'DisplayName','F11'); hold on 
    plot(X, Side_reward_proportion(2, :), 'Color',cb2(2,:),'LineStyle','--',...
        'Marker','*','MarkerSize',10,'LineWidth', 1.5,'DisplayName','F12');
    plot(X, Side_reward_proportion(3, :), 'Color', cb2(3,:),'LineStyle','--',...
        'Marker','o','MarkerSize',10,'LineWidth', 1.5,'DisplayName','F14');
    plot(X, Side_reward_proportion(4, :), 'Color', cb2(4,:),'LineStyle','--',...
        'Marker','s','MarkerSize',10,'LineWidth', 1.5,'DisplayName','F15');  
end
    
%%
% linear model of results 
% polyfit(X, Y, 1) returns the slope and intercept

%%
function [Side_reward_proportion] = proportionoflickononeside(animal, side, type)

s1 = '/filepath/';
s2 = '/';
s3 = '_side_fixed_';
s4 = type;

myFolder = strcat(s1, animal, s2, side, s3, s4); % Define your working folder
filePattern = fullfile(myFolder, '*.mat');
matFiles = dir(filePattern);

%Initialize parameters
rewardtotal = zeros(3, 7);
Left_side_reward_proportion = zeros(1, 7);
Right_side_reward_proportion = zeros(1, 7);

for k = 1:length(matFiles)
    baseFileName = matFiles(k).name;
    fullFileName = fullfile(myFolder, baseFileName);
    load(fullFileName); % load individual files
    
    param = regexprep(params, '+', ' '); % get parameters
    param = str2num(param);
    
    if eventlog(1, 1) == 10
        eventlog(1, :) = [];
    end

    lick1opentime = param(66);
    lick2opentime = param(67);
%     lick1delaytoreward = param(68);
%     lick2delaytoreward = param(69);
    
%     minrewardslick1 = param(72);
%     minrewardslick2 = param(73);

    rewards = eventlog(eventlog(:,1)==10,:); % get all delivered rewards
    [rewardsts,rewardsidx] = intersect(eventlog(:,2),rewards(:,2)); % get reward times
    cueforrewardts = rewardsts - 1000; % for each reward, get the cue preceding it
    [cueforrewardts,cueforrewardsidx] = intersect(eventlog(:,2),cueforrewardts); % get the cue's index

    lick1rewards = rewardsts(eventlog(cueforrewardsidx,1)==1, 1); % get lick 1 times on each reward 
    lick2rewards = rewardsts(eventlog(cueforrewardsidx,1)==3, 1); % get lick 2 times on each reward
    [lick1rewards, lick1rewardsidx] = intersect(rewardsts,lick1rewards);
    [lick2rewards, lick2rewardsidx] = intersect(rewardsts,lick2rewards);

% calculate the amount of licking proportion on each side
% %    For Not automated trials
if contains(type,'manual') == 1 
    if contains(side, 'left') == 1
        idx = lick2opentime / 10 +1;            % Comment out if doing right side fixed
    elseif contains(side, 'right') == 1
        idx = lick1opentime / 10 +1;            % Comment out if doing left side fixed
    end
    rewardtotal(1, idx) = size(lick1rewards,1);
    rewardtotal(2, idx) = size(lick2rewards,1);
    rewardtotal(3, idx) = rewardtotal(1, idx) + rewardtotal(2, idx);
    Left_side_reward_proportion(1, idx) = rewardtotal(1, idx) / rewardtotal(3, idx)*100;
    Right_side_reward_proportion(1, idx) = rewardtotal(2, idx) / rewardtotal(3, idx)*100;
    
%   For automated trials 
elseif contains(type,'auto') == 1
    for i=1:length(lick1rewardsidx)
        if lick1rewardsidx(i) <= 20
            rewardtotal(1, 1) = rewardtotal(1, 1) + 1;
        elseif lick1rewardsidx(i) > 21 && lick1rewardsidx(i) <= 40
            rewardtotal(1, 7) = rewardtotal(1, 7) + 1;
        elseif lick1rewardsidx(i) > 41 && lick1rewardsidx(i) <= 60
            rewardtotal(1, 2) = rewardtotal(1, 2) + 1;
        elseif lick1rewardsidx(i) > 61 && lick1rewardsidx(i) <= 80
            rewardtotal(1, 6) = rewardtotal(1, 6) + 1;        
        elseif lick1rewardsidx(i) > 81 && lick1rewardsidx(i) <= 100
            rewardtotal(1, 3) = rewardtotal(1, 3) + 1;  
        elseif lick1rewardsidx(i) > 101 && lick1rewardsidx(i) <= 120
            rewardtotal(1, 5) = rewardtotal(1, 5) + 1;
        elseif lick1rewardsidx(i) > 120 && lick1rewardsidx(i) <= 140
            rewardtotal(1, 4) = rewardtotal(1, 4) + 1;
        end 
    end
    for i=1:length(lick2rewardsidx)
        if lick2rewardsidx(i) <= 20
            rewardtotal(2, 1) = rewardtotal(2, 1) + 1;
        elseif lick2rewardsidx(i) > 21 && lick2rewardsidx(i) <= 40
            rewardtotal(2, 7) = rewardtotal(2, 7) + 1;
        elseif lick2rewardsidx(i) > 41 && lick2rewardsidx(i) <= 60
            rewardtotal(2, 2) = rewardtotal(2, 2) + 1;
        elseif lick2rewardsidx(i) > 61 && lick2rewardsidx(i) <= 80
            rewardtotal(2, 6) = rewardtotal(2, 6) + 1;        
        elseif lick2rewardsidx(i) > 81 && lick2rewardsidx(i) <= 100
            rewardtotal(2, 3) = rewardtotal(2, 3) + 1;  
        elseif lick2rewardsidx(i) > 101 && lick2rewardsidx(i) <= 120
            rewardtotal(2, 5) = rewardtotal(2, 5) + 1;
        elseif lick2rewardsidx(i) > 120 && lick2rewardsidx(i) <= 140
            rewardtotal(2, 4) = rewardtotal(2, 4) + 1;
        end 
    end    
    rewardtotal(3,:) = rewardtotal(1,:) + rewardtotal(2,:);
    for j=1:7
        Left_side_reward_proportion(1, j) = rewardtotal(1, j) / rewardtotal(3, j)*100;
        Right_side_reward_proportion(1, j) = rewardtotal(2, j) / rewardtotal(3, j)*100;
    end
end
end
    if contains(side, 'left') == 1
        Side_reward_proportion = Right_side_reward_proportion;      
    elseif contains(side, 'right') == 1
        Side_reward_proportion = Left_side_reward_proportion;
    end
   
end