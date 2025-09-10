addpath("Results Functions")

reviewerNames = {'Reviewer_1', 'Reviewer_2', 'Reviewer_3', 'Reviewer_4', ...
    'Reviewer_5', 'Reviewer_6', 'Reviewer_7', 'Reviewer_8', ...
    'Reviewer_9', 'Reviewer_10', 'Reviewer_11', 'Reviewer_12',...
    'Reviewer_13', 'Reviewer_14', 'Reviewer_15', 'Reviewer_16', ...
    'Reviewer_17', 'Reviewer_18', 'Reviewer_19', 'Reviewer_20'};

% format is 'Day they did ERP', 'Day they did TF'
confidenceMap = containers.Map( ...
    reviewerNames, ...
    {{'Day_1', 'Day_2'},{'Day_1', 'Day_2'}, {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'},...
    {'Day_1', 'Day_2'}, {'Day_1', 'Day_2'}, {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'},...
    {'Day_1', 'Day_2'}, {'Day_1', 'Day_2'}, {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'},...
    {'Day_2', 'Day_1'}, {'Day_1', 'Day_2'}, {'Day_1', 'Day_2'}, {'Day_1', 'Day_2'},...
    {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'}, {'Day_1', 'Day_2'}});

[allParticipant_format] = reformat_results(reviewerNames, confidenceMap, allParticipant);

numReviewers = length(reviewerNames);
reviewers_ERP = arrayfun(@(n) sprintf('Reviewer%d_ERP', n), 1:numReviewers, 'UniformOutput', false);
reviewers_TF  = strrep(reviewers_ERP, '_ERP', '_TF');
reviewers = [reviewers_ERP,reviewers_TF];

% Set as Education or Experience 
Seperator = 'Experience';

[fig1] = Binary_Stacked(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format);

[fig2] = latency_event(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format, Seperator);

[fig3] = Confusion(reviewers_ERP,reviewers_TF, reviewers, allParticipant_format, Seperator);

[fig4] = Confidence_box(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format, Seperator);

[fig5] = Latency_overall(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format, Seperator);

Kappa_InterRate(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format);

