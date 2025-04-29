function [Confidence_val] = confidence_slider(peak)



% Create the figure
f = figure('Position', [500, 300, 550, 200], ...
    'Name', 'Peak Confidence', ...
    'NumberTitle', 'off');

% Add the title as a static text at the top
uicontrol('Style', 'text', ...
    'Position', [50, 150, 300, 30], ...
    'String', 'How confident are you in your choice ', ...
    'FontSize', 10, ...
    'HorizontalAlignment', 'center');

% Slider position info
slider_left = 100;
slider_width = 350;
slider_bottom = 90;

% Create the slider (free movement)
s = uicontrol('Style', 'slider', ...
    'Min', 1, 'Max', 5, ...
    'Value', 3, ...
    'SliderStep', [0.01 0.1], ...
    'Position', [slider_left, slider_bottom, slider_width, 20]);

% Define labeled values and their names
label_values = [1, 3, 5];
label_names = {'Not', 'Somewhat', 'Very'};

% Place static text labels above the slider
for i = 1:length(label_values)
    rel_x = (label_values(i) - 1) / (5 - 1); % Normalize between 0 and 1
    x_pos = slider_left + rel_x * slider_width - 25; % adjust for centering
    uicontrol('Style', 'text', ...
        'Position', [x_pos, slider_bottom + 25, 55, 15], ...
        'String', label_names{i}, ...
        'HorizontalAlignment', 'center');
end

% % Add the "Continue" button
% uicontrol('Style', 'pushbutton', ...
%     'String', 'Continue', ...
%     'Position', [150, 30, 100, 30], ...
%     'Callback', @continue_callback);
%
%     function [Confidence_val] = continue_callback(~, ~)
%         Confidence_val = s.Value; % Get current slider value
%         assignin('base', 'selected_value', Confidence_val); % Save to workspace
%         close(f); % Close the UI
%     end
% end

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
end