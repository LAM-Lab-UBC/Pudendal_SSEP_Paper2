function [Man_Max_Power, Man_Max_Frequency, Man_Max_Time] = Manu_calcMax_TF_v5( ...
                        x_tf, frequencies, dat2plot, CzAvg,times,...
                         cbar_label, color_edges, type)

    % Create tiled layout with specific tile spacing and padding
    j = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
    t = tiledlayout('vertical', 'TileSpacing', 'tight', 'Padding', 'tight');  
    
    % First tile: Time Domain Average
    ax1 = nexttile(t);
    plot(ax1, times, CzAvg);
    title(ax1, 'Average');
    xlim(ax1, [-10 100]);
    xlabel(ax1, 'Time (ms)');
    ylabel(ax1, 'Amplitude (µV)');
    set(ax1, 'Ydir', 'reverse', 'YColor', 'k');

    % Second tile: Time Frequency Response
    ax2 = nexttile(t);
    contourf(ax2, x_tf, frequencies, dat2plot, 40, 'linecolor', 'none');
    hold(ax2, 'on');
    ylabel(ax2, 'Frequency');
    xlabel(ax2, 'Time (ms)');
    title(ax2, type);
    set(ax2, 'clim', color_edges);
    c1 = colorbar(ax2);
    colormap(ax2, 'jet');
    c1.Label.String = string(cbar_label);
    
    % Draw rectangle interactively
    h = drawrectangle(ax2, 'FaceAlpha', 0, 'Color', 'b');
    wait(h); % Wait for user to finish drawing the rectangle
    rect_position = h.Position;
    
    % Extract rectangle position and size
    rect_x = rect_position(1);
    rect_width = rect_position(3);
    rect_y = rect_position(2);
    rect_height = rect_position(4);
    
    % Ensure rect_position does not exceed x_tf bounds
    x_min = max(min(x_tf), rect_x);
    x_max = min(max(x_tf), rect_x + rect_width);
    y_min = max(min(frequencies), rect_y);
    y_max = min(max(frequencies), rect_y + rect_height);
    
    % Define x-axis and y-axis range of interest from the drawn rectangle
    x_roi = x_tf(x_tf >= x_min & x_tf <= x_max);
    y_roi = frequencies(frequencies >= y_min & frequencies <= y_max);
    
    % Find the corresponding indices for x_roi and y_roi in dat2plot
    x_indices = x_tf >= x_min & x_tf <= x_max;
    y_indices = frequencies >= y_min & frequencies <= y_max;
    y_roi_data = dat2plot(y_indices, x_indices);

    % Find the maximum power and its indices
    [max_power_row, row_max_ind] = max(y_roi_data, [], 1); % Find max power in each time slice
    [Man_Max_Power, time_max_ind] = max(max_power_row); % Find max power and its time index
    freq_max_ind = row_max_ind(time_max_ind); % Find frequency index for max power
    Man_Max_Frequency = y_roi(freq_max_ind); % Corresponding frequency
    Man_Max_Time = x_roi(time_max_ind); % Corresponding time
    
    % Plot max point
    plot(ax2, Man_Max_Time, Man_Max_Frequency, 'bo', 'MarkerSize', 10, 'LineWidth', 2);
    
    hold(ax2, 'off');
    close(j)
end
