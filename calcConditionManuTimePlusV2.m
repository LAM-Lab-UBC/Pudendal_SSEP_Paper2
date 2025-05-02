function [Peak_time, Peak_amp] = calcConditionManuTimePlusV2(trace_x, trace_y, peak, frequencies, dat2plot_ITPC,...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, x_tf)
if strcmp(peak, "P1")
    idx = 451;
elseif strcmp(peak, "P2")
    idx = 576;
elseif strcmp(peak, "N1")
    idx = 501;
elseif strcmp(peak, "N2")
    idx = 626;
elseif strcmp(peak, "Onset")
    idx = 401;
end


f1 = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

% "Phase locked"
ax1 =  nexttile;
contourf(x_tf, frequencies, dat2plot_PhaseLocked,40,'linecolor', 'none')
axes(ax1)
yl1 = ylim(ax1);
vline1 = line([trace_x(idx) trace_x(idx)], yl1, 'Color', 'k', 'LineStyle', '--');
ylabel('Frequency')
xlabel('Time (ms)')
title("Phase locked")
set(ax1, 'clim', color_edges_PhaseLocked);
c2 = colorbar;
colormap("jet");
xlim([-10 100]);
c2.Label.String = string(cbar_label_PhaseLocked);

% "ITPC"
ax2 =  nexttile;
contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
axes(ax2)
yl2 = ylim(ax2);
vline2 = line([trace_x(idx) trace_x(idx)], yl2, 'Color', 'k', 'LineStyle', '--');
ylabel('Frequency')
xlabel('Time (ms)')
title("ITPC")
set(ax2, 'clim', color_edges_ITPC);
c4 = colorbar;
xlim([-10 100]);
colormap("jet");
c4.Label.String = string(cbar_label_ITPC)';

% Global Field Potential
ax3 = nexttile;
plot(GFP_times, GFP_data,'-k', 'LineWidth', 1.5)
axes(ax3)

title("Global Field Power")
Y_max = max(GFP_data(101:end))*1.25;

xlim([-10 100]);
ylim([0 Y_max]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
yl3 = ylim(ax3);
vline3 = line([trace_x(idx) trace_x(idx)], yl3, 'Color', 'k', 'LineStyle', '--');
%
% % Time domain average
ax4 = nexttile;
%CzAvg_limits = CzAvg(201:751);
plot(trace_x, trace_y,'-r', 'LineWidth', 1.5)
title("Average")
xlim([-10 100]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
set(ax4, 'Ydir','reverse', 'YColor', 'k')
Y_max = max(trace_y(201:751))*1.25;
Y_min = min(trace_y(201:751))*1.25;
ylim([Y_min Y_max])
axes(ax4)
yl4 = ylim(ax4);
set(v_line, 'YData', yl4);
n_points = length(trace_x);
cursor = plot(trace_x(idx), trace_y(idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
% y_limits = ylim;
% x_limits = xlim;
% v_line = plot([trace_x(idx) trace_x(idx)], y_limits, 'k');
% h_line = plot(x_limits, [trace_y(idx) trace_y(idx)], 'k');
selected_points = [];

% Set up the figure keypress function
set(gcf, 'KeyPressFcn', @key_press_callback);

uiwait; % Wait until UI resumes (after escape key)


% Output variables
if ~isempty(selected_points)
    Peak_time = selected_points(:,1);
    Peak_amp = selected_points(:,2);
else
    Peak_time = [];
    Peak_amp = [];
end

    function key_press_callback(~, event)
        switch event.Key
            case 'rightarrow'
                if idx < n_points
                    idx = idx + 1;
                end
            case 'leftarrow'
                if idx > 1
                    idx = idx - 1;
                end
            case 'return'
                selected_points(end+1, :) = [trace_x(idx), trace_y(idx)];
                fprintf('Point selected: (%.4f, %.4f)\n', trace_x(idx), trace_y(idx));
            case 'escape'
                uiresume;
                return;
        end
        % Update cursor position
        % Update cursor and horizontal line (only in ax4)
        set(cursor, 'XData', trace_x(idx), 'YData', trace_y(idx));
        set(h_line, 'XData', x_limits, 'YData', [trace_y(idx) trace_y(idx)]);

        % Update vertical lines in all axes
        set(vline1, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax1));
        set(vline2, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax2));
        set(vline3, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax3));
        set(v_line, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax4));
    end
close(f1)
end