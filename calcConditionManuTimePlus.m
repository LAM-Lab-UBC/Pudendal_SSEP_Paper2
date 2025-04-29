function [Peak_amp, Peak_time] = calcConditionManuTimePlus(CzAvg, x_tf, peak, frequencies, dat2plot_ITPC,...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times)
trial = CzAvg;
f1 = figure;
t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

% "Phase locked"
ax1 =  nexttile;
contourf(x_tf, frequencies, dat2plot_PhaseLocked,40,'linecolor', 'none')
ylabel('Frequency')
xlabel('Time (ms)')
title("Phase locked")
set(ax1, 'clim', color_edges_PhaseLocked);
c2 = colorbar;
colormap("jet");
c2.Label.String = string(cbar_label_PhaseLocked);

% "ITPC"
ax2 =  nexttile;
contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
ylabel('Frequency')
xlabel('Time (ms)')
title("ITPC")
set(ax2, 'clim', color_edges_ITPC);
c4 = colorbar;
colormap("jet");
c4.Label.String = string(cbar_label_ITPC)';

ax4 = nexttile;
plot(times, CzAvg,'-r', 'LineWidth', 1.5)
title("Average")
xlim([-10 100]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
set(ax4, 'Ydir','reverse', 'YColor', 'k')

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