function [Peak_amp, Peak_time] = calcConditionManuTimePlus(CzAvg, x_tf, peak, frequencies, dat2plot_ITPC,...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data)

    trial = CzAvg;
    f1 = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
    t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

    % "Phase locked"
    ax1 = nexttile;
    contourf(x_tf, frequencies, dat2plot_PhaseLocked, 40, 'linecolor', 'none');
    ylabel('Frequency');
    xlabel('Time (ms)');
    title("Phase locked");
    set(ax1, 'clim', color_edges_PhaseLocked);
    c2 = colorbar;
    colormap("jet");
    xlim([-10 100]);
    c2.Label.String = string(cbar_label_PhaseLocked);

    % "ITPC"
    ax2 = nexttile;
    contourf(x_tf, frequencies, dat2plot_ITPC, 40, 'linecolor', 'none');
    ylabel('Frequency');
    xlabel('Time (ms)');
    title("ITPC");
    set(ax2, 'clim', color_edges_ITPC);
    c4 = colorbar;
    xlim([-10 100]);
    colormap("jet");
    c4.Label.String = string(cbar_label_ITPC);

    % Global Field Potential
    ax3 = nexttile;
    plot(GFP_times, GFP_data, '-k', 'LineWidth', 1.5);
    title("Global Field Power");
    Y_max = max(GFP_data(101:end)) * 1.25;

    xlim([-10 100]);
    ylim([0 Y_max]);
    xlabel('Time (ms)');
    ylabel('Amplitude (µV)');

    % Time domain average
    ax4 = nexttile;
    plot(times, CzAvg, '-r', 'LineWidth', 1.5);
    title("Average");
    xlim([-10 100]);
    xlabel('Time (ms)');
    ylabel('Amplitude (µV)');
    set(ax4, 'Ydir', 'reverse', 'YColor', 'k');

    hold(ax4, 'on');

    % Store the data for snapping
    XData = times;
    YData = CzAvg;

    % Mouse interaction setup
    set(f1, 'WindowButtonMotionFcn', @(~, ~) snapToTrace());
    set(f1, 'WindowButtonDownFcn', @(~, ~) storeClickedPoint());

    uiwait(f1);

    % Nested function: live marker
    function snapToTrace()
        cp = get(ax4, 'CurrentPoint');
        x_mouse = cp(1,1);
        if x_mouse < ax4.XLim(1) || x_mouse > ax4.XLim(2)
            snap_marker.XData = NaN;
            snap_marker.YData = NaN;
            return;
        end
        [~, idx] = min(abs(XData - x_mouse));
        snap_marker.XData = XData(idx);
        snap_marker.YData = YData(idx);
    end

    % Nested function: store clicked value
    function storeClickedPoint()
        cp = get(ax4, 'CurrentPoint');
        x_click = cp(1,1);
        if x_click < ax4.XLim(1) || x_click > ax4.XLim(2)
            return;
        end
        [~, idx] = min(abs(XData - x_click));
        Peak_time = XData(idx);
        Peak_amp = YData(idx);
        fprintf('Selected peak: Time = %.2f ms, Amplitude = %.2f µV\n', Peak_time, Peak_amp);

        % Optionally mark permanently and exit
        plot(ax4, Peak_time, Peak_amp, 'gs', 'MarkerSize', 10, 'LineWidth', 1.5);
        uiresume(f1); % Resume execution once user has clicked
    end
close(f1);

end




% function [Peak_amp, Peak_time] = calcConditionManuTimePlus(CzAvg, x_tf, peak, frequencies, dat2plot_ITPC,...
%     dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data)
% 
% trial = CzAvg;
% f1 = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
% t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");
% 
% % "Phase locked"
% ax1 =  nexttile;
% contourf(x_tf, frequencies, dat2plot_PhaseLocked,40,'linecolor', 'none')
% ylabel('Frequency')
% xlabel('Time (ms)')
% title("Phase locked")
% set(ax1, 'clim', color_edges_PhaseLocked);
% c2 = colorbar;
% colormap("jet");
% xlim([-10 100]);
% c2.Label.String = string(cbar_label_PhaseLocked);
% 
% % "ITPC"
% ax2 =  nexttile;
% contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
% ylabel('Frequency')
% xlabel('Time (ms)')
% title("ITPC")
% set(ax2, 'clim', color_edges_ITPC);
% c4 = colorbar;
% xlim([-10 100]);
% colormap("jet");
% c4.Label.String = string(cbar_label_ITPC)';
% 
% % Global Field Potential
% ax3 = nexttile;
% plot(GFP_times, GFP_data,'-k', 'LineWidth', 1.5)
% title("Global Field Power")
% Y_max = max(GFP_data(101:end))*1.25;
% 
% xlim([-10 100]);
% ylim([0 Y_max]);
% xlabel('Time (ms)')
% ylabel('Amplitude (µV)')
% 
% % Time domain average
% ax4 = nexttile;
% %CzAvg_limits = CzAvg(201:751);
% plot(times, CzAvg,'-r', 'LineWidth', 1.5)
% title("Average")
% xlim([-10 100]);
% xlabel('Time (ms)')
% ylabel('Amplitude (µV)')
% set(ax4, 'Ydir','reverse', 'YColor', 'k')
% 
% hold(ax4, 'on');
% 
% % h = drawrectangle('FaceAlpha', 0, 'Color', 'b');
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
% 
% 
% 
% 
% % Store the data for snapping
% XData = times;
% YData = CzAvg;
% % Mouse interaction setup
% set(f1, 'WindowButtonMotionFcn', @(~, ~) snapToTrace());
% set(f1, 'WindowButtonDownFcn', @(~, ~) storeClickedPoint());
% 
% uiwait(f1);
% 
% % Nested function: live marker
%     function snapToTrace()
%         cp = get(ax4, 'CurrentPoint');
%         x_mouse = cp(1,1);
%         if x_mouse < ax4.XLim(1) || x_mouse > ax4.XLim(2)
%             snap_marker.XData = NaN;
%             snap_marker.YData = NaN;
%             return;
%         end
%         [~, idx] = min(abs(XData - x_mouse));
%         snap_marker.XData = XData(idx);
%         snap_marker.YData = YData(idx);
%     end
% 
% % Nested function: store clicked value
%     function storeClickedPoint()
%         cp = get(ax4, 'CurrentPoint');
%         x_click = cp(1,1);
%         if x_click < ax4.XLim(1) || x_click > ax4.XLim(2)
%             return;
%         end
%         [~, idx] = min(abs(XData - x_click));
%         Peak_time = XData(idx);
%         Peak_amp = YData(idx);
%         fprintf('Selected peak: Time = %.2f ms, Amplitude = %.2f µV\n', Peak_time, Peak_amp);
% 
%         % Optionally mark permanently and exit
%         plot(ax4, Peak_time, Peak_amp, 'gs', 'MarkerSize', 10, 'LineWidth', 1.5);
%         uiresume(f1); % Resume execution once user has clicked
%     end
% end
% 
% 
% close(f1)