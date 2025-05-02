function [x_out, y_out] = pointSelectionV2(trace_x, trace_y, peak)
    % Plot the trace
    figure;
    plot(trace_x, trace_y, 'b'); hold on;
    xlim([-10 100])
    title('Use arrow keys to move. Press Enter to select. Esc to quit.');
    % Initial index
    if strcmp(peak, "P1")
        idx = 451;
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
        x_out = selected_points(:,1);
        y_out = selected_points(:,2);
    else
        x_out = [];
        y_out = [];
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
        set(cursor, 'XData', trace_x(idx), 'YData', trace_y(idx));
        set(v_line, 'XData', [trace_x(idx) trace_x(idx)], 'YData', y_limits);
        set(h_line, 'XData', x_limits, 'YData', [trace_y(idx) trace_y(idx)]);
    end
end
