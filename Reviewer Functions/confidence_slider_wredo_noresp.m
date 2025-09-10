function [Confidence_val, redo] = confidence_slider_wredo_noresp()
%Used when No is selected for either Overall Response or N2 identifying    
%CONFIDENCE_SLIDER_WREDO  Slider dialog with Continue and Redo buttons
    %
    %   [Confidence_val, redo] = confidence_slider_wredo()
    %
    % Returns:
    %   Confidence_val  Scalar in [0,1] from the slider
    %   redo            Logical flag: true if “Redo Trial” was clicked



% --- now build the modal slider dialog ---
f = figure('Units',       'normalized', ...
    'Position',    [0.7 0.42  0.27 0.18], ...  % [left bottom width height]
    'Name', 'Peak Confidence', ...
    'NumberTitle', 'off');

% Add the title as a static text at the top
uicontrol('Style', 'text', ...
    'Units',       'normalized', ...
    'Position', [0.10, 0.7, 0.8, 0.2], ...
    'String', "How confident are you in selecting 'Not Identifiable'?", 'FontSize', 10, ...
    'HorizontalAlignment', 'center');

% Slider position info
slider_left = 0.1;
slider_bottom = 0.4;
slider_width = 0.8;
slider_height = 0.12;

% Create the slider (free movement)
s = uicontrol('Style', 'slider', ...
    'Min', 0, 'Max', 1, ...
    'Value', 0.5, ...
    'SliderStep', [0.01 0.1], ...
    'Units',       'normalized', ...
    'Position', [slider_left, slider_bottom, slider_width, slider_height]);

% Define labeled values and their names
label_values = [0, 0.5, 1];
label_names = {'Not at all confident', 'Somewhat confident', 'Entirely confident'};
percent_labels = {'0%', '', '100%'};

% Place static text labels above the slider
for i = 1:length(label_values)
    rel_x = (label_values(i) - 0) / (1 - 0); % Normalize
    x_pos = slider_left + rel_x * slider_width - .27;

    % Top label (e.g., Not, Somewhat, Very)
    uicontrol('Style', 'text', ...
        'Units',       'normalized', ...
        'Position', [x_pos, slider_bottom + slider_height, .55, .15], ...
        'String', label_names{i}, ...
        'HorizontalAlignment', 'center');

    % Bottom label (e.g., 0%, 100%)
    if ~isempty(percent_labels{i})
        uicontrol('Style', 'text', ...
            'Units',       'normalized', ...
            'Position', [x_pos, slider_bottom - .15, .55, .15], ...
            'String', percent_labels{i}, ...
            'HorizontalAlignment', 'center');
    end
end

uicontrol('Style', 'pushbutton', ...
    'String', 'Continue', ...
    'Units',       'normalized', ...
    'Position',[0.1 0.10 0.35 0.18], ...
    'Callback', @continue_callback);


% Redo Trial button
uicontrol('Parent',f,'Style','pushbutton', ...
    'String','Redo Trial', ...
    'Units',       'normalized', ...
    'Position',[0.55 0.10 0.35 0.18], ...
    'Callback',@(~,~) set_and_resume(true));

% wait for user choice
uiwait(f);

    % Read out results
    Confidence_val = s.Value;
    redo           = getappdata(f, 'redo_flag');

    % Close the dialog
    if ishandle(f), close(f); end
end

function continue_callback(~, ~)
    % Mark “no redo” and resume
    setappdata(gcbf, 'redo_flag', false);
    uiresume(gcbf);
end

function set_and_resume(doRedo)
    % Mark redo flag and resume
    setappdata(gcbf, 'redo_flag', doRedo);
    uiresume(gcbf);
end
