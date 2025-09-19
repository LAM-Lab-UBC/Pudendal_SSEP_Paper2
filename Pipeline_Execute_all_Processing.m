%% Header
% MRPM 2025/08/12
% Author: Stephanie Wilkinson
% Project: MRPM SEP Paper 2 
% File: Pipeline_Execute_all_Processing.m

%% Code Description
% Processing
% runs time domain averaging, global field power and time frequency
% processing on all data based on if user says to processes the trial and
% if it meets requirment its xPT is between 2 and 3

% Analyzing
% asks user if there is a response
% autodetects the spot od max power for ITPC and PLP, asks user if they
% want to correct it
% asks user there is each even and tries to auto locate it if not can use
% manual selection 
%% Inputs
% if selected to process new data or process data

%% Outputs
% .mats for each trial in a folder selected by the user

%% Script
addpath("Functions Pipeline");
ProcessingTask = ["Process new data" "Analyze data"];
msgProcessingTask = "What task would you like to do";
ProcessingTaskChoice = menu(msgProcessingTask, ProcessingTask); % Prompt user selection
ProcessingTask_elect = ProcessingTask(ProcessingTaskChoice);    % Assign selection

if strcmp(ProcessingTask_elect, "Process new data")

    % Select folders
    data_folder = uigetdir('Select Folder with Raw Data');
    processed_folder = uigetdir('Select Folder with Processed Data');

    % Get list of subdirectories (participants)
    participant_folders_data = dir(data_folder);
    participant_folders_data = participant_folders_data(3:end); % Remove '.' and '..'

    % Launch EEGLAB
    [ALLEEG, EEG, CURRENTSET] = eeglab;

    % Loop through each participant
    for p = 1:length(participant_folders_data)
        participant_folder = participant_folders_data(p).name;
        participant_path = fullfile(data_folder, participant_folder);
        participant = participant_folder;

        % Path to participant's processed folder
        Par_folder = fullfile(processed_folder, participant_folder);

        % Skip if participant already processed
        if exist(Par_folder, 'dir')
            fprintf('Skipping %s — already processed.\n', participant_folder);
            continue;
        end

        % Get list of EEG recording files (.vhdr)
        file_list = dir(fullfile(participant_path, '*.vhdr'));
        if isempty(file_list)
            fprintf('No EEG files found for %s, skipping.\n', participant_folder);
            continue;
        end

        %Get info about teh participant
        % Ask participant info ONCE before looping over trials
        Sex = ["Female" "Male"];
        msgSex = sprintf("Select the Sex of Participant %s", participant);
        sexChoice = menu(msgSex, Sex);
        Sex_elect = Sex(sexChoice);

        Height_input = inputdlg('Enter height (cm):', sprintf('Participant %s', participant), [1 50]);
        height = Height_input{1};

        if strcmp(Sex_elect, 'Male')
            Circ_opt = ["Yes" "No"];
            msgCirc = sprintf('Is %s circumcised?', participant);
            circChoice = menu(msgCirc, Circ_opt);
            Circ_elect = Circ_opt(circChoice);
        else
            Circ_elect = "No";
        end

        % Now loop through all trial files
        for i = 1:length(file_list)
            file_path = fullfile(participant_path, file_list(i).name);
            fname = file_list(i).name(1:end-5);  % remove '.vhdr'

            SkipTrialOpt = ["Skip Trial" "Process data"];
            msgSkipTrial = append("Whould you like to process trial ", fname);
            SkipTrialChoice = menu(msgSkipTrial, SkipTrialOpt); % Prompt user selection
            SkipTrial_elect = SkipTrialOpt(SkipTrialChoice);    % Assign selection

            if strcmp(SkipTrial_elect, "Skip Trial")
                continue
            end
            Participant = []; 
            %get info about the trial conditions
            PT = inputdlg('Enter PT:', sprintf('Trial Number %s', fname), [1 50]);
            xPT_str = inputdlg('Enter xPT:', sprintf('Trial Number %s', fname), [1 50]);
            xPT = str2double(xPT_str{1});
           
            Participant.Participant_Info.Name = participant;
            Participant.Participant_Info.Sex = Sex_elect;
            Participant.Participant_Info.Circumsize = Circ_elect;
            Participant.Participant_Info.Height = height;
            Participant.Participant_Info.Trial_Num = fname;
            Participant.Trial.PT = PT;
            Participant.Trial.xPT = xPT;
            % Continue only if valid trial and PT between 2 and 3
            if xPT >= 2 && xPT <= 3

                % Load EEG data
                EEG = pop_loadbv(participant_path, file_list(i).name);
                [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0, ...
                    'setname', fname, 'gui', 'off');
                EEG.filepath = participant_path;

                %% Filtering
                order = 2;
                lowcutoff = 1;
                highcutoff = 100;
                Fs = 5000;

                [b1, a1] = butter(order, [59 61]/(Fs/2), 'stop');      % Notch filter (60 Hz)
                [b2, a2] = butter(order, [lowcutoff highcutoff]/(Fs/2), 'bandpass');

                [GFP_t, GFP_a, Cz_tr, GFP_data] = calc_gfp_Plot(EEG, b1, a1, b2, a2);
                data2filter = double(EEG.data(23, :));
                data_filt1 = filtfilt(b1, a1, data2filter);
                data_filt2 = filtfilt(b2, a2, data_filt1);
                EEG.data(23, :) = single(data_filt2);

                %% Epoching and Baseline Correction
                EEG = pop_epoch(EEG, {'S 15'}, [-0.05 0.25], ...
                    'newname', fname, 'epochinfo', 'yes');
                [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui', 'off');
                EEG = pop_rmbase(EEG, [-50 0], []);
                [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'gui', 'off');

                %% Cz Averaging
                trial_length = min(600, size(EEG.data, 3));
                Cz = squeeze(EEG.data(23, :, 1:trial_length));
                CzAvg = mean(Cz, 2);
                times = EEG.times;

                %% Time-Frequency Analysis
                x = EEG.times;
                time_l = EEG.xmin;
                time_h = EEG.xmax;
                freq_lims = [1 100];

                i_low = 1;
                i_high = 751;

                Cz = squeeze(EEG.data(23, :, 1:trial_length));
                erp = mean(Cz, 2, "omitnan");
                induced_EEG = Cz - repmat(erp, 1, size(Cz, 2));

                [erp_wt, frex, erp_scalingcfs] = cwt(erp, 'amor', EEG.srate, ...
                    FrequencyLimits = freq_lims);

                for t = 1:size(Cz, 2)
                    dat2convert = Cz(:, t);
                    if ~any(isnan(dat2convert))
                        [c_w, frex, sing_scalingcfs] = cwt(dat2convert, 'amor', ...
                            EEG.srate, FrequencyLimits = freq_lims);
                        sing_wt(:,:,t) = c_w(:, i_low:i_high);
                    else
                        sing_wt(:,:,t) = NaN;
                    end
                end

                sing_wt = sing_wt(:, i_low:i_high, :);

                cwt_outputs.erp.wt = erp_wt;
                cwt_outputs.erp.frex = frex;
                cwt_outputs.erp.scalingcfs = erp_scalingcfs;
                cwt_outputs.single_trial.wt = sing_wt;
                cwt_outputs.single_trial.frex = frex;
                cwt_outputs.single_trial.scalingcfs = sing_scalingcfs;

                x = x(i_low:i_high);
                [~, baseidx(1)] = min(abs(x + 50));
                [~, baseidx(2)] = min(abs(x + 10));

                erp_wt = erp_wt(:, i_low:i_high);
                pow_erp = abs(erp_wt).^2;
                pow_total = mean(abs(sing_wt).^2, 3, "omitnan");
                convol_pwr_ind = abs(sing_wt).^2;
                total_convol_result = mean(sing_wt, 3, "omitnan");
                pow_npl = pow_total - pow_erp;
                pow_plp = pow_total - pow_npl;
                ITPC = abs(mean(exp(1i * angle(sing_wt)), 3, "omitnan"));

                tf = zeros(5, size(pow_erp,1), size(pow_erp,2));
                tf(1,:,:) = pow_total;
                tf(2,:,:) = pow_npl;
                tf(3,:,:) = pow_erp;
                tf(4,:,:) = ITPC;
                tf(5,:,:) = pow_plp;
                tf = 10*log10(tf ./ mean(tf(:,:,baseidx(1):baseidx(2)),3,"omitnan"));
                tf(4,:,:) = ITPC;
                tf(3,:,:) = pow_erp;
                tf(5,:,:) = pow_plp;

                current_data.data = Cz;
                current_data.time = EEG.times;
                current_data.frequencies = frex;
                current_data.tf_times = x;
                current_data.tf = tf;
                current_data.cwt_outputs = cwt_outputs;
                current_data.tf_variables = ["Total","Non-phase-locked","ERP","ITPC","Phase locked"];

                Participant.Trial.CzAvg = CzAvg;
                Participant.Trial.times = times;
                Participant.Trial.tf = tf;
                Participant.Trial.frequencies = frex;
                Participant.Trial.x = current_data.time;
                Participant.Trial.x_tf = current_data.tf_times;
                Participant.Trial.GFP_data = GFP_data;
            end

            % Define participant's processed folder
            Par_folder = fullfile(processed_folder, participant);

            % Create the folder if it doesn't exist
            if ~exist(Par_folder, 'dir')
                mkdir(Par_folder);
            end

            % Build the save path
            save_path = fullfile(Par_folder, [participant, '_', fname, '.mat']);

            % Save the Participant struct
            save(save_path, 'Participant');

            % Clear EEGLAB sets for next run
            ALLEEG = [];
            fprintf('Processed and saved %s\n', participant);
        end
    end

elseif strcmp(ProcessingTask_elect, "Analyze data")
    processed_folder = uigetdir('Select Processed Data Folder');

    % Get list of participant folders
    participant_folders = dir(processed_folder);
    participant_folders = participant_folders([participant_folders.isdir]);
    participant_folders = participant_folders(3:end); % remove . and ..

    for p = 1:length(participant_folders)
        participant_name = participant_folders(p).name;

        % Skip if folder already marked analyzed
        if contains(participant_name, 'ANALYZED', 'IgnoreCase', true)
            fprintf('Skipping folder %s (already analyzed)\n', participant_name);
            continue;
        end

        participant_path = fullfile(processed_folder, participant_name);

        % Get all .mat files
        files = dir(fullfile(participant_path, '*.mat'));

        for f = 1:length(files)
            file_name = files(f).name;

            % Skip if file already analyzed (optional safeguard)
            if contains(file_name, 'ANALYZED', 'IgnoreCase', true)
                fprintf('Skipping %s (already analyzed)\n', file_name);
                continue;
            end

            fprintf('Analyzing %s...\n', file_name);
            file_path = fullfile(participant_path, file_name);

            % Load data
            load(file_path, 'Participant');
            xPT = Participant.Trial.xPT;
            % Continue only if valid trial and PT between 2 and 3
            if xPT >= 2 && xPT <= 3

            CzAvg = Participant.Trial.CzAvg;
            x_tf = Participant.Trial.x_tf;
            x = Participant.Trial.times;
            tf = Participant.Trial.tf;
            times = Participant.Trial.times;
            frequencies = Participant.Trial.frequencies;
            GFP_data = Participant.Trial.GFP_data;
            GFP_times = times(201:750);

            min_vect = min(min(tf(:,:,:,:),[],2),[],3);
            max_vect = max(max(tf(:,:,:),[],2),[],3);
            c_vector = max([abs(min_vect),abs(max_vect)],[],2);
            min_vect = -c_vector;
            min_vect(4) = 0; % for ITPC
            max_vect= c_vector;
            cbar_labels = {'dB';'Power (dB)';'dB';'ITPC';'Power (dB)'};

            figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96])
            tmain = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

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
            hold on
            xlim([-10 100]);
            xlabel('Time (ms)')
            ylabel('Amplitude (µV)')
            set(ax4, 'Ydir','reverse', 'YColor', 'k')

            % check if there is an overall response
            peak = "Overall";
            [Response_elect] = Response_selection(peak);
            Participant.Analysis.Overall_Response = Response_elect;

            if strcmp(Response_elect, "No")
                Participant.Analysis.Onset.Response = Response_elect;
                Participant.Analysis.P1.Response = Response_elect;
                Participant.Analysis.N1.Response = Response_elect;
                Participant.Analysis.P2.Response = Response_elect;
                Participant.Analysis.N2.Response = Response_elect;
            elseif strcmp(Response_elect, "Yes")
                %% Determine TF metrics for overall response
                % automatic
                [Auto_Max_Power_PLP,Auto_Max_Frequency_PLP, Auto_Max_Time_PLP, ...
                    Auto_Max_Power_ITPC,Auto_Max_Frequency_ITPC, Auto_Max_Time_ITPC, h] = AutoCalcAllMaxMin_TF( ...
                    x_tf, frequencies,dat2plot_ITPC,CzAvg,times, ...
                    cbar_label_ITPC, color_edges_ITPC,dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_PhaseLocked);

                PLP_Max_Power = Auto_Max_Power_PLP;
                PLP_Max_Frequency = Auto_Max_Frequency_PLP;
                PLP_Max_Time = Auto_Max_Time_PLP;

                ITPC_Max_Power = Auto_Max_Power_ITPC;
                ITPC_Max_Frequency = Auto_Max_Frequency_ITPC;
                ITPC_Max_Time = Auto_Max_Time_ITPC;

                % Phase Locked Power Manually Find Max
                PLP_ManualMax = ["Yes" "No" "No Response"];
                PLP_msgManualMax = append("Would you like to correct max phase locked power"); %% add the specific trial
                PLP_ManualChoiceMax = menu(PLP_msgManualMax,PLP_ManualMax); %Prompt user selection
                PLP_Manual_electMax = PLP_ManualMax(PLP_ManualChoiceMax); %Assign selection
                PLP_Response = 'Yes';
                if strcmp(PLP_Manual_electMax,'Yes')
                    type = 'Phase Locked';
                    [Man_Max_Power,Man_Max_Frequency, Man_Max_Time] = Manu_calcMax_TF_v5( ...
                        x_tf, frequencies, dat2plot_PhaseLocked, CzAvg,times, ...
                        color_edges_PhaseLocked, color_edges_PhaseLocked, type);
                    PLP_Max_Power = Man_Max_Power;
                    PLP_Max_Frequency = Man_Max_Frequency;
                    PLP_Max_Time = Man_Max_Time;
                    PLP_Response = 'Yes';
                end
                if strcmp(PLP_Manual_electMax,'No Response')
                    PLP_Max_Power = PLP_Manual_electMax;
                    PLP_Max_Frequency = PLP_Manual_electMax;
                    PLP_Max_Time = PLP_Manual_electMax;
                    PLP_Response = 'No';
                end

                % ITPC Manually Find Max
                ITPC_ManualMax = ["Yes" "No" "No Response"];
                ITPC_msgManualMax = append("Would you like to correct max ITPC"); %% add the specific trial
                ITPC_ManualChoiceMax = menu(ITPC_msgManualMax,ITPC_ManualMax); %Prompt user selection
                ITPC_Manual_electMax = ITPC_ManualMax(ITPC_ManualChoiceMax); %Assign selection
                ITPC_Response = 'Yes';
                if strcmp(ITPC_Manual_electMax, 'Yes')
                    type = 'ITPC';
                    [Man_Max_Power,Man_Max_Frequency, Man_Max_Time] = Manu_calcMax_TF_v5( ...
                        x_tf, frequencies, dat2plot_ITPC,CzAvg, times,...
                        cbar_label_ITPC, color_edges_ITPC, type);
                    ITPC_Max_Power = Man_Max_Power;
                    ITPC_Max_Frequency = Man_Max_Frequency;
                    ITPC_Max_Time = Man_Max_Time;
                    ITPC_Response = 'Yes';
                end
                if strcmp(ITPC_Manual_electMax, 'No Response')
                    ITPC_Max_Power = ITPC_Manual_electMax;
                    ITPC_Max_Frequency = ITPC_Manual_electMax;
                    ITPC_Max_Time = ITPC_Manual_electMax;
                    ITPC_Response = 'No';
                end

                close(h)
                % Save data
                Participant.Analysis.PLP.Max_Power = PLP_Max_Power;
                Participant.Analysis.PLP.Max_Frequency = PLP_Max_Frequency;
                Participant.Analysis.PLP.Max_Time = PLP_Max_Time;

                Participant.Analysis.ITPC.Max_Power = ITPC_Max_Power;
                Participant.Analysis.ITPC.Max_Frequency = ITPC_Max_Frequency;
                Participant.Analysis.ITPC.Max_Time = ITPC_Max_Time;

                %% Determine Time domain metrics for response
                % Onset
                peak = "Onset";
                [Response_elect] = Response_selection(peak);
                Participant.Analysis.Onset.Response = Response_elect;
                if strcmp(Response_elect, "Yes")
                    % try to auto calc location
                    [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                        dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                        times, GFP_times, GFP_data, x_tf);

                    Participant.Analysis.Onset.amp = Peak_amp;
                    Participant.Analysis.Onset.time = Peak_time;
                    plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
                end

                %P1
                peak = "P1";
                [Response_elect] = Response_selection(peak);
                Participant.Analysis.P1.Response = Response_elect;
                if strcmp(Response_elect, "Yes")
                    [Peak_amp,Peak_time, n] = AutoCalcPeaks(CzAvg, times, peak, frequencies, dat2plot_ITPC,...
                        dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                        GFP_times, GFP_data, x_tf);
                    [AutoResponse_elect] = AutoResponse_selection(peak);
                    close(n)
                    if strcmp(AutoResponse_elect, "Yes")
                        [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                            dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                            times, GFP_times, GFP_data, x_tf);
                    end
                    Participant.Analysis.P1.amp = Peak_amp;
                    Participant.Analysis.P1.time = Peak_time;
                    plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
                end

                %N1
                peak = "N1";
                [Response_elect] = Response_selection(peak);
                Participant.Analysis.N1.Response = Response_elect;
                if strcmp(Response_elect, "Yes")
                    [Peak_amp,Peak_time, n] = AutoCalcPeaks(CzAvg, times, peak, frequencies, dat2plot_ITPC,...
                        dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                        GFP_times, GFP_data, x_tf);
                    [AutoResponse_elect] = AutoResponse_selection(peak);
                    close(n)
                    if strcmp(AutoResponse_elect, "Yes")
                        [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                            dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                            times, GFP_times, GFP_data, x_tf);
                    end
                    Participant.Analysis.N1.amp = Peak_amp;
                    Participant.Analysis.N1.time = Peak_time;
                    plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
                end

                %P2
                peak = "P2";
                [Response_elect] = Response_selection(peak);
                Participant.Analysis.P2.Response = Response_elect;
                if strcmp(Response_elect, "Yes")
                    [Peak_amp,Peak_time, n] = AutoCalcPeaks(CzAvg, times, peak, frequencies, dat2plot_ITPC,...
                        dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                        GFP_times, GFP_data, x_tf);
                    [AutoResponse_elect] = AutoResponse_selection(peak);
                    close(n)
                    if strcmp(AutoResponse_elect, "Yes")
                        [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                            dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                            times, GFP_times, GFP_data, x_tf);
                    end
                    Participant.Analysis.P2.amp = Peak_amp;
                    Participant.Analysis.P2.time = Peak_time;
                    plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
                end

                %N2
                peak = "N2";
                [Response_elect] = Response_selection(peak);
                Participant.Analysis.N2.Response = Response_elect;
                if strcmp(Response_elect, "Yes")
                    [Peak_amp,Peak_time, n] = AutoCalcPeaks(CzAvg, times, peak, frequencies, dat2plot_ITPC,...
                        dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                        GFP_times, GFP_data, x_tf);
                    [AutoResponse_elect] = AutoResponse_selection(peak);
                    close(n)
                    if strcmp(AutoResponse_elect, "Yes")
                        [Peak_time, Peak_amp] = calcConditionManuTimePlusV3(times, CzAvg, peak, frequencies, dat2plot_ITPC,...
                            dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
                            times, GFP_times, GFP_data, x_tf);
                    end
                    Participant.Analysis.N2.amp = Peak_amp;
                    Participant.Analysis.N2.time = Peak_time;
                end

                %% Peak to peak values
                % P1N1
                if strcmp(Participant.Analysis.N1.Response, "Yes") && strcmp(Participant.Analysis.P1.Response, "Yes") && isnumeric(Participant.Analysis.N1.amp) && isnumeric(Participant.Analysis.P1.amp)
                    Participant.Analysis.Peak2Peak.P1N1  = abs(Participant.Analysis.N1.amp - Participant.Analysis.P1.amp);
                end
                % N1P2
                if strcmp(Participant.Analysis.N1.Response, "Yes") && strcmp(Participant.Analysis.P2.Response, "Yes") && isnumeric(Participant.Analysis.N1.amp) && isnumeric(Participant.Analysis.P2.amp)
                    Participant.Analysis.Peak2Peak.N1P2  = abs(Participant.Analysis.N1.amp - Participant.Analysis.P2.amp);
                end
                %P2N2
                % P1N1
                if strcmp(Participant.Analysis.N2.Response, "Yes") && strcmp(Participant.Analysis.P2.Response, "Yes") && isnumeric(Participant.Analysis.N2.amp) && isnumeric(Participant.Analysis.P2.amp)
                    Participant.Analysis.Peak2Peak.P2N2  = abs(Participant.Analysis.N2.amp - Participant.Analysis.P2.amp);
                end
            end
            close all
            end 

            % Mark as analyzed by renaming the file
            [~, baseName, ext] = fileparts(file_path);
            new_file_path = fullfile(participant_path, [baseName '_ANALYZED' ext]);
            movefile(file_path, new_file_path);
            fprintf('Renamed to %s\n', new_file_path);
        end
        new_folder_name = [participant_name '_ANALYZED'];
        new_folder_path = fullfile(processed_folder, new_folder_name);
        movefile(participant_path, new_folder_path);
        fprintf('Renamed folder to %s\n', new_folder_name);
    end
end