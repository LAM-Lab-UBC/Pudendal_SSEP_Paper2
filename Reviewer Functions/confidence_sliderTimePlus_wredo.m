function [Confidence_val, redo] = confidence_sliderTimePlus_wredo(...
    CzAvg, x_tf, frequencies, dat2plot_ITPC, ...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, ...
    color_edges_ITPC, cbar_label_PhaseLocked, ...
    cbar_label_ITPC, times, GFP_times, GFP_data, ...
    Peak_time, Peak_amp)
% Same multi‐panel plot as before
f1 = figure('units','normalized','outerposition',[0.2 0.04 0.5 0.96]);
t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");
ax1 = nexttile;
contourf(x_tf, frequencies, dat2plot_PhaseLocked, 40, 'linecolor','none');
ylabel('Frequency'); xlabel('Time (ms)'); title("Phase locked");
set(ax1,'clim',color_edges_PhaseLocked);
c1 = colorbar; colormap("jet");
c1.Label.String = string(cbar_label_PhaseLocked);
xlim([-10 100]);

ax2 = nexttile;
contourf(x_tf, frequencies, dat2plot_ITPC, 40, 'linecolor','none');
ylabel('Frequency'); xlabel('Time (ms)'); title("ITPC");
set(ax2,'clim',color_edges_ITPC);
c2 = colorbar; colormap("jet");
c2.Label.String = string(cbar_label_ITPC);
xlim([-10 100]);

ax3 = nexttile;
plot(GFP_times, GFP_data, '-k','LineWidth',1.5);
title("Global Field Power");
xlim([-10 100]);
ylim([0 max(GFP_data(101:end))*1.25]);
xlabel('Time (ms)'); ylabel('Amplitude (µV)');

ax4 = nexttile;
plot(times, CzAvg, '-r','LineWidth',1.5);
title("Average"); xlim([-10 100]);
xlabel('Time (ms)'); ylabel('Amplitude (µV)');
set(ax4, 'YDir','reverse','YColor','k');
hold(ax4,'on');
plot(Peak_time, Peak_amp, 'bo','MarkerSize',10,'LineWidth',2);

% --- now build the modal slider dialog ---
f = figure('Units',       'normalized', ...
    'Position',    [0.7 0.42  0.27 0.18], ...  % [left bottom width height]
    'Name', 'Peak Confidence', ...
    'NumberTitle', 'off');

% Add the title as a static text at the top
uicontrol('Style', 'text', ...
    'Units',       'normalized', ...
    'Position', [0.10, 0.7, 0.8, 0.2], ...
    'String', 'How confident are you in selecting this location?', 'FontSize', 10, ...
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

% read out
Confidence_val = s.Value;
redo           = getappdata(f,'redo_flag');

% cleanup
if ishandle(f),  close(f);  end
if ishandle(f1), close(f1); end
end

function continue_callback(~,~)
setappdata(gcbf,'redo_flag',false);
uiresume(gcbf);
end

function set_and_resume(doRedo)
setappdata(gcbf,'redo_flag',doRedo);
uiresume(gcbf);
end
