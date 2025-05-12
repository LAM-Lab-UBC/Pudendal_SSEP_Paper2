function [Peak_time, Peak_amp] = calcConditionManuTimePlusV4(trace_x, trace_y, peak, frequencies, dat2plot_ITPC,...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
    times, GFP_times, GFP_data, x_tf)

% Select peak index
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

restart = true;
while restart
    restart = false;  % Reset flag

    try
        % Create figure and tiled layout
        f1 = figure('units','normalized','outerposition',[0.2 0.04 0.5 0.96]);
        t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");
        title(t, {peak,'Use arrow keys to move. Press Enter to select. Esc to quit.'});

        % --- Plot 1: Phase Locked ---
        ax1 = nexttile;
        contourf(x_tf, frequencies, dat2plot_PhaseLocked, 40, 'linecolor', 'none')
        ylabel('Frequency')
        xlabel('Time (ms)')
        title("Phase locked")
        set(ax1, 'clim', color_edges_PhaseLocked);
        c1 = colorbar;
        colormap("jet");
        xlim([-10 100]);
        c1.Label.String = string(cbar_label_PhaseLocked);
        yl1 = ylim(ax1);
        vline1 = line(ax1, [trace_x(idx) trace_x(idx)], yl1, 'Color', 'k', 'LineStyle', '--');

        % --- Plot 2: ITPC ---
        ax2 = nexttile;
        contourf(x_tf, frequencies, dat2plot_ITPC, 40, 'linecolor', 'none')
        ylabel('Frequency')
        xlabel('Time (ms)')
        title("ITPC")
        set(ax2, 'clim', color_edges_ITPC);
        c2 = colorbar;
        colormap("jet");
        xlim([-10 100]);
        c2.Label.String = string(cbar_label_ITPC);
        yl2 = ylim(ax2);
        vline2 = line(ax2, [trace_x(idx) trace_x(idx)], yl2, 'Color', 'k', 'LineStyle', '--');

        % --- Plot 3: GFP ---
        ax3 = nexttile;
        plot(GFP_times, GFP_data, '-k', 'LineWidth', 1.5)
        title("Global Field Power")
        Y_max = max(GFP_data(101:end)) * 1.25;
        xlim([-10 100]);
        ylim([0 Y_max]);
        xlabel('Time (ms)')
        ylabel('Amplitude (µV)')
        yl3 = ylim(ax3);
        vline3 = line(ax3, [trace_x(idx) trace_x(idx)], yl3, 'Color', 'k', 'LineStyle', '--');

        % --- Plot 4: Time Domain Average ---
        ax4 = nexttile;
        hold(ax4, 'on');
        plot(trace_x, trace_y, '-r', 'LineWidth', 1.5)
        title("Average")
        xlim(ax4, [-10 100]);
        xlabel('Time (ms)')
        ylabel('Amplitude (µV)')
        set(ax4, 'Ydir','reverse', 'YColor', 'k')
        Y_max = max(trace_y(201:751)) * 1.25;
        Y_min = min(trace_y(201:751)) * 1.25;
        ylim(ax4, [Y_min Y_max]);

        % Add cursor (red dot), vertical line, horizontal line
        cursor = plot(ax4, trace_x(idx), trace_y(idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
        x_limits = xlim(ax4);
        y_limits = ylim(ax4);
        v_line = plot(ax4, [trace_x(idx) trace_x(idx)], y_limits, 'k');
        h_line = plot(ax4, x_limits, [trace_y(idx) trace_y(idx)], 'k');

        % --- Interactivity ---
        n_points = length(trace_x);
        selected_points = [];
        set(gcf, 'KeyPressFcn', @key_press_callback);
        uiwait;

        % --- Selection check ---
        if isempty(selected_points)
            error('No peak was selected. Please try again.');
        end

        % --- Output peak data ---
        Peak_time = selected_points(end, 1);
        Peak_amp = selected_points(end, 2);
        close(f1);

    catch ME
        warning('Warning: %s Restarting selection...', ME.message);
        if ishandle(f1)
            close(f1);
        end
        restart = true;
    end
end

    % --- Callback function for key presses ---
    function key_press_callback(~, event)
        switch event.Key
            case 'rightarrow'
                if idx < n_points
                    idx = idx + 1;
                end
                set(cursor, 'MarkerEdgeColor', 'r');
            case 'leftarrow'
                if idx > 1
                    idx = idx - 1;
                end
                set(cursor, 'MarkerEdgeColor', 'r');
            case 'return'
                selected_points(end+1, :) = [trace_x(idx), trace_y(idx)];
                set(cursor, 'MarkerEdgeColor', 'b');
            case 'escape'
                uiresume;
                return;
        end

        % Update visuals
        set(cursor, 'XData', trace_x(idx), 'YData', trace_y(idx));
        set(h_line, 'XData', x_limits, 'YData', [trace_y(idx) trace_y(idx)]);
        set(vline1, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax1));
        set(vline2, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax2));
        set(vline3, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax3));
        set(v_line, 'XData', [trace_x(idx) trace_x(idx)], 'YData', ylim(ax4));
    end

end
