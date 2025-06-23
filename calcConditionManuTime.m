function [Peak_amp, Peak_time, Peak_time_times] = calcConditionManuTime(CzAvg, times, peak)
trial = CzAvg;

f1 = figure('units','normalized','outerposition',[0.3 0.2 0.5 0.40]);
plot(times, trial,'-r', 'LineWidth', 1.5)
set(gca, 'Ydir','reverse')
hold on

xlim([-10 100])
title(peak)

% [raw_Peak_time, y] = ginput(1);
% Peak_time_round = round(raw_Peak_time / 0.2) * 0.2;
% Peak_time = Peak_time_round;
% [~, Peak_time_times(2)] = min(abs(times - Peak_time_round));
% Peak_time_times = Peak_time_times(2);
% Peak_amp = CzAvg(Peak_time_times);

[x, y] = pointSelection();
Peak_time = x;
Peak_time_times = x;
Peak_amp = y;

plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)



close(f1)
%h = drawrectangle('FaceAlpha', 0, 'Color', 'b');
% % rect_position = h.Position;
% % x_roi = times(times >= rect_position(1) & times <= rect_position(1) + rect_position(3));
% % trial100 = trial+100;
% % y_roi = trial100(times >= rect_position(1) & times <= rect_position(1) + rect_position(3));
% % if strcmp(peak, "P1") || strcmp(peak, "P2")
% %     [max_peak, max_index] = max(y_roi);
% % elseif strcmp(peak, "N1") || strcmp(peak, "N2") || strcmp(peak, "Onset")
% %     [max_peak, max_index] = min(y_roi);
% % end
% % Peak_time = x_roi(max_index);
% % Peak_amp = y_roi(max_index)-100;
