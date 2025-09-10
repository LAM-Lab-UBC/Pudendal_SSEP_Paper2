function [] = Kappa_InterRate(reviewers_ERP, reviewers_TF, reviewers, allParticipant_format)
%components = {'Onset','P1','N1','P2','N2'};


ERP_Agreement = zeros(length(allParticipant_format), 2);
TF_Agreement = zeros(length(allParticipant_format), 2);

TF_Agreement_ICC = zeros(length(allParticipant_format), length(reviewers_ERP));
ERP_Agreement_ICC = zeros(length(allParticipant_format), length(reviewers_TF));

%Cohen_agreement_table = zeros(length(reviewers_TF), 6 );
nERP = numel(reviewers_ERP);
nTF  = numel(reviewers_TF);
Cohen_agreement_table = cell(max(nERP, nTF), 8);
Fleiss_agreement_table = cell(1, 6);
for r = 1:numel(reviewers)
    name = reviewers{r};      % e.g. 'Reviewer1_ERP'
    reviewerMats.(name) = zeros(2);  % 2×2 array of zeros
end

for i = 1:length(allParticipant_format)
    for r = 1:length(reviewers_ERP)
        if strcmp(allParticipant_format(i).([reviewers_ERP{r} '_Overall']), "Yes")
            ERP_Agreement(i, 1) = ERP_Agreement(i, 1) + 1;
            ERP_Agreement_ICC(i, r) = 1;
        elseif strcmp(allParticipant_format(i).([reviewers_ERP{r} '_Overall']), "No")
            ERP_Agreement(i, 2) = ERP_Agreement(i, 2) + 1;
            ERP_Agreement_ICC(i, r) = 0;
        end
    end


    for v = 1:length(reviewers_TF)
        if strcmp(allParticipant_format(i).([reviewers_TF{v} '_Overall']), "Yes")
            TF_Agreement(i, 1) = TF_Agreement(i, 1) + 1;
            TF_Agreement_ICC(i, v) = 1;
        elseif strcmp(allParticipant_format(i).([reviewers_TF{v} '_Overall']), "No")
            TF_Agreement(i, 2) = TF_Agreement(i, 2) + 1;
            TF_Agreement_ICC(i, v) = 0;
        end
    end
end

for i = 1:length(allParticipant_format)
    for r = 1:length(reviewers)
        name = reviewers{r};
        if strcmp(allParticipant_format(i).([reviewers{r} '_Overall']), "Yes") && strcmp(allParticipant_format(i).('Experts_Overall'), "Yes")
            reviewerMats.(name)(1, 1) = reviewerMats.(name)(1, 1) + 1;
        elseif strcmp(allParticipant_format(i).([reviewers{r} '_Overall']), "No") && strcmp(allParticipant_format(i).('Experts_Overall'), "Yes")
            reviewerMats.(name)(1, 2) = reviewerMats.(name)(1, 2) + 1;
        elseif strcmp(allParticipant_format(i).([reviewers{r} '_Overall']), "Yes") && strcmp(allParticipant_format(i).('Experts_Overall'), "No")
            reviewerMats.(name)(2, 1) = reviewerMats.(name)(2, 1) + 1;
        elseif strcmp(allParticipant_format(i).([reviewers{r} '_Overall']), "No") && strcmp(allParticipant_format(i).('Experts_Overall'), "No")
            reviewerMats.(name)(2, 2) = reviewerMats.(name)(2, 2) + 1;
        end
    end
end

% fleiss(TF_Agreement)
% fleiss(ERP_Agreement)
% kappa(reviewerMats.Reviewer7_TF)
cohen_array_ERP = [];
for r = 1:length(reviewers_ERP)
    name = reviewers_ERP{r};
    [k, ci, agreement] = Cohen_kappa(reviewerMats.(name));
    Cohen_agreement_table{r, 1} = k;
    Cohen_agreement_table{r, 2} = ci(1);
    Cohen_agreement_table{r, 3} = ci(2);
    Cohen_agreement_table{r, 4} = agreement;
    cohen_array_ERP = [cohen_array_ERP; k];

    %[k] = CohenInterRate(reviewerMats.(name));
    %Cohen_agreement_table{r, 6} = k;
end
cohen_array_TF = [];
for r = 1:length(reviewers_TF)
    name = reviewers_TF{r};
    [k, ci, agreement] = Cohen_kappa(reviewerMats.(name));
    Cohen_agreement_table{r, 5} = k;
    Cohen_agreement_table{r, 6} = ci(1);
    Cohen_agreement_table{r, 7} = ci(2);
    Cohen_agreement_table{r, 8} = agreement;
    cohen_array_TF = [cohen_array_TF; k];

    %[k] = CohenInterRate(reviewerMats.(name));
    %Cohen_agreement_table{r, 12} = k;
end

Var_names = {'K ERP', 'CI Lower ERP', 'CI Upper ERP','Agreement_ERP',  'K TF', 'CI Lower TF', 'CI Upper TF' ,'Agreement_TF'};
table_cohen = cell2table(Cohen_agreement_table(:,1:numel(Var_names)), 'VariableNames', Var_names, 'RowNames', reviewers_ERP);
writetable(table_cohen, 'Cohen_Interrater.csv', 'WriteRowNames', true);

[k, ci, agreement] = fleiss_kappa(ERP_Agreement);
Fleiss_agreement_table{1, 1} = k;
Fleiss_agreement_table{1, 2} = ci(1);
Fleiss_agreement_table{1, 3} = ci(2);
Fleiss_agreement_table{1, 4} = agreement;
% fleiss(ERP_Agreement)
[k, ci, agreement] = fleiss_kappa(TF_Agreement);
Fleiss_agreement_table{1, 5} = k;
Fleiss_agreement_table{1, 6} = ci(1);
Fleiss_agreement_table{1, 7} = ci(2);
Fleiss_agreement_table{1, 8} = agreement;
Var_names = {'K ERP', 'CI Lower ERP', 'CI Upper ERP','Agreement_ERP',  'K TF', 'CI Lower TF', 'CI Upper TF' ,'Agreement_TF'};
table_fleiss = cell2table(Fleiss_agreement_table(:,1:numel(Var_names)), 'VariableNames', Var_names, 'RowNames', {'All reviewers'});
writetable(table_fleiss, 'fleiss_Interrater.csv', 'WriteRowNames', true);

correct_yes = 0;
correct_no = 0;
for i = 1:length(TF_Agreement)
    if ERP_Agreement(i, 1) == 7
        correct_yes = correct_yes +1;
    end
    if ERP_Agreement(i, 2) == 7
        correct_no = correct_no +1;

    end
end

mean_kappa_TF = mean(cohen_array_TF);
std_kappa_TF = std(cohen_array_TF);

if mean_kappa_TF<0
    Mean_agreement_TF={'None'};
elseif mean_kappa_TF>=0 && mean_kappa_TF<=0.2
    Mean_agreement_TF={'None'};
elseif mean_kappa_TF>0.2 && mean_kappa_TF<0.4
    Mean_agreement_TF={'Minimal'};
elseif mean_kappa_TF>=0.4 && mean_kappa_TF<0.6
    Mean_agreement_TF={'Weak'};
elseif mean_kappa_TF>=0.6 && mean_kappa_TF<0.8
    Mean_agreement_TF={'Moderate'};
elseif mean_kappa_TF>=0.8 && mean_kappa_TF<=0.9
    Mean_agreement_TF={'Strong'};
elseif mean_kappa_TF>0.9
    Mean_agreement_TF={'Almost Perfect'};
end


mean_kappa_ERP = mean(cohen_array_ERP);
std_kappa_ERP = std(cohen_array_ERP);
if mean_kappa_ERP<0
    Mean_agreement_ERP={'None'};
elseif mean_kappa_ERP>=0 && k<=0.2
    Mean_agreement_ERP={'None'};
elseif mean_kappa_ERP>0.2 && k<0.4
    Mean_agreement_ERP={'Minimal'};
elseif mean_kappa_ERP>=0.4 && k<0.6
    Mean_agreement_ERP={'Weak'};
elseif mean_kappa_ERP>=0.6 && k<0.8
    Mean_agreement_ERP={'Moderate'};
elseif mean_kappa_ERP>=0.8 && k<=0.9
    Mean_agreement_ERP={'Strong'};
elseif mean_kappa_ERP>0.9
    Mean_agreement_ERP={'Almost Perfect'};
end
