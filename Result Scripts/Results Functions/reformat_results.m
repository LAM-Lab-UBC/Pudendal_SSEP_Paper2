function [allParticipant_format] = reformat_results(reviewerNames, confidenceMap, allParticipant)

orderTypes = {'Overall_Response', 'Onset', 'P1', 'N1', 'P2', 'N2'};
components = {'ERP', 'TF'};
confidenceComponents = {'Onset', 'P1', 'N1', 'P2', 'N2'};

for i = 1:length(allParticipant)
    ap = allParticipant(i);

    % Basic info
    allParticipant_format(i).Trial = ap.Participant_Info.Trial_Num;
    allParticipant_format(i).Binned = ap.Binned;
    allParticipant_format(i).Experts = i;
    

    % Review order
    for r = 1:numel(reviewerNames)
        reviewer = reviewerNames{r};
        nameShort = sprintf('Reviewer%d', r);
        dayPair = confidenceMap(reviewer);  % {ERP_day, TF_day}

        % Use the mapped days for ERP and TF order assignment
        allParticipant_format(i).([nameShort '_ERP']) = ap.(reviewer).(dayPair{1}).order;
        allParticipant_format(i).([nameShort '_TF'])  = ap.(reviewer).(dayPair{2}).order;
        allParticipant_format(i).([nameShort '_ERP_Experience']) = ap.(reviewer).Experience;
        allParticipant_format(i).([nameShort '_ERP_Education']) = ap.(reviewer).Education;
    end

    % Expert overall & component responses (unchanged, always Day_2)
    allParticipant_format(i).Experts_Overall = ap.Expert_Review.Day_2.Overall_Response;
    for j = 2:numel(orderTypes) % Skip 'Overall_Response'
        type = orderTypes{j};
        allParticipant_format(i).(['Experts_' type]) = ap.Expert_Review.Day_2.(type).Response;
    end

    % Reviewers' overall/component responses
    for r = 1:numel(reviewerNames)
        reviewer = reviewerNames{r};
        nameShort = sprintf('Reviewer%d', r);
        dayPair = confidenceMap(reviewer);  % {ERP_day, TF_day}

        for c = 1:numel(components)
            comp = components{c};
            % ERP day for this component
            erpDay = dayPair{1};
            % TF day for this component
            tfDay = dayPair{2};

            % Overall response
            overallField_ERP = [nameShort '_ERP_Overall'];
            overallField_TF = [nameShort '_TF_Overall'];
            allParticipant_format(i).(overallField_ERP) = ap.(reviewer).(erpDay).Overall_Response;
            allParticipant_format(i).(overallField_TF) = ap.(reviewer).(tfDay).Overall_Response;

            % Component responses (Onset, P1, N1, P2, N2)
            for j = 2:numel(orderTypes)
                type = orderTypes{j};
                compField = [nameShort '_ERP_' type];
                compFieldTF = [nameShort '_TF_' type];
                allParticipant_format(i).(compField) = ap.(reviewer).(erpDay).(type).Response;
                allParticipant_format(i).(compFieldTF) = ap.(reviewer).(tfDay).(type).Response;
            end

            % Now TF component responses
            %overallFieldTF = [nameShort '_' comp '_Overall_TF'];
            %allParticipant_format(i).([nameShort '_TF_Overall']) = ap.(reviewer).(tfDay).Overall_Response;
            % 
            % for j = 2:numel(orderTypes)
            %     type = orderTypes{j};
            %     compFieldTF = [nameShort '_' comp '_' type];
            %     allParticipant_format(i).(compFieldTF) = ap.(reviewer).(tfDay).(type).Response;
            % end
        end
    end

    % === Timestamp difference for each component (Onset, P1, N1, P2, N2) ===
    timeComponents = {'Onset', 'P1', 'N1', 'P2', 'N2'};

    for tc = 1:numel(timeComponents)
        compName = timeComponents{tc};
        expertField = ap.Expert_Review.Day_2.(compName);

        if strcmp(expertField.Response, 'Yes')
            expertTime = expertField.time;
            allParticipant_format(i).(['Experts_' compName '_Time']) = expertTime;

            for r = 1:numel(reviewerNames)
                reviewer = reviewerNames{r};
                nameShort = sprintf('Reviewer%d', r);
                dayPair = confidenceMap(reviewer);  % {ERP_day, TF_day}

                % ERP timing difference using ERP day for that reviewer
                if isfield(ap.(reviewer).(dayPair{1}), compName) && ...
                   strcmp(ap.(reviewer).(dayPair{1}).(compName).Response, 'Yes')
                    diffERP = expertTime - ap.(reviewer).(dayPair{1}).(compName).time;
                else
                    diffERP = NaN;
                end
                allParticipant_format(i).([nameShort '_ERP_' compName '_Time']) = diffERP;

                % TF timing difference using TF day for that reviewer
                if isfield(ap.(reviewer).(dayPair{2}), compName) && ...
                   strcmp(ap.(reviewer).(dayPair{2}).(compName).Response, 'Yes')
                    diffTF = expertTime - ap.(reviewer).(dayPair{2}).(compName).time;
                else
                    diffTF = NaN;
                end
                allParticipant_format(i).([nameShort '_TF_' compName '_Time']) = diffTF;
            end
        else
            allParticipant_format(i).(['Experts_' compName '_Time']) = NaN;
            for r = 1:numel(reviewerNames)
                nameShort = sprintf('Reviewer%d', r);
                allParticipant_format(i).([nameShort '_ERP_' compName '_Time']) = NaN;
                allParticipant_format(i).([nameShort '_TF_' compName '_Time']) = NaN;
            end
        end
    end

    % === Confidence values already use confidenceMap, so they are correct
    % ===\ confidenceComponents = {'Onset', 'P1', 'N1', 'P2', 'N2'};
    %confidenceMap = containers.Map( ...
        %{'Reviewer_1', 'Reviewer_2', 'Reviewer_3', 'Reviewer_4', 'Reviewer_5', 'Reviewer_6', 'Reviewer_7', 'Reviewer_8', 'Reviewer_9', 'Reviewer_10', 'Reviewer_11', 'Reviewer_12'},  ...
        %{{'Day_1', 'Day_2'}, {'Day_1', 'Day_2'}, {'Day_2', 'Day_1'}, ...
         %{'Day_2', 'Day_1'}, {'Day_1', 'Day_2'}, {'Day_1', 'Day_2'}, {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'}, {'Day_1', 'Day_2'}, {'Day_1', 'Day_2'}, {'Day_2', 'Day_1'}, {'Day_2', 'Day_1'}});  % ERP, TF day swap

    for r = 1:numel(reviewerNames)
        reviewer = sprintf('Reviewer_%d', r);
        nameShort = sprintf('Reviewer%d', r);
        dayPair = confidenceMap(reviewer);  % {ERP_day, TF_day}

        for cc = 1:numel(confidenceComponents)
            comp = confidenceComponents{cc};

            % ERP Confidence
            if isfield(ap.(reviewer).(dayPair{1}), comp) && ...
               isfield(ap.(reviewer).(dayPair{1}).(comp), 'Confidence')
                allParticipant_format(i).([nameShort '_ERP_' comp '_Confidence']) = ...
                    ap.(reviewer).(dayPair{1}).(comp).Confidence;
            else
                allParticipant_format(i).([nameShort '_ERP_' comp '_Confidence']) = NaN;
            end

            % TF Confidence
            if isfield(ap.(reviewer).(dayPair{2}), comp) && ...
               isfield(ap.(reviewer).(dayPair{2}).(comp), 'Confidence')
                allParticipant_format(i).([nameShort '_TF_' comp '_Confidence']) = ...
                    ap.(reviewer).(dayPair{2}).(comp).Confidence;
            else
                allParticipant_format(i).([nameShort '_TF_' comp '_Confidence']) = NaN;
            end
        end
    end
end

% Convert struct array to table
T = struct2table(allParticipant_format);

% Write table to CSV
writetable(T, 'allParticipant_format.csv');% Convert struct array to table
