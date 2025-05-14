function T = scatterSEP(allParticipant)
% scatterSEP: Scatter plot of reviewer confidence per event for ERP vs Full days.
%   allParticipant: 1×N struct array with fields Participant_Info, Trial, Reviewer_*
%   Returns T: table in long format with columns:
%       TraceIndex, TrialNum, Reviewer, DayType, Event, Confidence

    % --- Setup
    fn = fieldnames(allParticipant);
    revFields = fn(startsWith(fn,'Reviewer_'));
    nReviewers = numel(revFields);
    events = {'Onset','P1','N1','P2','N2'};
    N = numel(allParticipant);

    % --- Colormap (tab10 if available)
    try
        baseColors = tab10;
    catch
        baseColors = lines(10);
    end
    if nReviewers <= size(baseColors,1)
        colors = baseColors(1:nReviewers,:);
    else
        colors = lines(nReviewers);
    end

    % --- Prepare storage for table
    TraceIdxList = [];
    TrialNumList = string([]);
    ReviewerList = string([]);
    DayTypeList  = string([]);
    EventList    = string([]);
    ConfList     = [];

    % --- Collect data
    for traceIdx = 1:N
        trialNum = allParticipant(traceIdx).Participant_Info.Trial_Num;
        for r = 1:nReviewers
            revName = revFields{r};
            revStruct = allParticipant(traceIdx).(revName);
            revNum    = sscanf(revName,'Reviewer_%d');
            % Two day types
            for dt = 1:2
                if dt == 1
                    dayType = 'ERP';
                    if revNum <= 2, dayField = 'Day_1'; else dayField = 'Day_2'; end
                else
                    dayType = 'Full';
                    if revNum <= 2, dayField = 'Day_2'; else dayField = 'Day_1'; end
                end
                if ~isfield(revStruct, dayField), continue; end
                dayStruct = revStruct.(dayField);
                % For each event
                for e = 1:numel(events)
                    ev = dayStruct.(events{e});
                    if strcmpi(ev.Response,'Yes')
                        conf = round(ev.Confidence,2);
                        % Store
                        TraceIdxList(end+1,1) = traceIdx;
                        TrialNumList(end+1,1) = trialNum;
                        ReviewerList(end+1,1) = revName;
                        DayTypeList(end+1,1)  = dayType;
                        EventList(end+1,1)    = events{e};
                        ConfList(end+1,1)     = conf;
                    end
                end
            end
        end
    end

    % --- Build table
    T = table(TraceIdxList, TrialNumList, ReviewerList, DayTypeList, EventList, ConfList, ...
              'VariableNames',{'TraceIndex','TrialNum','Reviewer','DayType','Event','Confidence'});

    % --- Plotting
    figure;
    tiledlayout(numel(events),2,'TileSpacing','compact','Padding','compact');
    for e = 1:numel(events)
        for dt = 1:2
            ax = nexttile;
            hold(ax,'on');
            % Select relevant rows
            currentDay = ifelse(dt==1,'ERP','Full');
            mask = (T.Event == events{e}) & (T.DayType == currentDay);
            % Plot per reviewer color, filled markers
            for r = 1:nReviewers
                revName = revFields{r};
                submask = mask & (T.Reviewer == revName);
                scatter(ax, T.Confidence(submask), T.TraceIndex(submask), 36, ...
                        colors(r,:), 'filled', 'DisplayName', revName);
            end
            hold(ax,'off');
            xlim(ax,[0 1]);
            xlabel(ax,'Confidence');
            ylabel(ax,'Trace Index');
            title(ax,sprintf('%s (%s)', events{e}, currentDay));
            legend(ax,'Location','best');
        end
    end
end

% Helper inline ifelse
function out = ifelse(cond, a, b)
    if cond, out = a; else out = b; end
end