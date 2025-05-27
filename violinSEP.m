function T = violinSEP(allParticipant)
% violinSEP: Violin plot of reviewer confidence per event for ERP vs Full days.
%   allParticipant: 1×N struct array with fields Participant_Info, Trial, Reviewer_*
%   Returns T: long-form table of confidence ratings (same as scatterSEP).

    % Reuse scatterSEP to get the confidence table
    T = scatterSEP(allParticipant);

    % Unique events and day types
    events = {'Onset','P1','N1','P2','N2'};
    days   = {'ERP','Full'};

    % Create figure layout: 5 rows × 2 columns
    figure('units','normalized','outerposition',[0.01 0.04 0.98 0.96]);
    tiledlayout(numel(events),2,'TileSpacing','compact','Padding','compact');

    % Loop through events and day types
    for e = 1:numel(events)
        for d = 1:numel(days)
            ax = nexttile;
            hold(ax,'on');
            % Subset data
            mask = (T.Event == events{e}) & (T.DayType == days{d});
            data = T.Confidence(mask);
            grpString = T.Reviewer(mask);
            % Convert grouping to cell array of char for violinplot
            grp = cellstr(grpString);

            % Plot violin if available, otherwise boxchart
            if exist('violinplot','file') == 2
                % Grouped violin plot by reviewer
                violinplot(data, grp, 'Parent', ax);
                xlim(ax,[0.5, numel(unique(grp))+0.5]);
            else
                % Fallback: boxchart grouped by reviewer
                boxchart(ax, categorical(grp), data);
                
            end

            % Format axes
            
            ylim(ax,[0,1]);
            xticklabels(ax, unique(grp));
            set(gca, 'TickLabelInterpreter', 'none');
            xtickangle(ax,45);
            ylabel(ax,'Confidence');
            title(ax,sprintf('%s (%s)', events{e}, days{d}));
            hold(ax,'off');

        end
    end

    % Super-title
    sgtitle('Violin plots of confidence: ERP vs Full by event');
end