%% Header
% MRPM 2025/04/29
% Author: Stephanie Wilkinson
% Project: MRPM SEP
% File: execute_all_processing.m

%% File Description
% For paper 2 in the MRPM SSEP project
% asks users to review data in two different methods: once with just
% time-domain infromation and once with time-domain plus time-frequency and
% global field potential information

%% Inputs
% .mat with the pre-processed data

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
%% Enter information about Reviewer_metrics
% Select which Reviewer_it is
ReviewerOpt = ["Reviewer_1" "Reviewer_2" "Reviewer_3" "Reviewer_4"];
msgReviewer= append("Which Reviewer are you"); %% add the specific trial
ReviewerChoice = menu(msgReviewer,ReviewerOpt); %Prompt user selection
Reviewer_elect = ReviewerOpt(ReviewerChoice); %Assign selection

% Select which review session it is
SessionOpt = ["Day_1" "Day_2"];
msgSession = 'What reviewing session is this';
SessionChoice = menu(msgSession, SessionOpt);
Session_elect = SessionOpt(SessionChoice);


%% Start processing data
% Create random order for processing data
order_trials = randperm(length(allParticipant));
%% Time domain only
% Reviewer_1 & 2 day 1
% Reviewer_3 & 4 day 2
if strcmp(Reviewer_elect, "Reviewer_1") && strcmp(Session_elect, "Day_1") || strcmp(Reviewer_elect, "Reviewer_2") && strcmp(Session_elect, "Day_1") ...
        || strcmp(Reviewer_elect, "Reviewer_3") && strcmp(Session_elect, "Day_2") || strcmp(Reviewer_elect, "Reviewer_4") && strcmp(Session_elect, "Day_2")
    for i = 1:length(order_trials)
        current_index = order_trials(i);
        CzAvg = allParticipant(current_index).Trial.CzAvg;
        times = allParticipant(current_index).Trial.times;

        % Scheduled breaks
        if i == 20 || i == 40
            web('https://www.youtube.com/watch?v=9EcjWd-O4jI')
            pause(221)
            !taskkill -f -im msedge.exe
        end

        %Plot the response
        tic;
        figure('units','normalized','outerposition',[0.3 0.2 0.5 0.40])
        plot(times, CzAvg,'-r', 'LineWidth', 1.5)
        set(gca, 'Ydir','reverse')
        hold on
        xlim([-10 100])
        hold off

        % check if there is an overall response
        peak = "Overall";
        [Response_elect] = Response_selection(peak);
        Overall_response_time = toc;
        allParticipant(current_index).(Reviewer_elect).(Session_elect).Overall_Response = Response_elect;


        if strcmp(Response_elect, "No")

            [Confidence_val] = confidence_slider();
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Overall_Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Confidence = Confidence_val;

        elseif strcmp(Response_elect, "Yes")
            % Onset
            peak = "Onset";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Response = Response_elect;
            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimeV2(times,CzAvg, peak);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTime(peak,CzAvg, times, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_slider();
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Confidence = Confidence_val;

            %P1
            peak = "P1";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Response = Response_elect;
            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimeV2(times,CzAvg, peak);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTime(peak,CzAvg, times, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                [Confidence_val] = confidence_slider();
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.peak_response_time = peak_response_time;
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Confidence = Confidence_val;

            %N1
            peak = "N1";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Response = Response_elect;
            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimeV2(times,CzAvg, peak);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTime(peak,CzAvg, times, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                [Confidence_val] = confidence_slider();
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.peak_response_time = peak_response_time;
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Confidence = Confidence_val;

            %P2
            peak = "P2";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Response = Response_elect;
            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimeV2(times,CzAvg, peak);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTime(peak,CzAvg, times, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                [Confidence_val] = confidence_slider();
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.peak_response_time = peak_response_time;
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Confidence = Confidence_val;

            %N2
            peak = "N2";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Response = Response_elect;
            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimeV2(times,CzAvg, peak);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTime(peak,CzAvg, times, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                [Confidence_val] = confidence_slider();
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.peak_response_time = peak_response_time;
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Confidence = Confidence_val;

        end

        allParticipant(current_index).(Reviewer_elect).(Session_elect).response_time = Overall_response_time;
        allParticipant(current_index).(Reviewer_elect).(Session_elect).order = i;
        close all
    end
end


%% With time frequency and global field potential
% Reviewer_1 & 2 day 2
% Reviewer_3 & 4 day 1
if strcmp(Reviewer_elect, "Reviewer_1") && strcmp(Session_elect, "Day_2") || strcmp(Reviewer_elect, "Reviewer_2") && strcmp(Session_elect, "Day_2") ...
        || strcmp(Reviewer_elect, "Reviewer_3") && strcmp(Session_elect, "Day_1") || strcmp(Reviewer_elect, "Reviewer_4") && strcmp(Session_elect, "Day_1")
    for i = 1:length(order_trials)

        % Scheduled breaks
        if i == 20 || i == 40

            web('https://www.youtube.com/watch?v=9EcjWd-O4jI')
            pause(221)
            !taskkill -f -im msedge.exe
        end

        current_index = order_trials(i);
        CzAvg = allParticipant(current_index).Trial.CzAvg;
        x_tf = allParticipant(current_index).Trial.x_tf;
        x = allParticipant(current_index).Trial.times;
        tf = allParticipant(current_index).Trial.tf;
        times = allParticipant(current_index).Trial.times;
        frequencies = allParticipant(current_index).Trial.frequencies;
        GFP_data = allParticipant(current_index).Trial.GFP_data;
        GFP_times = times(201:750);

        min_vect = min(min(tf(:,:,:,:),[],2),[],3);
        max_vect = max(max(tf(:,:,:),[],2),[],3);
        c_vector = max([abs(min_vect),abs(max_vect)],[],2);
        min_vect = -c_vector;
        min_vect(4) = 0; % for ITP
        max_vect= c_vector;
        cbar_labels = {'dB';'Power (dB)';'dB';'ITPC';'Power (dB)'};

        tic;
        figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96])
        t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

        % "Phase locked"
        ax1 =  nexttile;
        dat2plot_PhaseLocked = squeeze(tf(5,:,:));
        cbar_label_PhaseLocked = cbar_labels(5);
        color_edges_PhaseLocked = [min_vect(5) max_vect(5)];
        contourf(x_tf, frequencies, dat2plot_PhaseLocked,40,'linecolor', 'none')
        ylabel('Frequency')
        xlabel('Time (ms)')
        title("Phase locked")
        xlim([-10 100]);
        set(ax1, 'clim', color_edges_PhaseLocked);
        c2 = colorbar;
        colormap("jet");
        c2.Label.String = string(cbar_label_PhaseLocked);

        % "ITPC"
        ax2 =  nexttile;
        dat2plot_ITPC = squeeze(tf(4,:,:));
        cbar_label_ITPC = cbar_labels(4);
        color_edges_ITPC = [min_vect(4) max_vect(4)];
        contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
        ylabel('Frequency')
        xlabel('Time (ms)')
        title("ITPC")
        xlim([-10 100]);
        set(ax2, 'clim', color_edges_ITPC);
        c4 = colorbar;
        colormap("jet");
        c4.Label.String = string(cbar_label_ITPC)';

        % Global Field Potential
        ax3 = nexttile;
        plot(GFP_times, GFP_data,'-k', 'LineWidth', 1.5)
        title("Global Field Potential")
        xlim([-10 100]);
        xlabel('Time (ms)')
        ylabel('Amplitude (µV)')

        % Time domain average
        ax4 = nexttile;
        %CzAvg_limits = CzAvg(201:751);
        plot(times, CzAvg,'-r', 'LineWidth', 1.5)
        title("Average")
        xlim([-10 100]);
        xlabel('Time (ms)')
        ylabel('Amplitude (µV)')
        set(ax4, 'Ydir','reverse', 'YColor', 'k')

        % check if there is an overall response
        peak = "Overall";
        [Response_elect] = Response_selection(peak);
        response_time = toc;
        allParticipant(current_index).(Reviewer_elect).(Session_elect).response_time = response_time;
        allParticipant(current_index).(Reviewer_elect).(Session_elect).Overall_Response = Response_elect;

        if strcmp(Response_elect, "No")
            [Confidence_val] = confidence_slider();
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Overall_Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Confidence = Confidence_val;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Response = Response_elect;
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Confidence = Confidence_val;

        elseif strcmp(Response_elect, "Yes")
            % Onset
            peak = "Onset";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Response = Response_elect;
            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                    times, GFP_times, GFP_data, x_tf);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTimePlus(CzAvg, x_tf, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_slider();
            end

            allParticipant(current_index).(Reviewer_elect).(Session_elect).Onset.Confidence = Confidence_val;

            %P1
            peak = "P1";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Response = Response_elect;

            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                    times, GFP_times, GFP_data, x_tf);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTimePlus(CzAvg, x_tf, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_slider();
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P1.Confidence = Confidence_val;

            %N1
            peak = "N1";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Response = Response_elect;

            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                    times, GFP_times, GFP_data, x_tf);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTimePlus(CzAvg, x_tf, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_slider();
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N1.Confidence = Confidence_val;

            %P2
            peak = "P2";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Response = Response_elect;

            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                    times, GFP_times, GFP_data, x_tf);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTimePlus(CzAvg, x_tf, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                [Confidence_val] = confidence_slider();
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.peak_response_time = peak_response_time;
            end

            allParticipant(current_index).(Reviewer_elect).(Session_elect).P2.Confidence = Confidence_val;

            %N2
            peak = "N2";
            tic;
            [Response_elect] = Response_selection(peak);
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Response = Response_elect;

            if strcmp(Response_elect, "Yes")
                [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                    times, GFP_times, GFP_data, x_tf);
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.amp = Peak_amp;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.time = Peak_time;
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_sliderTimePlus(CzAvg, x_tf, frequencies, dat2plot_ITPC,...
                    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, Peak_time, Peak_amp);
            elseif strcmp(Response_elect, "No")
                peak_response_time = toc;
                allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.peak_response_time = peak_response_time;
                [Confidence_val] = confidence_slider();
            end
            allParticipant(current_index).(Reviewer_elect).(Session_elect).N2.Confidence = Confidence_val;
        end

        allParticipant(current_index).(Reviewer_elect).(Session_elect).order = i;
        close all
    end

    % Select which tool was the most helpful in the reviewing process
    ToolOpt = ["Time-Frequency" "Global Field Potential" "Did not need either"];
    msgTool = 'What tool was the most helpful in classifying the SEP responses';
    ToolChoice = menu(msgTool, ToolOpt);
    Tool_elect = ToolOpt(ToolChoice);
    for k = 1:length(allParticipant)
        allParticipant(k).(Reviewer_elect).Tool = Tool_elect;
    end
end

