function [Confidence_val, redo] = confidence_sliderTime_wredo(peak, CzAvg, times, Peak_time, Peak_amp)
    % Plot the signal and mark the peak
    f1 = figure('units','normalized','outerposition',[0.2 0.2 0.5 0.40]);
    plot(times, CzAvg, '-r', 'LineWidth', 1.5);
    set(gca, 'YDir', 'reverse');
    hold on;
    xlim([-10 100]);
    title(peak);
    plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2);

    % Create the confidence slider dialog
    f = figure('Position', [1350, 300, 550, 200], ...
               'Name', 'Peak Confidence', ...
               'NumberTitle', 'off', ...
               'WindowStyle', 'modal');

    % Instruction text
    uicontrol('Parent', f, 'Style', 'text', ...
              'Position', [50, 150, 450, 30], ...
              'String', 'How confident are you in selecting this location?', ...
              'FontSize', 10, 'HorizontalAlignment', 'center');

    % Slider
    slider_left   = 100;
    slider_width  = 350;
    slider_bottom = 90;
    s = uicontrol('Parent', f, 'Style', 'slider', ...
                  'Min', 0, 'Max', 1, 'Value', 0.5, ...
                  'SliderStep', [0.01 0.1], ...
                  'Position', [slider_left, slider_bottom, slider_width, 20]);

    % Labels above/below the slider
    label_values   = [0, 0.5, 1];
    label_names    = {'Not at all confident', 'Somewhat confident', 'Entirely confident'};
    percent_labels = {'0%', '', '100%'};
    for k = 1:numel(label_values)
        rel = (label_values(k) - 0) / (1 - 0);
        x  = slider_left + rel * slider_width - 25;
        uicontrol('Parent', f, 'Style', 'text', ...
                  'Position', [x, slider_bottom + 25, 55, 15], ...
                  'String', label_names{k}, 'HorizontalAlignment', 'center');
        if ~isempty(percent_labels{k})
            uicontrol('Parent', f, 'Style', 'text', ...
                      'Position', [x, slider_bottom - 20, 55, 15], ...
                      'String', percent_labels{k}, 'HorizontalAlignment', 'center');
        end
    end

    % Initialize the redo flag to false
    setappdata(f, 'redo_flag', false);

    % Continue button
    uicontrol('Parent', f, 'Style', 'pushbutton', ...
              'String', 'Continue', ...
              'Position', [150, 30, 100, 30], ...
              'Callback', @continue_callback);

    % Redo Trial button
    uicontrol('Parent', f, 'Style', 'pushbutton', ...
              'String', 'Redo Trial', ...
              'Position', [300, 30, 100, 30], ...
              'Callback', @(~,~) set_and_resume(true));

    % Block until one of the callbacks calls uiresume
    uiwait(f);

    % Read out results
    Confidence_val = s.Value;
    redo           = getappdata(f, 'redo_flag');

    % Clean up
    if ishandle(f),  close(f);  end
    if ishandle(f1), close(f1); end
end

function continue_callback(~, ~)
    % Mark “no redo” and resume
    setappdata(gcbf, 'redo_flag', false);
    uiresume(gcbf);
end

function set_and_resume(doRedo)
    % Mark redo or not, then resume
    setappdata(gcbf, 'redo_flag', doRedo);
    uiresume(gcbf);
end
