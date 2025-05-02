function [Confidence_val] = confidence_sliderTimePlus(CzAvg, x_tf, peak, frequencies, dat2plot_ITPC,...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC, times, GFP_times, GFP_data, Response_elect, Peak_time_times, Peak_amp)



f1 = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

% "Phase locked"
ax1 =  nexttile;
contourf(x_tf, frequencies, dat2plot_PhaseLocked,40,'linecolor', 'none')
ylabel('Frequency')
xlabel('Time (ms)')
title("Phase locked")
set(ax1, 'clim', color_edges_PhaseLocked);
c2 = colorbar;
colormap("jet");
xlim([-10 100]);
c2.Label.String = string(cbar_label_PhaseLocked);

% "ITPC"
ax2 =  nexttile;
contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
ylabel('Frequency')
xlabel('Time (ms)')
title("ITPC")
set(ax2, 'clim', color_edges_ITPC);
c4 = colorbar;
xlim([-10 100]);
colormap("jet");
c4.Label.String = string(cbar_label_ITPC)';

% Global Field Potential
ax3 = nexttile;
plot(GFP_times, GFP_data,'-k', 'LineWidth', 1.5)
title("Global Field Power")
Y_max = max(GFP_data(101:end))*1.25;

xlim([-10 100]);
ylim([0 Y_max]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
%
% % Time domain average
ax4 = nexttile;
%CzAvg_limits = CzAvg(201:751);
plot(times, CzAvg,'-r', 'LineWidth', 1.5)
title("Average")
xlim([-10 100]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
set(ax4, 'Ydir','reverse', 'YColor', 'k')
hold(ax4, 'on');
plot(Peak_time_times, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)


% Create the figure
f = figure('Position', [500, 300, 550, 200], ...
    'Name', 'Peak Confidence', ...
    'NumberTitle', 'off');

% Add the title as a static text at the top
uicontrol('Style', 'text', ...
    'Position', [50, 150, 300, 30], ...
    'String', append('How confident are you in your choice of ', ...
    Response_elect, ' for ', peak), 'FontSize', 10, ...
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


