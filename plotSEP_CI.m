function outlierData = plotSEP_CI(allParticipant, method, showN, showOutliers)
% plotSEP_CI(allParticipant, method, showN, showOutliers)
% -------------------------------------------------------------------------
% DESCRIPTION:
%   Plots SEP traces (CzAvg vs. time) for multiple trials and overlays event
%   markers (Onset, P1, N1, P2, N2) with their central tendency (mean or median),
%   95% confidence intervals, optional sample-size annotations, and optional outlier
%   markers. Generates 12 figures covering trials 1–60 in groups of 5 (5 rows × 2 cols):
%     • Left column: ERP session
%     • Right column: Full session
%
%   **DISCLAIMER**: Before using this function, ensure that allReviewer Day_1/Day_2
%   fields in `allParticipant` have been renamed to 'ERP' and 'Full' (e.g., using
%   the provided renaming script). USE RemappingDays.m
%
% USAGE:
%   % Simple usage with mean, no n labels or outliers
%   plotSEP_CI(allParticipant, 'mean', false, false);
%
%   % Mean with sample-size labels
%   plotSEP_CI(allParticipant, 'mean', true, false);
%
%   % Mean with sample-size labels and outlier plotting
%   outData = plotSEP_CI(allParticipant, 'mean', true, true);
%
% INPUTS:
%   allParticipant  – 1×N struct array of trials, each having:
%                      .Trial.times, .Trial.CzAvg, .Binned, and Reviewer_* subfields
%   method          – 'mean' or 'median': central tendency to compute
%   showN           – logical: if true, annotate each event marker with (n = #obs)
%   showOutliers    – logical: if true, plot and return outliers outside 95% CI
%
% OUTPUTS:
%   outlierData     – struct array for each outlier set, with fields:
%                      .trial, .session, .event, .times, .y
%
% MAJOR STEPS:
%  1. Validate inputs and normalize `method`.
%  2. Loop over 12 figure blocks (5 trials each).
%  3. For each trial and session (ERP/Full):
%       a. Extract SEP trace (0–100 ms) and plot.
%       b. For each event: gather reviewer times, compute ct & 95% CI,
%          plot CI bar and central marker.
%       c. Optionally annotate (n = #) below marker.
%       d. Optionally identify and plot outliers, record in outlierData.
%  4. Add legend on the first subplot of each figure.
% -------------------------------------------------------------------------
    % Handle defaults
    if nargin < 3, showN = false;      else showN      = logical(showN);      end
    if nargin < 4, showOutliers = false; else showOutliers = logical(showOutliers); end
    method = lower(char(method));
    assert(any(strcmp(method,{'mean','median'})), ...
        'Method must be ''mean'' or ''median''.');

    events    = {'Onset','P1','N1','P2','N2'};
    colors    = lines(numel(events));
    lw_bar    = 3;    % CI bar stroke
    lw_mark   = 2.25; % marker stroke

    outlierData = struct('trial',{},'session',{},'event',{},'times',{},'y',{});

    for figIdx = 1:12
        trials = (figIdx-1)*5 + (1:5);
        figure('Name',sprintf('Trials %d–%d',trials(1),trials(end)), ...
               'Units','normalized','OuterPosition',[0 0 1 1]);
        tiledlayout(5,2,'TileSpacing','compact','Padding','compact');

        for row = 1:5
            tr     = trials(row);
            times  = allParticipant(tr).Trial.times;
            Cz     = allParticipant(tr).Trial.CzAvg;
            mask   = times >= 0 & times <= 100;
            t2     = times(mask);
            Cz2    = Cz(mask);
            binned = allParticipant(tr).Binned;

            revs = fieldnames(allParticipant(tr));
            revs = revs(startsWith(revs,'Reviewer_'));

            for col = 1:2
                sess = ternary(col==1,'ERP','Full');
                ax   = nexttile((row-1)*2 + col);
                plot(ax, t2, Cz2, 'k-','LineWidth',1); hold(ax,'on');
                title(ax,sprintf('Trial %d — %s — %s',tr,sess,binned));
                xlabel(ax,'Time (ms)'); ylabel(ax,'CzAvg');

                for e = 1:numel(events)
                    ev    = events{e};
                    tvals = [];
                    for r = 1:numel(revs)
                        R = allParticipant(tr).(revs{r});
                        if ~isfield(R,sess), continue; end
                        S = R.(sess);
                        if isfield(S,ev) && isstruct(S.(ev)) && isfield(S.(ev),'time') ...
                           && ~isempty(S.(ev).time) && isnumeric(S.(ev).time)
                            tvals(end+1) = S.(ev).time; %#ok<AGROW>
                        end
                    end
                    if isempty(tvals), continue; end

                    % Compute central tendency & 95% CI
                    switch method
                      case 'mean'
                        ct = mean(tvals);
                        se = std(tvals)/sqrt(numel(tvals));
                      case 'median'
                        ct = median(tvals);
                        se = 1.2533*std(tvals)/sqrt(numel(tvals));
                    end
                    ci   = 1.96 * se;
                    low  = ct - ci; high = ct + ci;

                    % Find y at ct
                    [~,idx_ct] = min(abs(t2 - ct));
                    y_ct       = Cz2(idx_ct);

                    % Plot CI bar & marker
                    plot(ax, [low high], [y_ct y_ct], '-', ...
                         'LineWidth', lw_bar, 'Color', colors(e,:));
                    plot(ax, ct,       y_ct,       'x', ...
                         'LineWidth', lw_mark, 'MarkerSize',8, ...
                         'Color', colors(e,:));

                    % Annotate sample size
                    if showN
                        yl   = ylim(ax);
                        yoff = (yl(2)-yl(1))*0.02;
                        text(ax, ct, y_ct - yoff, ...
                             sprintf('(n = %d)',numel(tvals)), ...
                             'HorizontalAlignment','center', ...
                             'VerticalAlignment','top', ...
                             'FontSize',8);
                    end

                    % Outlier handling
                    if showOutliers
                        isOut = (tvals < low) | (tvals > high);
                        outs  = tvals(isOut);
                        if ~isempty(outs)
                            y_out = zeros(size(outs));
                            for k = 1:numel(outs)
                                [~,idx_o] = min(abs(t2 - outs(k)));
                                y_out(k)  = Cz2(idx_o);
                            end
                            plot(ax, outs, y_out, 'o', ...
                                 'MarkerEdgeColor', colors(e,:), ...
                                 'MarkerFaceColor', colors(e,:), ...
                                 'MarkerSize', 4);

                            outlierData(end+1) = struct( ...
                                'trial',   tr,     ...
                                'session', sess,   ...
                                'event',   ev,     ...
                                'times',   outs,   ...
                                'y',       y_out);
                        end
                    end
                end

                % Legend on first subplot only
                if row==1 && col==1
                    h = gobjects(numel(events),1);
                    for e = 1:numel(events)
                        h(e) = plot(ax, NaN,NaN,'x', ...
                                    'LineWidth',lw_mark,'Color',colors(e,:));
                    end
                    legend(ax, h, events, 'Location','best');
                end

                hold(ax,'off');
            end
        end
    end
end

function out = ternary(cond,a,b)
    if cond, out = a; else out = b; end
end
