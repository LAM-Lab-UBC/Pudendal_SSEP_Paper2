% Extract SNR values
linear_snr = zeros(length(allParticipant), 1);
db_snr = zeros(length(allParticipant), 1);

for i = 1:length(allParticipant)
    linear_snr(i) = allParticipant(i).Trial.snr_linear;
    db_snr(i) = allParticipant(i).Trial.snr_db;
end

% Summary stats
fprintf('Mean Linear SNR: %.4f\n', mean(linear_snr));
fprintf('SD Linear SNR:   %.4f\n', std(linear_snr));
fprintf('Mean dB SNR:     %.4f\n', mean(db_snr));
fprintf('SD dB SNR:       %.4f\n', std(db_snr));