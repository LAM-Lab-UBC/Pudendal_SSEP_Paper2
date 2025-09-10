function [fig] = latency_event(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format, Seperator)
components = {'Onset','P1','N1','P2','N2'};

%% Confidence
Latency_ERP = zeros(length(reviewers_ERP), length(components));
Latency_ERP_count = zeros(size(Latency_ERP));
Latency_TF = zeros(length(reviewers_ERP), length(components));
Latency_TF_count = zeros(size(Latency_TF));
Latency_ERP_All = [];
Latency_TF_All = [];


for i = 1:length(allParticipant_format)
    for c = 1:length(components)
        expert_field = ['Experts_' components{c}];
        expert_label = allParticipant_format(i).(expert_field);

        for r = 1:length(reviewers_ERP)
            reviewer_field = [reviewers_ERP{r} '_' components{c}];
            late_field = [reviewers_ERP{r} '_' components{c} '_Time'];
            reviewer_label = allParticipant_format(i).(reviewer_field);
            Latencty = allParticipant_format(i).(late_field);
            % Swapped indexing: (component, reviewer)
            if ~isempty(Latencty)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes')
                    Latency_ERP(r, c) = Latency_ERP(r, c) + Latencty;
                    Latency_ERP_count(r, c) = Latency_ERP_count(r, c) + 1;
                    Latency_ERP_All = [Latency_ERP_All; Latencty];
                end
            end
        end

        for v = 1:length(reviewers_TF)
            reviewer_field = [reviewers_TF{v} '_' components{c}];
            late_field = [reviewers_TF{v} '_' components{c} '_Time'];
            reviewer_label = allParticipant_format(i).(reviewer_field);
            Latencty = allParticipant_format(i).(late_field);
            % Swapped indexing: (component, reviewer)
            if ~isempty(Latencty)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes')
                    Latency_TF(v, c) = Latency_TF(v, c) + Latencty;
                    Latency_TF_count(v, c) = Latency_TF_count(v, c) + 1;
                    Latency_TF_All = [Latency_TF_All; Latencty];
                end
            end
        end
    end
end
Late_avg_ERP = zeros(size(Latency_ERP));
Late_avg_TF = zeros(size(Latency_TF));
    for c = 1:width(Latency_ERP_count)
    for r = 1:length(Latency_ERP_count)
Late_avg_ERP(r,c) = Latency_ERP(r,c) / Latency_ERP_count(r,c);
Late_avg_TF(r,c) = Latency_TF(r,c) / Latency_TF_count(r,c);
    end
end

components = {'Onset','P1','N1','P2','N2'};
dayLabel    = {'ERP', 'TF'};
reviewerNames = strrep(reviewers_ERP,'_ERP','');   % {'Reviewer1' …}
fig = figure('Color','w','units','normalized','outerposition',[0.01 0.04 0.98 0.98]);
t = tiledlayout("vertical","TileSpacing","compact","Padding","compact");  % 1-row grid
theme(fig,"light")

% Get experience levels per reviewer (from first participant)
nReviewers = length(reviewers_ERP);
experienceLevels = cell(1, nReviewers);
uniqueExperiences = {};

for r = 1:nReviewers
    nameShort = sprintf('Reviewer%d', r);
    if strcmp(Seperator, 'Experience')
    experienceField = [nameShort '_ERP_Experience'];
    elseif strcmp(Seperator, 'Education')
    experienceField = [nameShort '_ERP_Education'];
    end
    if isfield(allParticipant_format(1), experienceField)
        experience = allParticipant_format(1).(experienceField);
        experienceLevels{r} = experience;
        if ~ismember(experience, uniqueExperiences)
            uniqueExperiences{end+1} = experience;
        end
    else
        experienceLevels{r} = 'Unknown';
    end
end

% Assign colors by experience
experienceColors = lines(numel(uniqueExperiences));
reviewerClrByExperience = zeros(nReviewers, 3);
for r = 1:nReviewers
    expIdx = find(strcmp(experienceLevels{r}, uniqueExperiences));
    reviewerClrByExperience(r, :) = experienceColors(expIdx, :);
end


reviewerNames = strrep(reviewers_ERP,'_ERP','');
for c = 1:numel(components)
    nexttile
hForLegend = [];
h = plotPair(gca , Late_avg_ERP(:,c) , Late_avg_TF(:,c) , 1 , ...
    nReviewers, reviewerClrByExperience, reviewerNames , components{c});
if isempty(hForLegend)
    hForLegend = h;
end
end
title(t, "Latency Difference:ERP vs TF")
% Group legend entries by unique experience level
[~, idxFirst] = unique(experienceLevels, 'stable');  % Indices of first occurrence
legendHandles = hForLegend(idxFirst);
legendLabels = experienceLevels(idxFirst);

legend(legendHandles, legendLabels, 'Location', 'northwest', 'Box', 'off');
end 
function h = plotPair(ax, erpMat, tfMat, cidx, nReviewers, reviewerClrByExperience, reviewerNames , components)

axes(ax);  cla(ax)
data   = [tfMat(:,cidx); erpMat(:,cidx)];
groups = [ones(nReviewers,1);  2*ones(nReviewers,1)];

boxplot(data, groups, 'Labels',{'TF' ; 'ERP'}, ...
    'PlotStyle','traditional','Widths',.5,'Colors',[0 0 0], 'Orientation', 'horizontal');
hold on
h = gobjects(nReviewers,1);
for r = 1:nReviewers
    h(r) = plot([tfMat(r,cidx) erpMat(r,cidx)],[1 2], '-o', ...
        'Color', reviewerClrByExperience(r,:), ...
        'MarkerFaceColor', reviewerClrByExperience(r,:), ...
        'LineWidth',1.2, ...
        'DisplayName', reviewerNames{r});
end

title(components);
%ylabel(rowLabel)
xlabel("Timing (ms)")
%ylim padded;



grid on;  set(gca,'FontSize',9)
xlim([-2.6 2.8])

hold off
end

