function [fig] = Confusion(reviewers_ERP, ...
    reviewers_TF, reviewers, allParticipant_format, Seperator)

% Initialize: now rows = components, columns = reviewers
components = {'Overall'};


TP_count_ERP = zeros(length(components), length(reviewers_ERP));
TN_count_ERP = zeros(length(components), length(reviewers_ERP));
FP_count_ERP = zeros(length(components), length(reviewers_ERP));
FN_count_ERP = zeros(length(components), length(reviewers_ERP));

TP_count_TF = zeros(length(components), length(reviewers_TF));
TN_count_TF = zeros(length(components), length(reviewers_TF));
FP_count_TF = zeros(length(components), length(reviewers_TF));
FN_count_TF = zeros(length(components), length(reviewers_TF));

Expert_Yes = 0;
Expert_No = 0;

for i = 1:length(allParticipant_format)
    for c = 1:length(components)
        expert_field = ['Experts_' components{c}];
        expert_label = allParticipant_format(i).(expert_field);
        if strcmp(expert_label, 'Yes')
            Expert_Yes = Expert_Yes + 1;
        elseif strcmp(expert_label, 'No')
            Expert_No = Expert_No + 1;
        end

        for r = 1:length(reviewers_ERP)
            reviewer_field = [reviewers_ERP{r} '_' components{c}];
            reviewer_label = allParticipant_format(i).(reviewer_field);
            if isfield(allParticipant_format(i), reviewer_field)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes')
                    TP_count_ERP(c, r) = TP_count_ERP(c, r) + 1;
                elseif strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'No')
                    TN_count_ERP(c, r) = TN_count_ERP(c, r) + 1;
                elseif strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'No')
                    FP_count_ERP(c, r) = FP_count_ERP(c, r) + 1;
                elseif strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'Yes')
                    FN_count_ERP(c, r) = FN_count_ERP(c, r) + 1;
                end
            end
        end

        for r = 1:length(reviewers_TF)
            reviewer_field = [reviewers_TF{r} '_' components{c}];
            reviewer_label = allParticipant_format(i).(reviewer_field);
            if isfield(allParticipant_format(i), reviewer_field)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes')
                    TP_count_TF(c, r) = TP_count_TF(c, r) + 1;
                elseif strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'No')
                    TN_count_TF(c, r) = TN_count_TF(c, r) + 1;
                elseif strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'No')
                    FP_count_TF(c, r) = FP_count_TF(c, r) + 1;
                elseif strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'Yes')
                    FN_count_TF(c, r) = FN_count_TF(c, r) + 1;
                end
            end
        end
    end
end

% Compute summary metrics
TP_sum_ERP = sum(TP_count_ERP, 1);
FP_sum_ERP = sum(FP_count_ERP, 1);
FN_sum_ERP = sum(FN_count_ERP, 1);
TN_sum_ERP = sum(TN_count_ERP, 1);

TP_sum_TF = sum(TP_count_TF, 1);
FP_sum_TF = sum(FP_count_TF, 1);
FN_sum_TF = sum(FN_count_TF, 1);
TN_sum_TF = sum(TN_count_TF, 1);

% ERP Metrics
Accuracy    = (TP_sum_ERP + TN_sum_ERP) ./ (TP_sum_ERP + TN_sum_ERP + FP_sum_ERP + FN_sum_ERP);
Precision   = TP_sum_ERP ./ (TP_sum_ERP + FP_sum_ERP);
Recall      = TP_sum_ERP ./ (TP_sum_ERP + FN_sum_ERP);
Specificity = TN_sum_ERP ./ (TN_sum_ERP + FP_sum_ERP);
F1_score    = 2 * (Precision .* Recall) ./ (Precision + Recall);

Accuracy(isnan(Accuracy))       = 0;
Precision(isnan(Precision))     = 0;
Recall(isnan(Recall))           = 0;
Specificity(isnan(Specificity)) = 0;
F1_score(isnan(F1_score))       = 0;

Metrics_ERP = [Accuracy', Precision', Recall', Specificity', F1_score'];
MetricsTable_ERP= table(reviewers_ERP', Accuracy', Precision', Recall', Specificity', F1_score', ...
    'VariableNames', {'Reviewer', 'Accuracy', 'Precision', 'Recall', 'Specificity', 'F1_Score'});
writetable(MetricsTable_ERP, 'Confusion_Metrics_ERP.csv');
% TF Metrics
Accuracy    = (TP_sum_TF + TN_sum_TF) ./ (TP_sum_TF + TN_sum_TF + FP_sum_TF + FN_sum_TF);
Precision   = TP_sum_TF ./ (TP_sum_TF + FP_sum_TF);
Recall      = TP_sum_TF ./ (TP_sum_TF + FN_sum_TF);
Specificity = TN_sum_TF ./ (TN_sum_TF + FP_sum_TF);
F1_score    = 2 * (Precision .* Recall) ./ (Precision + Recall);

Accuracy(isnan(Accuracy))       = 0;
Precision(isnan(Precision))     = 0;
Recall(isnan(Recall))           = 0;
Specificity(isnan(Specificity)) = 0;
F1_score(isnan(F1_score))       = 0;

Metrics_TF = [Accuracy', Precision', Recall', Specificity', F1_score'];
MetricsTable_TF= table(reviewers_ERP', Accuracy', Precision', Recall', Specificity', F1_score', ...
    'VariableNames', {'Reviewer', 'Accuracy', 'Precision', 'Recall', 'Specificity', 'F1_Score'});
writetable(MetricsTable_TF, 'Confusion_Metrics_TF.csv');



Mean_ERP_Accuracy = mean(Metrics_ERP(:,1));
Mean_TF_Accuracy = mean(Metrics_TF(:,1));
Mean_ERP_Precision = mean(Metrics_ERP(:,2));
Mean_TF_Precision = mean(Metrics_TF(:,2));
Mean_ERP_Recall = mean(Metrics_ERP(:,3));
Mean_TF_Recall = mean(Metrics_TF(:,3));
Mean_ERP_Specificity = mean(Metrics_ERP(:,4));
Mean_TF_Specificity = mean(Metrics_TF(:,4));
Mean_ERP_F1 = mean(Metrics_ERP(:,5));
Mean_TF_F1 = mean(Metrics_TF(:,5));

Median_ERP_Accuracy = median(Metrics_ERP(:,1));
Median_TF_Accuracy = median(Metrics_TF(:,1));
Median_ERP_Precision = median(Metrics_ERP(:,2));
Median_TF_Precision = median(Metrics_TF(:,2));
Median_ERP_Recall = median(Metrics_ERP(:,3));
Median_TF_Recall = median(Metrics_TF(:,3));
Median_ERP_Specificity = median(Metrics_ERP(:,4));
Median_TF_Specificity = median(Metrics_TF(:,4));
Median_ERP_F1 = median(Metrics_ERP(:,5));
Median_TF_F1 = median(Metrics_TF(:,5));

SD_ERP_Accuracy = std(Metrics_ERP(:,1));
SD_TF_Accuracy = std(Metrics_TF(:,1));
SD_ERP_Precision = std(Metrics_ERP(:,2));
SD_TF_Precision = std(Metrics_TF(:,2));
SD_ERP_Recall = std(Metrics_ERP(:,3));
SD_TF_Recall = std(Metrics_TF(:,3));
SD_ERP_Specificity = std(Metrics_ERP(:,4));
SD_TF_Specificity = std(Metrics_TF(:,4));
SD_ERP_F1 = std(Metrics_ERP(:,5));
SD_TF_F1 = std(Metrics_TF(:,5));

increase_acc = 0;
decrease_acc = 0;
constant_acc = 0;

increase_prec = 0;
decrease_prec = 0;
constant_prec = 0;

increase_recall= 0;
decrease_recall = 0;
constant_recall = 0;

increase_spec = 0;
decrease_spec = 0;
constant_spec = 0;

increase_F1 = 0;
decrease_F1 = 0;
constant_F1 = 0;
for i = 1:length(reviewers_ERP)
    %accuracy
    if Metrics_ERP(i,1) < Metrics_TF(i,1)
        increase_acc = increase_acc + 1;
    elseif Metrics_ERP(i,1) > Metrics_TF(i,1)
        decrease_acc = decrease_acc + 1;
    elseif Metrics_ERP(i,1) == Metrics_TF(i,1)
        constant_acc = constant_acc + 1;
    end

    %precision
    if Metrics_ERP(i,2) < Metrics_TF(i,2)
        increase_prec = increase_prec + 1;
    elseif Metrics_ERP(i,2) > Metrics_TF(i,2)
        decrease_prec = decrease_prec + 1;
    elseif Metrics_ERP(i,2) == Metrics_TF(i,2)
        constant_prec = constant_prec + 1;
    end

    %Recall
    if Metrics_ERP(i,3) < Metrics_TF(i,3)
        increase_recall = increase_recall + 1;
    elseif Metrics_ERP(i,3) > Metrics_TF(i,3)
        decrease_recall = decrease_recall + 1;
    elseif Metrics_ERP(i,3) == Metrics_TF(i,3)
        constant_recall = constant_recall + 1;
    end

    % specificity
    if Metrics_ERP(i,4) < Metrics_TF(i,4)
        increase_spec = increase_spec + 1;
    elseif Metrics_ERP(i,4) > Metrics_TF(i,4)
        decrease_spec = decrease_spec + 1;
    elseif Metrics_ERP(i,4) == Metrics_TF(i,4)
        constant_spec = constant_spec + 1;
    end

    % F1 Score
    if Metrics_ERP(i,5) < Metrics_TF(i,5)
        increase_F1 = increase_F1 + 1;
    elseif Metrics_ERP(i,5) > Metrics_TF(i,5)
        decrease_F1 = decrease_F1 + 1;
    elseif Metrics_ERP(i,5) == Metrics_TF(i,5)
        constant_F1 = constant_F1 + 1;
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

% Plotting
componentsToPlot = {'Accuracy', 'Precision', 'Recall', 'Specificity', 'F1_score'};
reviewerNames = strrep(reviewers_ERP,'_ERP','');

fig = figure('Color','w', 'units','normalized','outerposition',[0.01 0.04 0.98 0.96]);
t = tiledlayout(1,5,"TileSpacing","compact","Padding","compact");  % 1-row grid
theme(fig,"light")

hForLegend = [];

for c = 1:numel(componentsToPlot)
    nexttile
    h = plotPair(gca , Metrics_ERP , Metrics_TF , c , ...
        ' ' , componentsToPlot , reviewerClrByExperience , nReviewers, ...
        " ", reviewerNames);
    if isempty(hForLegend)
        hForLegend = h;
    end
end

% Group legend entries by unique experience level
[~, idxFirst] = unique(experienceLevels, 'stable');  % Indices of first occurrence
legendHandles = hForLegend(idxFirst);
legendLabels = experienceLevels(idxFirst);

legend(legendHandles, legendLabels, 'Location', 'northwest', 'Box', 'off');
title(t,"Confusion Matrix by Experience")
end
% Function
function h = plotPair(ax, erpMat, tfMat, cidx, rowLabel, components, ...
    reviewerClr, nReviewers, correctness, revNames)
axes(ax); cla(ax)
data   = [erpMat(:,cidx);  tfMat(:,cidx)];
groups = [ones(nReviewers,1);  2*ones(nReviewers,1)];

boxplot(data, groups, 'Labels',{'ERP','TF'}, ...
    'PlotStyle','traditional','Widths',.5,'Colors',[0 0 0]);
hold on
h = gobjects(nReviewers,1);
for r = 1:nReviewers
    h(r) = plot([1 2], [erpMat(r,cidx) tfMat(r,cidx)], '-o', ...
        'Color', reviewerClr(r,:), ...
        'MarkerFaceColor', reviewerClr(r,:), ...
        'LineWidth',1.2, ...
        'DisplayName', revNames{r});

    % text(2.05, tfMat(r,cidx), revNames{r}, ...
    %     'Color', reviewerClr(r,:), ...
    %     'FontSize', 7, ...
    %     'HorizontalAlignment', 'left', ...
    %     'VerticalAlignment', 'middle');


end
title([components{cidx} " " correctness], 'Interpreter', 'none');
ylabel(rowLabel)
ylim([0.05 1.009]);
grid on; set(gca,'FontSize',9)
hold off
end


