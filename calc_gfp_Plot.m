function [GFP_t, GFP_a, Cz_tr, GFP_data] = calc_gfp_Plot(rawEEG, b1, a1, b2, a2)
% Calculates Global Field Power (GFP) and related measures from raw EEG data.
% Inputs:
%   rawEEG - raw EEG data structure
%   b1, a1 - notch filter coefficients
%   b2, a2 - bandpass filter coefficients
% Outputs:
%   GFP_t    - times of GFP peaks
%   GFP_a    - amplitudes of GFP peaks
%   Cz_tr    - Cz electrode ERP trace in GFP window
%   GFP_data - full GFP time series in the analysis window

% Sampling frequency
Fs = 5000;

% Filter and analysis parameters
notchBand   = [59 61];     % Notch filter range (Hz)
lowEdge     = 1000;         % Low-pass cutoff (Hz)
n_epochs    = 600;         % Max number of epochs to use
base_ms     = [-50 0];     % Baseline window (ms)
minPromFrac = 0.25;        % Min peak prominence (fraction of max)
minDist_ms  = 5;           % Min distance between peaks (ms)
window      = [-10 100];   % Time window to analyze for GFP (ms)

% Save original channel labels for later interpolation
origLabs = {rawEEG.chanlocs.labels};

%% Step 1: Artifact removal with high-pass filter (0.5–1 Hz)
EEG = clean_artifacts(rawEEG, 'Highpass', [0.5 1]);

%% Step 2: Interpolate removed channels
newLabs = {EEG.chanlocs.labels};
badLabs = setdiff(origLabs, newLabs); % Channels removed by cleaning
if ~isempty(badLabs)
    badIdx = find(ismember(origLabs, badLabs));
    EEG = eeg_interp(EEG, rawEEG.chanlocs(badIdx), 'spherical'); % Spherical interpolation
end

%% Step 3: Identify usable channels and Cz
labels = {EEG.chanlocs.labels};
recIdx = find(~cellfun(@isempty, labels) & ~strcmpi(labels, 'Fz')); % All channels except Fz
cz_idx = find(strcmpi(labels, 'Cz'), 1); % Index of Cz channel
if isempty(cz_idx)
    warning('Cz missing after cleaning in %s – skipped.', file_list(f).name);
end

%% Step 4: Apply filters to all recording channels
for ch = recIdx
    sig = filtfilt(b1, a1, double(EEG.data(ch, :)));       % Apply notch filter
    EEG.data(ch, :) = single(filtfilt(b2, a2, sig));       % Apply bandpass filter
end

%% Step 5: Epoch data around stimulus "S 15" and remove baseline
EEG = pop_epoch(EEG, {'S 15'}, [-0.05 0.25], 'epochinfo', 'yes');
EEG = pop_rmbase(EEG, base_ms);
EEG = pop_selectevent(EEG, 'epoch', 1:min(n_epochs, EEG.trials)); % Limit to max epochs
if EEG.trials == 0
    warning('No epochs in %s – skipped.', file_list(f).name);
end

%% Step 6: Calculate ERP and GFP
erp = mean(EEG.data(recIdx, :, :), 3);                       % Average ERP across channels
wMask = EEG.times >= window(1) & EEG.times <= window(2);    % Time window mask
erpWin = erp(:, wMask);                                     % ERP in selected window
gfp = sqrt(mean((erpWin - mean(erpWin, 1)).^2, 1));         % GFP = SD across channels

%% Step 7: Detect peaks in GFP signal
[pks, locs] = findpeaks(gfp, ...
    'MinPeakProminence', minPromFrac * max(gfp), ...
    'MinPeakDistance', round(minDist_ms * Fs / 1000));
[~, ix] = maxk(pks, min(4, numel(pks)));                    % Get up to 4 largest peaks

% Output values
GFP_t = sort(EEG.times(wMask(locs(ix))));                   % GFP peak times
GFP_a = pks(ix);                                            % GFP peak amplitudes
Cz_tr = erpWin(cz_idx, :);                                  % Cz channel trace
GFP_data = gfp;                                             % Full GFP time series

end
