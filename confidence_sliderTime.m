function [Confidence_val] = confidence_sliderTime(peak,CzAvg, times, Peak_time, Peak_amp)

f1 = figure('units','normalized','outerposition',[0.3 0.2 0.5 0.40]);
plot(times, CzAvg,'-r', 'LineWidth', 1.5)
set(gca, 'Ydir','reverse')
hold on
xlim([-10 100])
title(peak)
display(Peak_time)
display(Peak_amp)
plot(Peak_time, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)

% Create the figure
f = figure('Position', [25, 300, 550, 200], ...
    'Name', 'Peak Confidence', ...
    'NumberTitle', 'off');

% Add the title as a static text at the top
uicontrol('Style', 'text', ...
    'Position', [50, 150, 450, 30], ...
    'String', 'How confident are you your judgement was correct?', 'FontSize', 10, ...
    'HorizontalAlignment', 'center');

% Slider position info
slider_left = 100;
slider_width = 350;
slider_bottom = 90;

% Create the slider (free movement)
s = uicontrol('Style', 'slider', ...
    'Min', 0, 'Max', 1, ...
    'Value', 0.5, ...
    'SliderStep', [0.01 0.1], ...
    'Position', [slider_left, slider_bottom, slider_width, 20]);

% Define labeled values and their names
label_values = [0, 0.5, 1];
label_names = {'Not', 'Somewhat', 'Very'};
percent_labels = {'0%', '', '100%'};

% Place static text labels above the slider
for i = 1:length(label_values)
    rel_x = (label_values(i) - 0) / (1 - 0); % Normalize
    x_pos = slider_left + rel_x * slider_width - 25;

    % Top label (e.g., Not, Somewhat, Very)
    uicontrol('Style', 'text', ...
        'Position', [x_pos, slider_bottom + 25, 55, 15], ...
        'String', label_names{i}, ...
        'HorizontalAlignment', 'center');

    % Bottom label (e.g., 0%, 100%)
    if ~isempty(percent_labels{i})
        uicontrol('Style', 'text', ...
            'Position', [x_pos, slider_bottom - 20, 55, 15], ...
            'String', percent_labels{i}, ...
            'HorizontalAlignment', 'center');
    end
end

uicontrol('Style', 'pushbutton', ...
    'String', 'Continue', ...
    'Position', [150, 30, 100, 30], ...
    'Callback', @continue_callback);

% Wait for the user to press "Continue"
uiwait(f);

% Get value after UI resumes
Confidence_val = s.Value;
close(f); % Close the UI if not already

    function continue_callback(~, ~)
        uiresume(f); % Resume main function
    end
close(f1)
end


