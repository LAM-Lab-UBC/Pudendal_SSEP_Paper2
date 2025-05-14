%% Header
% MRPM 2025/04/29
% Author: Winston Brandt
% Project: MRPM SEP
% File: view_data.m

%% File Description
% For paper 2 in the MRPM SSEP project
% 

%% Inputs
% .mat with the allParticipant data

%% Script
% %% Load data
% % Select the workspace that has all previously processed data

% [filename, inpath] = uigetfile({'*.mat', 'Impact file (*.mat)'}, ...
%     'Select .mat workspace with all previously processed data', 'MultiSelect', 'off');
% addpath(inpath);
% inDat = load(filename);
% temp_name = string(fieldnames(inDat));
% inDat = inDat.(temp_name);
% allParticipant = inDat;

% Note if everyone is working on the same computer we can just set this as
% a specific path so people do not have to load in the data
% Also make sure it is store locally on whatever computure you are using
%%
function plot_my_SEP(allParticipant, dayType)
    dayType = char(dayType);

    % 1) Dynamic reviewer fields
    fn = fieldnames(allParticipant);
    revFields = fn(startsWith(fn, "Reviewer_"));
    nReviewers = numel(revFields);

    % 2) Colors
    colors = lines(nReviewers);

    % 3) Menu for blocks of 10
    options = {"1-10","11-20","21-30","31-40","41-50","51-60"};
    choice = menu("Select traces to plot", options);
    if choice<1 || choice>numel(options), return; end
    startIdx = (choice-1)*10 + 1;
    endIdx   =  choice   *10;

    % 4) Figure layout
    figure;
    tiledlayout(2,5,"TileSpacing","compact","Padding","compact");

    % 5) Loop over traces
    for traceIdx = startIdx:endIdx
        ax = nexttile; hold(ax,"on");

        % Plot CzAvg vs time subset
        tVec = allParticipant(traceIdx).Trial.times;
        yVec = allParticipant(traceIdx).Trial.CzAvg;
        mask = (tVec>=-10)&(tVec<=100);
        plot(ax, tVec(mask), yVec(mask), "k");

        % 6) Overlay reviewer lines
        for r = 1:nReviewers
            revName   = revFields{r};
            revStruct = allParticipant(traceIdx).(revName);
            revNum    = sscanf(revName, "Reviewer_%d");

            % Map Day_1/Day_2 to ERP/Full
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

            events = {"Onset","P1","N1","P2","N2"};
            for e = 1:numel(events)
                ev = dayStruct.(events{e});
                if strcmpi(ev.Response,"Yes")
                    conf = round(ev.Confidence,2);
                    if conf < 0.5
                        style = ':'; 
                    else
                        style = '-'; 
                    end
                    xline(ax, ev.time, style, "Color", colors(r,:), "LineWidth", 1);
                end
            end
        end

        % 7) Title & limits
        tit = allParticipant(traceIdx).Participant_Info.Trial_Num;
        title(ax, sprintf("%d: %s", traceIdx, tit));
        xlim(ax, [-10 100]);
        hold(ax,"off");

        % 8) Legend on first tile only
        if traceIdx==startIdx
            % Reviewer‐color keys
            hRev = gobjects(nReviewers,1);
            revLabels = cell(nReviewers,1);
            for r = 1:nReviewers
                revNum = sscanf(revFields{r}, "Reviewer_%d");
                revLabels{r} = sprintf("Reviewer %d", revNum);
                hRev(r) = plot(ax, NaN, NaN, "-", ...
                               "Color", colors(r,:), "LineWidth", 1.5);
            end

            % Style keys
            hStyle(1) = plot(ax, NaN, NaN, "-", "Color", "k", "LineWidth", 1.5);
            hStyle(2) = plot(ax, NaN, NaN, ":", "Color", "k", "LineWidth", 1.5);
            styleLabels = { "Solid = Confidence ≥ 0.5"
                            "Dotted = Confidence < 0.5" };
            hStyle = hStyle(:);

            % Combine and draw legend
            allH      = [hRev; hStyle];
            allLabels = [revLabels; styleLabels];
            legend(ax, allH, allLabels, "Location", "best");
        end
    end

    % 9) Super-title
    sgtitle(sprintf("SEP traces (%s days): Trials %d–%d", ...
           dayType, startIdx, endIdx));
end

function out = ternary(c,a,b)
    if c, out = a; else out = b; end
end


%%

% To view ERP days:
plot_my_SEP(allParticipant, "ERP");
