function [Peak_time, Peak_amp] = calcConditionManuTimeV2(trace_x, trace_y, peak)
    % Plot the trace
    f1 = figure('units','normalized','outerposition',[0.3 0.2 0.5 0.40]);
    plot(trace_x, trace_y,'-r', 'LineWidth', 1.5);
    hold on;
    set(gca, 'Ydir','reverse')
    xlim([-10 100])
    Y_max = max(trace_y(201:751))*1.25;
    Y_min = min(trace_y(201:751))*1.25;
    ylim([Y_min Y_max])
    title( {peak,'Use arrow keys to move. Press Enter to select. Esc to quit.'});

    % Initial index
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
    
    n_points = length(trace_x);
    cursor = plot(trace_x(idx), trace_y(idx), 'ro', 'MarkerSize', 10, 'LineWidth', 2);
    y_limits = ylim;
    x_limits = xlim;
    v_line = plot([trace_x(idx) trace_x(idx)], y_limits, 'k');
    h_line = plot(x_limits, [trace_y(idx) trace_y(idx)], 'k');
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
    Peak_time = Peak_time(end);
    Peak_amp = Peak_amp(end);
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
                %fprintf('Point selected: (%.4f, %.4f)\n', trace_x(idx), trace_y(idx));
                set(cursor, 'MarkerEdgeColor', 'b');
            case 'escape'
                uiresume;
                return;
        end
        % Update cursor position
        set(cursor, 'XData', trace_x(idx), 'YData', trace_y(idx));
        set(v_line, 'XData', [trace_x(idx) trace_x(idx)], 'YData', y_limits);
        set(h_line, 'XData', x_limits, 'YData', [trace_y(idx) trace_y(idx)]);
    end
close(f1)
end
