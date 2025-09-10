function [fig] = Binary_Stacked(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format)
%Initialize: now rows = components, columns = reviewers
components = {'Overall'};

TP_count = zeros(length(components), length(reviewers));
TN_count = zeros(length(components), length(reviewers));
FP_count = zeros(length(components), length(reviewers));
FN_count = zeros(length(components), length(reviewers));
Expert_Yes = 0;
Expert_No = 0;
for i = 1:length(allParticipant_format)
    for c = 1:length(components)
        expert_field = ['Experts_' components{c}];
        expert_label = allParticipant_format(i).(expert_field);
        if strcmp(expert_label, 'Yes')
            Expert_Yes = Expert_Yes +1;
        elseif strcmp(expert_label, 'No')
            Expert_No = Expert_No +1;
        end

        for r = 1:length(reviewers)
            reviewer_field = [reviewers{r} '_' components{c}];
            reviewer_label = allParticipant_format(i).(reviewer_field);


            if isfield(allParticipant_format(i), reviewer_field)
                if strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'Yes')
                    TP_count(c, r) = TP_count(c, r) + 1;
                elseif strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'No')
                    TN_count(c, r) = TN_count(c, r) + 1;
                elseif strcmpi(reviewer_label, 'Yes') && strcmpi(expert_label, 'No')
                    FP_count(c, r) = FP_count(c, r) + 1;
                elseif strcmpi(reviewer_label, 'No') && strcmpi(expert_label, 'Yes')
                    FN_count(c, r) = FN_count(c, r) + 1;
                end
            end
            %display(reviewer_field)
        end
    end
end
%average confidence
%Compute averages

%general counts
FP_table = array2table(FP_count, 'VariableNames', reviewers, 'RowNames', components);
TP_table = array2table(TP_count, 'VariableNames', reviewers, 'RowNames', components);
FN_table = array2table(FN_count, 'VariableNames', reviewers, 'RowNames', components);
TN_table = array2table(TN_count, 'VariableNames', reviewers, 'RowNames', components);

Expert_Yes_Col = array2table(Expert_Yes, 'VariableNames', {'Expert_Yes'}, 'RowNames', components);
Expert_No_Col  = array2table(Expert_No, 'VariableNames', {'Expert_No'}, 'RowNames', components);

% Combine expert columns with the other tables
TP_table = [Expert_Yes_Col Expert_No_Col TP_table];
FP_table = [Expert_Yes_Col Expert_No_Col FP_table];
FN_table = [Expert_Yes_Col Expert_No_Col FN_table];
TN_table = [Expert_Yes_Col Expert_No_Col TN_table];



TP_count_with_expert = [Expert_Yes, TP_count];
TN_count_with_expert = [Expert_No, TN_count];
FP_count_with_expert = [0, FP_count];  % Experts don't make FP/FN
FN_count_with_expert = [0, FN_count];

TP_sum = sum(TP_count, 1);  % Sum across components
FP_sum = sum(FP_count, 1);
FN_sum = sum(FN_count, 1);
TN_sum = sum(TN_count, 1);


rows = {};
TP_vals = [];
FP_vals = [];
FN_vals = [];
TN_vals = [];

for c = 1:length(components)
    for r = 1:length(reviewers)
        rows{end+1,1} = components{c};
        rows{end,2} = reviewers{r};
        TP_vals(end+1,1) = TP_count(c,r);
        FP_vals(end+1,1) = FP_count(c,r);
        FN_vals(end+1,1) = FN_count(c,r);
        TN_vals(end+1,1) = TN_count(c,r);
    end
end

ConfusionMatrixTable = table(...
    rows(:,1), rows(:,2), TP_vals, FP_vals, FN_vals, TN_vals, ...
    'VariableNames', {'Component', 'Reviewer', 'TP', 'FP', 'FN', 'TN'} ...
    );

writetable(ConfusionMatrixTable, 'ConfusionMatrixCounts.csv');
num_reviewers = length(reviewers);

reviewers_with_expert = ['Expert', reviewers];

% === Compare ERP vs TF for each reviewer ===
num_people = length(reviewers_ERP);
reduced_count_fp = 0;
increased_count_fp = 0;
nochange_count_fp = 0;
reduced_count_fn  = 0;
increased_count_fn  = 0;
nochange_count_fn = 0;

for i = 1:num_people
    % ERP and TF indices in the FP/FN arrays
    erp_idx = i;             % ERP is in first half of reviewers
    tf_idx  = i + num_people; % TF is in second half

    % Get FP/FN counts for ERP and TF
    fp_erp = FP_count(:, erp_idx);
    fn_erp = FN_count(:, erp_idx);
    fp_tf  = FP_count(:, tf_idx);
    fn_tf  = FN_count(:, tf_idx);

    % Check differences
    if (fp_tf < fp_erp)
        reduced_count_fp = reduced_count_fp + 1;
    end

    if (fn_tf < fn_erp)
        reduced_count_fn = reduced_count_fn  + 1;
    end

    if (fp_tf > fp_erp)
        increased_count_fp = increased_count_fp + 1;
    end
    if (fn_tf > fn_erp)
        increased_count_fn = increased_count_fn + 1;
    end

    if (fp_tf == fp_erp)
        nochange_count_fp = nochange_count_fp + 1;
    end

    if (fn_tf == fn_erp)
        nochange_count_fn = nochange_count_fn + 1;
    end

end


%% Plot bar plot correctnes
darkgreen = "#83ac72";   %dark green
lightgreen = "#B3C6AC"; %light green
pink = "#C7ADAD"; %light red
red = "#B66868"; %red

% === Split reviewer indices ===
erp_idx = find(contains(reviewers, 'ERP'));
tf_idx = find(contains(reviewers, 'TF'));

% === Prepare ERP plot data ===
TP_erp = [Expert_Yes, TP_count(:, erp_idx)];
FP_erp = [0, FP_count(:, erp_idx)];
FN_erp = [0, FN_count(:, erp_idx)];
TN_erp = [Expert_No, TN_count(:, erp_idx)];
reviewers_erp = ['Expert', reviewers(erp_idx)];

% === Prepare TF plot data ===
TP_tf = [Expert_Yes, TP_count(:, tf_idx)];
FP_tf = [0, FP_count(:, tf_idx)];
FN_tf = [0, FN_count(:, tf_idx)];
TN_tf = [Expert_No, TN_count(:, tf_idx)];
reviewers_tf = ['Expert', reviewers(tf_idx)];

reviewerNames = strrep(reviewers_ERP,'_ERP','');
reviewers_shrt = ['Expert', reviewerNames];
fig = figure('units','normalized','outerposition',[0.01 0.04 0.58 0.96]);
tiledlayout("vertical")
gt = theme(fig,"light");
% === ERP Plot ===
nexttile
bh = bar([TP_erp; FP_erp; FN_erp; TN_erp]', 'stacked');
xticks(1:length(reviewers_erp));
xticklabels(reviewers_shrt);
xlabel('Reviewers (ERP)');
ylabel('Count');
title('Confusion Matrix Counts - ERP Reviewers');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'none');
yline(Expert_Yes, '--k', ...
    'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
legend({'TP','FP','FN','TN'});
bh(1).FaceColor = darkgreen;   %dark green
bh(2).FaceColor = lightgreen; %light green
bh(3).FaceColor = pink; %light red
bh(4).FaceColor = red; %red


%
%figure('units','normalized','outerposition',[0.01 0.04 0.98 0.96]);
nexttile
bh = bar([TP_tf; FP_tf; FN_tf; TN_tf]', 'stacked');
xticks(1:length(reviewers_tf));
xticklabels(reviewers_shrt);
xlabel('Reviewers (TF)');
ylabel('Count');
title('Confusion Matrix Counts - TF Reviewers');
set(gca, 'FontSize', 12, 'TickLabelInterpreter', 'none');
yline(Expert_Yes, '--k', ...
    'LineWidth', 1.5, 'LabelHorizontalAlignment', 'left', 'LabelVerticalAlignment', 'bottom');
legend({'TP','FP','FN','TN'});
bh(1).FaceColor = darkgreen;   %dark green
bh(2).FaceColor = lightgreen; %light green
bh(3).FaceColor = pink; %light red
bh(4).FaceColor = red; %red
