% Adds a swarmchart under the boxplot to better see how data falls 
function [fig] = Confidence_box(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format, Seperator)

components = {'Onset','P1','N1','P2','N2'};
%% Confidence
conf_ERP_Correct = zeros(length(reviewers_ERP), length(components));
conf_count_ERP_Correct = zeros(size(conf_ERP_Correct));

conf_TF_Correct = zeros(length(reviewers_TF), length(components));
conf_count_TF_Correct = zeros(size(conf_TF_Correct));

conf_ERP_Incorrect = zeros(length(reviewers_ERP), length(components));
conf_count_ERP_Incorrect = zeros(size(conf_ERP_Incorrect));

conf_TF_Incorrect = zeros(length(reviewers_TF), length(components));
conf_count_TF_Incorrect = zeros(size(conf_TF_Incorrect));

Onset_conf_ERP_Correct = [];
P1_conf_ERP_Correct = [];
P2_conf_ERP_Correct = [];
N1_conf_ERP_Correct = [];
N2_conf_ERP_Correct = [];

Onset_conf_ERP_Incorrect = [];
P1_conf_ERP_Incorrect = [];
P2_conf_ERP_Incorrect = [];
N1_conf_ERP_Incorrect = [];
N2_conf_ERP_Incorrect = [];

Onset_conf_TF_Correct = [];
P1_conf_TF_Correct = [];
P2_conf_TF_Correct = [];
N1_conf_TF_Correct = [];
N2_conf_TF_Correct = [];

Onset_conf_TF_Incorrect = [];
P1_conf_TF_Incorrect = [];
P2_conf_TF_Incorrect = [];
N1_conf_TF_Incorrect = [];
N2_conf_TF_Incorrect = [];

for i = 1:length(allParticipant_format)
    for c = 1:length(components)
        expert_field = ['Experts_' components{c}];
        expert_label = allParticipant_format(i).(expert_field);

        for r = 1:length(reviewers_ERP)
            reviewer_field = [reviewers_ERP{r} '_' components{c}];
            conf_field = [reviewers_ERP{r} '_' components{c} '_Confidence'];
            reviewer_label = allParticipant_format(i).(reviewer_field);
            confidence = allParticipant_format(i).(conf_field);
            % Swapped indexing: (component, reviewer)
            if ~isempty(confidence)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes') || strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'No')
                conf_ERP_Correct(r, c) = conf_ERP_Correct(r, c) + confidence;
                conf_count_ERP_Correct(r, c) = conf_count_ERP_Correct(r, c) + 1;
                if strcmpi(components{c}, "Onset")
                    Onset_conf_ERP_Correct = [Onset_conf_ERP_Correct; confidence*100];
                elseif strcmpi(components{c}, "P1")
                    P1_conf_ERP_Correct = [P1_conf_ERP_Correct; confidence*100];
                elseif strcmpi(components{c}, "N1")
                    N1_conf_ERP_Correct = [N1_conf_ERP_Correct; confidence*100];
                elseif strcmpi(components{c}, "P2")
                    P2_conf_ERP_Correct = [P2_conf_ERP_Correct; confidence*100];
                elseif strcmpi(components{c}, "N2")
                    N2_conf_ERP_Correct = [N2_conf_ERP_Correct; confidence*100];
                end 
                elseif strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'No') || strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'Yes')
                conf_ERP_Incorrect(r, c) = conf_ERP_Incorrect(r, c) + confidence;
                conf_count_ERP_Incorrect(r, c) = conf_count_ERP_Incorrect(r, c) + 1;

                if strcmpi(components{c}, "Onset")
                    Onset_conf_ERP_Incorrect = [Onset_conf_ERP_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "P1")
                    P1_conf_ERP_Incorrect = [P1_conf_ERP_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "N1")
                    N1_conf_ERP_Incorrect = [N1_conf_ERP_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "P2")
                    P2_conf_ERP_Incorrect = [P2_conf_ERP_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "N2")
                    N2_conf_ERP_Incorrect = [N2_conf_ERP_Incorrect; confidence*100];
                end 
                end 
            end
        end

        for v = 1:length(reviewers_TF)
            reviewer_field = [reviewers_TF{v} '_' components{c}];
            conf_field = [reviewers_TF{v} '_' components{c} '_Confidence'];
            reviewer_label = allParticipant_format(i).(reviewer_field);
            confidence = allParticipant_format(i).(conf_field);
            % Swapped indexing: (component, reviewer)
            if ~isempty(confidence)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes') || strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'No')
                conf_TF_Correct(v, c) = conf_TF_Correct(v, c) + confidence;
                conf_count_TF_Correct(v, c) = conf_count_TF_Correct(v, c) + 1;

                if strcmpi(components{c}, "Onset")
                    Onset_conf_TF_Correct = [Onset_conf_TF_Correct; confidence*100];
                elseif strcmpi(components{c}, "P1")
                    P1_conf_TF_Correct = [P1_conf_TF_Correct; confidence*100];
                elseif strcmpi(components{c}, "N1")
                    N1_conf_TF_Correct = [N1_conf_TF_Correct; confidence*100];
                elseif strcmpi(components{c}, "P2")
                    P2_conf_TF_Correct = [P2_conf_TF_Correct; confidence*100];
                elseif strcmpi(components{c}, "N2")
                    N2_conf_TF_Correct = [N2_conf_TF_Correct; confidence*100];
                end 
                elseif strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'No') || strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'Yes')
                    conf_TF_Incorrect(v, c) = conf_TF_Incorrect(v, c) + confidence;
                conf_count_TF_Incorrect(v, c) = conf_count_TF_Incorrect(v, c) + 1;

                if strcmpi(components{c}, "Onset")
                    Onset_conf_TF_Incorrect = [Onset_conf_TF_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "P1")
                    P1_conf_TF_Incorrect = [P1_conf_TF_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "N1")
                    N1_conf_TF_Incorrect = [N1_conf_TF_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "P2")
                    P2_conf_TF_Incorrect = [P2_conf_TF_Incorrect; confidence*100];
                elseif strcmpi(components{c}, "N2")
                    N2_conf_TF_Incorrect = [N2_conf_TF_Incorrect; confidence*100];
                end 
                end
            end
        end
    end
end



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


swarm.ERP.Incorrect = { ...
        Onset_conf_ERP_Incorrect , P1_conf_ERP_Incorrect , ...
        N1_conf_ERP_Incorrect    , P2_conf_ERP_Incorrect , ...
        N2_conf_ERP_Incorrect };

swarm.ERP.Correct   = { ...
        Onset_conf_ERP_Correct   , P1_conf_ERP_Correct   , ...
        N1_conf_ERP_Correct      , P2_conf_ERP_Correct   , ...
        N2_conf_ERP_Correct };

swarm.TF.Incorrect  = { ...
        Onset_conf_TF_Incorrect  , P1_conf_TF_Incorrect , ...
        N1_conf_TF_Incorrect     , P2_conf_TF_Incorrect , ...
        N2_conf_TF_Incorrect };

swarm.TF.Correct    = { ...
        Onset_conf_TF_Correct    , P1_conf_TF_Correct   , ...
        N1_conf_TF_Correct       , P2_conf_TF_Correct   , ...
        N2_conf_TF_Correct };

Conf_avg_ERP_Correct = conf_ERP_Correct ./ max(conf_count_ERP_Correct, 1) * 100;
Conf_avg_TF_Correct = conf_TF_Correct ./ max(conf_count_TF_Correct, 1)* 100;
Conf_avg_ERP_Incorrect = conf_ERP_Incorrect ./ max(conf_count_ERP_Incorrect, 1)* 100;
Conf_avg_TF_Incorrect = conf_TF_Incorrect ./ max(conf_count_TF_Incorrect, 1)* 100;
%make CSV of the average values of each person
avg_conf_ERP_Correct = array2table(Conf_avg_ERP_Correct, 'VariableNames', components, 'RowNames', reviewers_ERP);
avg_conf_ERP_Incorrect = array2table(Conf_avg_ERP_Incorrect, 'VariableNames', components, 'RowNames', reviewers_ERP);
avg_conf_TF_Correct = array2table(Conf_avg_TF_Correct, 'VariableNames', components, 'RowNames', reviewers_TF);
avg_conf_TF_Incorrect = array2table(Conf_avg_TF_Incorrect, 'VariableNames', components, 'RowNames', reviewers_TF);
writetable(avg_conf_ERP_Correct,    'avg_conf_ERP_Correct.csv',    'WriteRowNames', true);
writetable(avg_conf_ERP_Incorrect,  'avg_conf_ERP_Incorrect.csv',  'WriteRowNames', true);
writetable(avg_conf_TF_Correct,     'avg_conf_TF_Correct.csv',     'WriteRowNames', true);
writetable(avg_conf_TF_Incorrect,   'avg_conf_TF_Incorrect.csv',   'WriteRowNames', true);

components = {'onset','P1','N1','P2','N2'};
conditions = {'correct','incorrect'};
measures   = {'mean','median','SD'};
sources    = {'TF','ERP'};

% Map measure names to function handles
funcMap.mean   = @mean;
funcMap.median = @median;
funcMap.SD     = @(x) std(x,0); % std needs special handling for dim argument

% Map conditions to matrices
dataMap.correct.TF  = Conf_avg_TF_Correct;
dataMap.correct.ERP = Conf_avg_ERP_Correct;
dataMap.incorrect.TF  = Conf_avg_TF_Incorrect;
dataMap.incorrect.ERP = Conf_avg_ERP_Incorrect;

% Build stats struct
for m = 1:numel(measures)
    measureName = measures{m};
    for cond = 1:numel(conditions)
        condName = conditions{cond};
        for src = 1:numel(sources)
            srcName = sources{src};
            mat = dataMap.(condName).(srcName);
            for c = 1:numel(components)
                compName = components{c};
                stats.(measureName).(condName).(srcName).(compName) = ...
                    funcMap.(measureName)(mat(:,c));
            end
        end
    end
end

%nReviewers  = size(Conf_avg_ERP,1);
components  = {'Onset','P1','N1','P2','N2'};   % just to be sure
dayLabel    = {'ERP', 'TF'};
reviewerNames = strrep(reviewers_ERP,'_ERP','');   % {'Reviewer1' …}
fig = figure('Color','w', 'units','normalized','outerposition',[0.01 0.04 0.98 0.96]);
t = tiledlayout(2,5,"TileSpacing","compact","Padding","compact");  % 1-row grid
theme(fig,"light")

nReviewers  = size(Conf_avg_ERP_Correct,1);
reviewerClr = lines(nReviewers);          % fixed colour per reviewer

hForLegend = [];               % will store handles from the 1st tile

% top row : incorrect 
for c = 1:numel(components)
    nexttile
    h = plotPair(gca , Conf_avg_ERP_Incorrect , Conf_avg_TF_Incorrect , c , ...
             'Confidence (%)' , components , reviewerClrByExperience , nReviewers , ...
             "Incorrect" , reviewerNames , ...
             swarm.ERP.Incorrect{c} , swarm.TF.Incorrect{c});
    if isempty(hForLegend)
        hForLegend = h;
    end
end

%  bottom row : correct 
for c = 1:numel(components)
    nexttile
    plotPair(gca , Conf_avg_ERP_Correct , Conf_avg_TF_Correct , c , ...
             'Confidence (%)' , components , reviewerClrByExperience , nReviewers , ...
             "Correct" , reviewerNames , ...
             swarm.ERP.Correct{c} , swarm.TF.Correct{c});
end

% Group legend entries by unique experience level
[~, idxFirst] = unique(experienceLevels, 'stable');  % Indices of first occurrence
legendHandles = hForLegend(idxFirst);
legendLabels = experienceLevels(idxFirst);

legend(legendHandles, legendLabels, 'Location', 'northwest', 'Box', 'off');
%xlabel(t,"Day");   
title(t,"Reviewer confidence by component")

end
function h = plotPair(ax, erpMat, tfMat, cidx, rowLabel, components , ...
                      reviewerClr, nReviewers, correctness, revNames , ...
                      swERP, swTF)

    axes(ax);  cla(ax)

    data   = [erpMat(:,cidx);  tfMat(:,cidx)];
    groups = [ones(nReviewers,1);  2*ones(nReviewers,1)];
    boxplot(data, groups, 'Labels',{'ERP','TF'}, ...
            'PlotStyle','traditional','Widths',.5,'Colors',[0 0 0]);
    hold on

    bx2 = findobj(gca,'Tag','boxplot');
    set(bx2.Children,'LineWidth',1.5)

    swarmchart( ones(size(swERP)) , swERP , 18 , 'k', ...
                'filled', 'MarkerFaceAlpha',0.35 , ...
                'XJitterWidth',0.5 , 'HandleVisibility','off');

    swarmchart( 2*ones(size(swTF)) , swTF , 18 , 'k', ...
                'filled', 'MarkerFaceAlpha',0.35 , ...
                'XJitterWidth',0.5 , 'HandleVisibility','off');

    h = gobjects(nReviewers,1);
    for r = 1:nReviewers
        h(r) = plot([1 2], [erpMat(r,cidx) tfMat(r,cidx)], '-o', ...
                    'Color', reviewerClr(r,:), ...
                    'MarkerFaceColor', reviewerClr(r,:), ...
                    'LineWidth',1.2, ...
                    'DisplayName', revNames{r});
    end

    title([components{cidx} "  " correctness]);
    ylabel(rowLabel)
    ylim([0 100])
    grid on
    set(gca,'FontSize',9)
    hold off
end

