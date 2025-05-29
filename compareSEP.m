function compareSEP(allParticipant)
% compareSEP: Compare reviewer event selections for ERP vs Full days side-by-side.
%   allParticipant: 1×N struct array with fields Participant_Info, Trial, Reviewer_*

% 1) Detect reviewer fields and assign colors
fn = fieldnames(allParticipant);
revFields = fn(startsWith(fn,'Reviewer_'));
nReviewers = numel(revFields);
colors = lines(nReviewers);

% 2) Menu for blocks of 5 trials (multi-select)
N = numel(allParticipant);
blockStarts = 1:5:N;
opts = arrayfun(@(s) sprintf('%d–%d', s, min(s+4, N)), blockStarts, 'UniformOutput', false);

[selection, ok] = listdlg( ...
    'PromptString', 'Select blocks of 5 trials to compare:', ...
    'ListString', opts, ...
    'SelectionMode', 'multiple', ...
    'ListSize', [200 300]);

if ~ok || isempty(selection)
    return;
end

for s = 1:length(selection)
    startIdx = blockStarts(selection(s));
    endIdx   = min(startIdx + 4, N);

    % Plot current block
    figure('units','normalized','outerposition',[0.01 0.04 0.98 0.96]);
    tiledlayout(5,2,'TileSpacing','compact','Padding','compact');

    for r = 1:(endIdx - startIdx + 1)
        traceIdx = startIdx + r - 1;
        trialNum = allParticipant(traceIdx).Participant_Info.Trial_Num;

        % --- ERP column (col 1)
        ax1 = nexttile;
        hold(ax1,'on');
        tVec = allParticipant(traceIdx).Trial.times;
        yVec = allParticipant(traceIdx).Trial.CzAvg;
        mask = (tVec>=-10) & (tVec<=100);
        plot(ax1, tVec(mask), yVec(mask), 'k');
        for i = 1:nReviewers
            revName   = revFields{i};
            revStruct = allParticipant(traceIdx).(revName);
            revNum    = sscanf(revName, 'Reviewer_%d');
            % Map Day for ERP: reviewers 1-2 -> Day_1, others -> Day_2
            if revNum <= 2
                dayField = 'Day_1';
            else
                dayField = 'Day_2';
            end
            if ~isfield(revStruct, dayField), continue; end
            dayStruct = revStruct.(dayField);
            events = {'Onset','P1','N1','P2','N2'};
            for e = 1:numel(events)
                ev = dayStruct.(events{e});
                if strcmpi(ev.Response,'Yes')
                    conf = round(ev.Confidence,2);
                    if conf < 0.5, style = ':'; else style = '-'; end
                    xline(ax1, ev.time, style, 'Color', colors(i,:), 'LineWidth', 2);
                end
            end
            % remove this section to remove the answers (lines 60-68)
            dayStruct = allParticipant(traceIdx).Expert_Review.Day_2;
            events = {'Onset','P1','N1','P2','N2'};
            for e = 1:numel(events)
                ev = dayStruct.(events{e});
                if strcmpi(ev.Response,'Yes')
                    %xline(ax1, ev.time, style, 'Color', colors(i,:), 'LineWidth', 2);
                    plot(ev.time, ev.amp, 'bo', 'MarkerSize',7, 'LineWidth', 2, 'Color', 'b');
                end
            end

        end
        title(ax1, sprintf('%d: %s (ERP)', traceIdx, trialNum), 'Interpreter', 'none');
        xlim(ax1, [-10 100]);
        set(ax1,'YDir','reverse');  % invert y-axis (negative up)
        hold(ax1,'off');

        % Legend on ERP first row only
        if r == 1
            axes(ax1); hold(ax1,'on');
            hRev = gobjects(nReviewers,1);
            revLabels = cell(nReviewers,1);
            for i = 1:nReviewers
                revLabels{i} = sprintf('Reviewer %d', sscanf(revFields{i}, 'Reviewer_%d'));
                hRev(i) = plot(ax1, NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 2);
            end
            hStyle = gobjects(2,1);
            hStyle(1) = plot(ax1, NaN, NaN, '-', 'Color','k','LineWidth',2);
            hStyle(2) = plot(ax1, NaN, NaN, ':', 'Color','k','LineWidth',2);
            hStyle(3) = plot(ax1, NaN, NaN, 'o', 'Color','b','LineWidth',2);
            styleLabels = {'Solid = Confidence ≥ 0.5'; 'Dotted = Confidence < 0.5'; 'Marker = Expert Revier Answer'};
            legend(ax1, [hRev; hStyle], [revLabels; styleLabels], 'Location', 'best');
            hold(ax1,'off');
        end

        % --- Full column (col 2)
        ax2 = nexttile;
        hold(ax2,'on');
        plot(ax2, tVec(mask), yVec(mask), 'k');
        for i = 1:nReviewers
            revName   = revFields{i};
            revStruct = allParticipant(traceIdx).(revName);
            revNum    = sscanf(revName, 'Reviewer_%d');
            % Map Day for Full: reviewers 1-2 -> Day_2, others -> Day_1
            if revNum <= 2
                dayField = 'Day_2';
            else
                dayField = 'Day_1';
            end
            if ~isfield(revStruct, dayField), continue; end
            dayStruct = revStruct.(dayField);
            for e = 1:numel(events)
                ev = dayStruct.(events{e});
                if strcmpi(ev.Response,'Yes')
                    conf = round(ev.Confidence,2);
                    if conf < 0.5, style = ':'; else style = '-'; end
                    xline(ax2, ev.time, style, 'Color', colors(i,:), 'LineWidth', 2);
                end
            end
            % remove this section to remove the answers (lines 118-126)
            dayStruct = allParticipant(traceIdx).Expert_Review.Day_2;
            events = {'Onset','P1','N1','P2','N2'};
            for e = 1:numel(events)
                ev = dayStruct.(events{e});
                if strcmpi(ev.Response,'Yes')
                    %xline(ax1, ev.time, style, 'Color', colors(i,:), 'LineWidth', 2);
                    plot(ev.time, ev.amp, 'bo', 'MarkerSize',7, 'LineWidth', 2, 'Color', 'b');
                end
            end

        end
        title(ax2, sprintf('%d: %s (Full)', traceIdx, trialNum), 'Interpreter', 'none');
        xlim(ax2, [-10 100]);
        set(ax2,'YDir','reverse');  % invert y-axis (negative up)
        hold(ax2,'off');

        % Legend on Full first row only
        if r == 1
            axes(ax2); hold(ax2,'on');
            hRevF = gobjects(nReviewers,1);
            revLabelsF = cell(nReviewers,1);
            for i = 1:nReviewers
                revLabelsF{i} = sprintf('Reviewer %d', sscanf(revFields{i}, 'Reviewer_%d'));
                hRevF(i) = plot(ax2, NaN, NaN, '-', 'Color', colors(i,:), 'LineWidth', 2);
            end
            hStyleF = gobjects(2,1);
            hStyleF(1) = plot(ax2, NaN, NaN, '-', 'Color','k','LineWidth',2);
            hStyleF(2) = plot(ax2, NaN, NaN, ':', 'Color','k','LineWidth',2);
            hStyleF(3) = plot(ax2, NaN, NaN, 'o', 'Color','b','LineWidth',2);
            styleLabelsF = {'Solid = Confidence ≥ 0.5'; 'Dotted = Confidence < 0.5'; 'Marker = Expert Revier Answer'};
            legend(ax2, [hRevF; hStyleF], [revLabelsF; styleLabelsF], 'Location', 'best');
            hold(ax2,'off');
        end
    end

    % 5) Super-title
    sgtitle(sprintf('Comparing SEP (ERP vs Full responses): Trials %d–%d', startIdx, endIdx));
end

% Helper inline ternary
% function out = ternary(cond, a, b)
%     if cond, out = a; else out = b; end
% end
