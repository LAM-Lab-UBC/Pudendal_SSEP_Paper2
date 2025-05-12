function [Confidence_val, redo] = confidence_slider_wredo()
    %CONFIDENCE_SLIDER_WREDO  Slider dialog with Continue and Redo buttons
    %
    %   [Confidence_val, redo] = confidence_slider_wredo()
    %
    % Returns:
    %   Confidence_val  Scalar in [0,1] from the slider
    %   redo            Logical flag: true if “Redo Trial” was clicked

    % Create the figure (modal)
    f = figure( ...
        'Position',    [1350, 400, 550, 200], ...
        'Name',        'Peak Confidence', ...
        'NumberTitle', 'off', ...
        'WindowStyle', 'modal' ...
    );

    % Instruction text
    uicontrol('Parent', f, 'Style', 'text', ...
        'Position', [50, 150, 450, 30], ...
        'String', 'How confident are you in selecting this location?', ...
        'FontSize', 10, 'HorizontalAlignment', 'center');

    % Slider position info
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
        x   = slider_left + rel*slider_width - 25;
        uicontrol('Parent', f, 'Style', 'text', ...
            'Position', [x, slider_bottom + 25, 55, 15], ...
            'String', label_names{k}, ...
            'HorizontalAlignment', 'center');
        if ~isempty(percent_labels{k})
            uicontrol('Parent', f, 'Style', 'text', ...
                'Position', [x, slider_bottom - 20, 55, 15], ...
                'String', percent_labels{k}, ...
                'HorizontalAlignment', 'center');
        end
    end

    % Initialize the redo flag
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

    % Block until user makes a choice
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
