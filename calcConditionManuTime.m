function [Peak_amp, Peak_time] = calcConditionManuTime(CzAvg, times, peak)
trial = CzAvg;

f1 = figure;
plot(times, trial,'-r', 'LineWidth', 1.5)
set(gca, 'Ydir','reverse')
hold on

xlim([-10 100])
title(peak)
h = drawrectangle('FaceAlpha', 0, 'Color', 'b');
rect_position = h.Position;
x_roi = times(times >= rect_position(1) & times <= rect_position(1) + rect_position(3));
trial100 = trial+100;
y_roi = trial100(times >= rect_position(1) & times <= rect_position(1) + rect_position(3));
if strcmp(peak, "P1") || strcmp(peak, "P2")
    [max_peak, max_index] = max(y_roi);
elseif strcmp(peak, "N1") || strcmp(peak, "N2") || strcmp(peak, "Onset")
    [max_peak, max_index] = min(y_roi);
end
Peak_time = x_roi(max_index);
Peak_amp = y_roi(max_index)-100;
close(f1)

f2 = figure;
plot(times, trial,'-r', 'LineWidth', 1.5)
set(gca, 'Ydir','reverse')
hold on
xlim([-10 100])
plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
hold off

close(f2)