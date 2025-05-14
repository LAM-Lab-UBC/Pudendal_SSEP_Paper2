function kdeSEP(allParticipant)
% kdeSEP: Kernel density estimate of reviewer confidence per event for ERP vs Full days.
%   allParticipant: 1×N struct array with fields Participant_Info, Trial, Reviewer_*
%   Generates a 5×2 grid of KDE plots (events × [ERP, Full]) colored by reviewer.

    % Reuse scatterSEP to build the confidence table
    T = scatterSEP(allParticipant);

    % Define events and day types
    events = {'Onset','P1','N1','P2','N2'};
    days   = {'ERP','Full'};

    % Determine reviewer fields and colors
    fn = fieldnames(allParticipant);
    revFields = fn(startsWith(fn,'Reviewer_'));
    nReviewers = numel(revFields);
    try
        cmap = tab10;  % use tab10 if available
    catch
        cmap = lines(nReviewers);
    end
    if size(cmap,1) < nReviewers
        cmap = lines(nReviewers);
    end

    % Create figure and tiled layout (5 rows × 2 columns)
    figure;
    tiledlayout(numel(events),2,'TileSpacing','compact','Padding','compact');

    % Loop through each event and day type
    for e = 1:numel(events)
        for d = 1:numel(days)
            ax = nexttile;
            hold(ax,'on');
            mask = (T.Event == events{e}) & (T.DayType == days{d});

            % Plot KDE for each reviewer
            for r = 1:nReviewers
                revName = revFields{r};
                sel = mask & (T.Reviewer == revName);
                data = T.Confidence(sel);
                data = data(~isnan(data));
                if numel(data) < 2
                    continue;
                end
                [f, xi] = ksdensity(data);  % automatic support
                plot(ax, xi, f, 'LineWidth', 2, 'Color', cmap(r,:));
            end

            % Format axes
            hold(ax,'off');
            xlim(ax, [0 1]);
            xlabel(ax, 'Confidence');
            ylabel(ax, 'Density');
            title(ax, sprintf('%s (%s)', events{e}, days{d}));

            % Add legend on first subplot only
            if e == 1 && d == 1
                revLabels = cell(nReviewers,1);
                for r = 1:nReviewers
                    revLabels{r} = sprintf('Reviewer %d', sscanf(revFields{r}, 'Reviewer_%d'));
                end
                legend(ax, revLabels, 'Location', 'best');
            end
        end
    end

    sgtitle('KDE of Confidence: ERP vs Full by Event');
end
