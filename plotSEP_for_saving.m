function plotSEP_save(allParticipant, reviewerChoice)
% plotSEP: Visualize ERP vs Full event selections and save each block as a full-screen JPEG.
%   allParticipant: 1×N struct array with fields Participant_Info, Trial, Reviewer_*
%   reviewerChoice: 'all' (default) or a single reviewer name (e.g. 'Reviewer_1')

    %% 0) Inputs & output folder selection
    if nargin < 2
        reviewerChoice = 'all';
    end
    reviewerChoice = char(reviewerChoice);

    outputFolder = uigetdir(pwd, 'Select folder to save figures');
    if isequal(outputFolder,0)
        warning('No folder selected – figures will NOT be saved.');
        saveFigures = false;
    else
        saveFigures = true;
    end

    %% 1) Find reviewers dynamically
    fn        = fieldnames(allParticipant);
    revFields = fn(startsWith(fn, 'Reviewer_'));

    % pick subset
    if strcmpi(reviewerChoice,'all')
        revList = revFields;
    else
        assert(any(strcmp(revFields, reviewerChoice)), ...
               "Reviewer '%s' not found.", reviewerChoice);
        revList = {reviewerChoice};
    end

    %% 2) Remap Day_1/Day_2 → ERP/Full (hard-coded for reviewers 1–2 vs 3+)
    for t = 1:numel(allParticipant)
      for r = 1:numel(revFields)
        revName   = revFields{r};
        revStruct = allParticipant(t).(revName);
        revNum    = sscanf(revName,'Reviewer_%d');
        if revNum <= 2
          if isfield(revStruct,'Day_1')
            revStruct.ERP  = revStruct.Day_1;  revStruct = rmfield(revStruct,'Day_1');
          end
          if isfield(revStruct,'Day_2')
            revStruct.Full = revStruct.Day_2;  revStruct = rmfield(revStruct,'Day_2');
          end
        else
          if isfield(revStruct,'Day_1')
            revStruct.Full = revStruct.Day_1;  revStruct = rmfield(revStruct,'Day_1');
          end
          if isfield(revStruct,'Day_2')
            revStruct.ERP  = revStruct.Day_2;  revStruct = rmfield(revStruct,'Day_2');
          end
        end
        allParticipant(t).(revName) = revStruct;
      end
    end

    %% 3) Trial-block menu (with 'All' option)
    blocks = {"1-10","11-20","21-30","31-40","41-50","51-60","All"};
    choice = menu("Select traces to plot", blocks);
    if choice < 1 || choice > numel(blocks)
        return;
    end

    if choice == numel(blocks)   % 'All' selected
        blockIndices = 1:(numel(blocks)-1);
    else
        blockIndices = choice;
    end

    %% 4) Define colors for ERP vs Full
    purple = [128,0,128]/255;
    orange = [255,165,0]/255;

    %% 5) Loop over each requested block
    for b = blockIndices
        startIdx = (b-1)*10 + 1;
        endIdx   =  b   *10;

        % create full-screen figure
        fig = figure('Units','normalized','OuterPosition',[0 0 1 1]);
        tiledlayout(5,2,'TileSpacing','compact','Padding','compact');
        axesHandles = gobjects(endIdx-startIdx+1,1);
        count = 0;

        % plot each trace
        for traceIdx = startIdx:endIdx
            count = count + 1;
            ax = nexttile; hold(ax,'on');
            axesHandles(count) = ax;

            % raw SEP trace
            tVec = allParticipant(traceIdx).Trial.times;
            yVec = allParticipant(traceIdx).Trial.CzAvg;
            idx  = (tVec>=-10)&(tVec<=100);
            plot(ax, tVec(idx), yVec(idx), 'k');

            % overlay ERP & Full
            for r = 1:numel(revList)
                revStruct = allParticipant(traceIdx).(revList{r});
                for day = ["ERP","Full"]
                    if ~isfield(revStruct, day), continue; end
                    dayStruct = revStruct.(day);
                    events = {'Onset','P1','N1','P2','N2'};
                    for e = 1:numel(events)
                        ev = dayStruct.(events{e});
                        if strcmpi(ev.Response,'Yes')
                            conf  = round(ev.Confidence,2);
                            style = ternary(conf<0.5,':','-');
                            col   = ternary(day=="ERP", purple, orange);
                            xline(ax, ev.time, style, 'Color', col, 'LineWidth', 2);
                        end
                    end
                end
            end

            % formatting
            trialNum = allParticipant(traceIdx).Participant_Info.Trial_Num;
            title(ax, sprintf("%d: %s", traceIdx, trialNum));
            xlim(ax, [-10 100]);
            set(ax,'YDir','reverse');
            hold(ax,'off');
        end

        % legend on first subplot
        ax0 = axesHandles(1);
        axes(ax0); hold(ax0,'on');
        hERP   = plot(NaN,NaN,'-','Color',purple,'LineWidth',2);
        hFull  = plot(NaN,NaN,'-','Color',orange,'LineWidth',2);
        hSolid = plot(NaN,NaN,'-','Color','k','LineWidth',2);
        hDot   = plot(NaN,NaN,':','Color','k','LineWidth',2);
        legend(ax0, [hERP,hFull,hSolid,hDot], ...
               {'ERP responses','Full responses', ...
                'Solid = Confidence ≥ 0.5','Dotted = Confidence < 0.5'}, ...
               'Location','best');
        hold(ax0,'off');

        sgtitle(sprintf("SEP traces: Trials %d–%d (purple=ERP, orange=Full)", ...
                 startIdx, endIdx));

        % save as JPEG if requested
        if saveFigures
            filename = sprintf('SEP_traces_%02d-%02d.jpg', startIdx, endIdx);
            % 300 dpi JPEG
            print(fig, fullfile(outputFolder, filename), '-djpeg', '-r300');
        end
    end
end

%% inline ternary helper
function out = ternary(cond, a, b)
    if cond, out = a; else out = b; end
end
