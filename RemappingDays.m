% --- rename Day_1/Day_2 to ERP/Full for all participants & reviewers ---
% mapping: reviewers [1,2,5,6,9,10] do Day_1→ERP, Day_2→Full
%          reviewers [3,4,7,8] do Day_1→Full, Day_2→ERP

erpFirst = [1,2,5,6,9,10,14,15,16];
fullFirst = [3,4,7,8,11,12,13,17];

nTrials = numel(allParticipant);
for ti = 1:nTrials
    % get all fieldnames, pick out the reviewers
    fn = fieldnames(allParticipant(ti));
    isRev = startsWith(fn, 'Reviewer_');
    revNames = fn(isRev);
    
    for r = 1:numel(revNames)
        rev = revNames{r};
        % parse reviewer number
        tokens = regexp(rev, 'Reviewer_(\d+)', 'tokens', 'once');
        revNum = str2double(tokens{1});
        
        % decide new labels
        if ismember(revNum, erpFirst)
            name1 = 'ERP';
            name2 = 'Full';
        elseif ismember(revNum, fullFirst)
            name1 = 'Full';
            name2 = 'ERP';
        else
            warning('Reviewer_%d not in mapping—skipping rename.', revNum);
            continue
        end
        
        % do the rename
        allParticipant(ti).(rev).(name1) = allParticipant(ti).(rev).Day_1;
        allParticipant(ti).(rev).(name2) = allParticipant(ti).(rev).Day_2;
        allParticipant(ti).(rev) = rmfield(allParticipant(ti).(rev), {'Day_1','Day_2'});
    end
end