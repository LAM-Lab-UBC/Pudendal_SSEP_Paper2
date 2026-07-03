[filename, inpath] = uigetfile({'*.mat', 'Impact file (*.mat)'}, ...
    'Select .mat workspace with all previously processed data', 'MultiSelect', 'off');
addpath(inpath);
inDat = load(filename);
temp_name = string(fieldnames(inDat));
inDat = inDat.(temp_name);
allParticipant = inDat;

% Select folder containing raw data for all participants
data_folder = uigetdir('Select Folder with Raw Data');

% Get list of subfolders (participant IDs)
participant_folders = dir(data_folder);
participant_folders = participant_folders(3:end); % Remove '.' and '..'
[ALLEEG EEG CURRENTSET] = eeglab;

for x = 1:length(allParticipant)
    participant_name = string(allParticipant(x).Participant_Info.Name);
    trial_number = string(allParticipant(x).Participant_Info.Trial_Num); % or use num2str

    participant_path = fullfile(data_folder, participant_name);

    % Check if folder exists
    if ~isfolder(participant_path)
        warning('Folder for participant %s not found. Skipping.', participant_name);
        continue;
    end

    % List all .vhdr files
    file_list = dir(fullfile(participant_path, '*.vhdr'));

    % Loop through files to match the trial number
    for f = 1:length(file_list)
        file_name_no_ext = file_list(f).name(1:end-5); % remove .vhdr
        if strcmp(file_name_no_ext, trial_number)
            % Load and process EEG
            file_path = fullfile(participant_path, file_list(f).name);
            EEG = pop_loadbv(participant_path, file_list(f).name);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'setname', file_name_no_ext, 'gui', 'off');
            EEG.filepath = participant_path;

            %% Filter data
            % Specify filter parameters
            order = 2;
            lowcutoff = 1;
            highcutoff = 100;
            Fs = 5000;

            % Design notch and bandpass filters
            [b1, a1] = butter(order, [59 61]/(Fs/2), 'stop'); % notch
            [b2, a2] = butter(order, [lowcutoff highcutoff]/(Fs/2), 'bandpass');

            % Apply filters
            data2filter = double(EEG.data(23, :));
            data_filt1 = filtfilt(b1, a1, data2filter);
            data_filt2 = filtfilt(b2, a2, data_filt1);
            EEG.data(23, :) = single(data_filt2);

            % Extract Epochs and Baseline Removal
            EEG = pop_epoch(EEG, {'S 15'}, [-0.05 0.25], 'newname', file_name_no_ext, 'epochinfo', 'yes');
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 1, 'gui', 'off');
            EEG = pop_rmbase(EEG, [-50 0], []);
            [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 2, 'gui', 'off');
            %name = append(participant_folder, '_', file_name_no_ext, '_', char(f));
            % save(name, 'EEG');
            % Get Averaged Cz Plot
            % Get the minimum of 600 or the actual length of the trial data
            trial_length = min(600, size(EEG.data, 3));
            %trial_length = size(EEG.data, 3);

            % Select the appropriate range of data
            Cz = squeeze(EEG.data(23,:,1:trial_length));
            % grab stims 50-550 from channel number 23
            CzAvg = mean(Cz,2);

            %allParticipant(New).data(New_data).times = EEG.times;
            times = EEG.times;

            % Step 1: Compute the ERP (average across trials)
            erp = CzAvg;  % [time x 1]

            % Step 2: Subtract ERP from each trial to get residuals (noise)
            residuals = Cz - erp;  % [time x trials]

            % Step 3: Compute RMS of the ERP (signal)
            %rms_signal = sqrt(mean(erp.^2));  % scalar

            % Step 4: Compute RMS of the residuals (noise)
            % Option 1: Compute RMS per trial, then average
            rms_noise_trials = sqrt(mean(residuals.^2, 1));  % [1 x trials]
            %rms_noise = mean(rms_noise_trials);  % scalar
            rms_Sig_trials = sqrt(mean(Cz.^2, 1));  % [1 x trials]

            
            % Option 2 (simpler): Flatten all residuals and compute one RMS
            % rms_noise = sqrt(mean(residuals(:).^2));

            % Step 5: Compute SNR (linear and in dB)
            snr_linear = rms_Sig_trials / rms_noise_trials;
            snr_db = 10 * log10(snr_linear);

            allParticipant(x).Trial.snr_linear = snr_linear;
            allParticipant(x).Trial.snr_db = snr_db;

            % Display results
            fprintf('Processed trial %s for participant %s\n', trial_number, participant_name);
            fprintf('SNR (linear): %.2f\n', snr_linear);
            fprintf('SNR (dB): %.2f dB\n', snr_db);
            ALLEEG = [];

        end
    end
end

LinearSNR = [];
dBSNR = [];
max_dBSNR = -100000;
max_LinearSNR = -100000;

min_dBSNR = 100000;
min_LinearSNR = 100000;
for i = 1:length(allParticipant)
    LinearSNR = [LinearSNR;allParticipant(i).Trial.snr_linear];
    dBSNR = [dBSNR;allParticipant(i).Trial.snr_db];

    max_dBSNR = max(max_dBSNR, allParticipant(i).Trial.snr_db);
    max_LinearSNR = max(max_LinearSNR, allParticipant(i).Trial.snr_linear);

    min_dBSNR = min(min_dBSNR, allParticipant(i).Trial.snr_db);
    min_LinearSNR = min(min_LinearSNR, allParticipant(i).Trial.snr_linear);
end 
av_LinearSNR = mean(LinearSNR)
av_dBSNR = mean(dBSNR)

std_LinearSNR = std(LinearSNR)
std_dBSNR = std(dBSNR)