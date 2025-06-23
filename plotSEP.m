function plotSEP(allParticipant, dayType)
% plotSEP: Visualize SEP event selections by multiple reviewers.
%   allParticipant: 1×N struct array with fields Participant_Info, Trial, Reviewer_*
%   dayType: 'ERP' or 'Full'

    dayType = char(dayType);  % ensure char for switch

    % 1) Find all Reviewer_* fields
    fn = fieldnames(allParticipant);
    revFields = fn(startsWith(fn,'Reviewer_'));
    nReviewers = numel(revFields);

    % 2) Colormap for reviewers
    colors = lines(nReviewers);

    % 3) Menu for blocks of 10 trials
    opts = {"1-10","11-20","21-30","31-40","41-50","51-60"};
    choice = menu("Select traces to plot", opts);
    if choice<1 || choice>numel(opts), return; end
    startIdx = (choice-1)*10 + 1;
    endIdx   =  choice   *10;

    % 4) Create figure with 5 rows × 2 columns
    figure;
    tiledlayout(5,2,'TileSpacing','compact','Padding','compact');

    % Preallocate for legend creation later
    axesHandles = gobjects(endIdx-startIdx+1,1);
    count = 0;

    % 5) Loop through the selected 10 trials
    for traceIdx = startIdx:endIdx
        count = count + 1;
        ax = nexttile;
        axesHandles(count) = ax;
        hold(ax,'on');

        % Plot CzAvg vs time (–10 to 100 ms)
        tVec = allParticipant(traceIdx).Trial.times;
        yVec = allParticipant(traceIdx).Trial.CzAvg;
        idx = (tVec>=-10)&(tVec<=100);
        plot(ax, tVec(idx), yVec(idx), 'k');

        % 6) Overlay each reviewer’s event lines
        for r = 1:nReviewers
            revName   = revFields{r};
            revStruct = allParticipant(traceIdx).(revName);
            revNum    = sscanf(revName,'Reviewer_%d');

            % Map Day_1/Day_2 → ERP/Full
            switch dayType
              case 'ERP'
                dayField = ternary(revNum<=2,'Day_1','Day_2');
              case 'Full'
                dayField = ternary(revNum<=2,'Day_2','Day_1');
              otherwise
                error("dayType must be 'ERP' or 'Full'");
            end
            if ~isfield(revStruct, dayField), continue; end
            dayStruct = revStruct.(dayField);

            events = {'Onset','P1','N1','P2','N2'};
            for e = 1:numel(events)
                ev = dayStruct.(events{e});
                if strcmpi(ev.Response,'Yes')
                    conf = round(ev.Confidence,2);
                    if conf < 0.5
                        style = ':';    % low confidence → dotted
                    else
                        style = '-';    % high confidence → solid
                    end
                    % Thicker vertical lines for better visibility
                    xline(ax, ev.time, style, ...
                          'Color', colors(r,:), 'LineWidth', 2);
                end
            end
        end

        % Title and limits
        trialNum = allParticipant(traceIdx).Participant_Info.Trial_Num;
        title(ax, sprintf("%d: %s", traceIdx, trialNum));
        xlim(ax, [-10 100]);
        set(ax, 'YDir', 'reverse');
        hold(ax,'off');
    end

    % 7) Build a single legend on the **first** subplot
    ax0 = axesHandles(1);
    axes(ax0); hold(ax0,'on');

    % Reviewer color keys
    revLabels = cell(nReviewers,1);
    hRev = gobjects(nReviewers,1);
    for r = 1:nReviewers
        revLabels{r} = sprintf("Reviewer %d", sscanf(revFields{r}, 'Reviewer_%d'));
        hRev(r) = plot(ax0, NaN, NaN, '-', ...
                       'Color', colors(r,:), 'LineWidth', 2);
    end

    % Style keys
    styleLabels = { "Solid = Confidence ≥ 0.5"
                    "Dotted = Confidence < 0.5" };
    hStyle = gobjects(2,1);
    hStyle(1) = plot(ax0, NaN, NaN, '-', 'Color','k','LineWidth',2);
    hStyle(2) = plot(ax0, NaN, NaN, ':', 'Color','k','LineWidth',2);

    hold(ax0,'off');
    legend(ax0, [hRev; hStyle], [revLabels; styleLabels], 'Location','best');

    % 8) Super-title
    sgtitle(sprintf("SEP traces (%s days): Trials %d–%d", ...
            dayType, startIdx, endIdx));
end

% Helper inline ternary
function out = ternary(cond, a, b)
    if cond, out = a; else out = b; end
end
