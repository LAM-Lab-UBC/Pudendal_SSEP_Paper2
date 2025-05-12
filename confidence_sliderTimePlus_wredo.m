function [Confidence_val, redo] = confidence_sliderTimePlus_wredo(...
        CzAvg, x_tf, frequencies, dat2plot_ITPC, ...
        dat2plot_PhaseLocked, color_edges_PhaseLocked, ...
        color_edges_ITPC, cbar_label_PhaseLocked, ...
        cbar_label_ITPC, times, GFP_times, GFP_data, ...
        Peak_time, Peak_amp)
    % Same multi‐panel plot as before
    f1 = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
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
    f = figure(...
        'Position',    [1350, 300, 550, 200], ...
        'Name',        'Peak Confidence', ...
        'NumberTitle', 'off', ...
        'WindowStyle', 'modal' ...
    );

    % Instruction
    uicontrol('Parent',f,'Style','text', ...
        'Position',[50,150,450,30], ...
        'String','How confident are you in selecting this location?', ...
        'FontSize',10,'HorizontalAlignment','center');

    % Slider
    slider_left   = 100;
    slider_width  = 350;
    slider_bottom = 90;
    s = uicontrol('Parent',f,'Style','slider', ...
        'Min',0,'Max',1,'Value',0.5, ...
        'SliderStep',[0.01 0.1], ...
        'Position',[slider_left,slider_bottom,slider_width,20]);

    % Labels
    label_values   = [0,0.5,1];
    label_names    = {'Not at all confident','Somewhat confident','Entirely confident'};
    percent_labels = {'0%','', '100%'};
    for k = 1:numel(label_values)
        rel = label_values(k);
        x   = slider_left + rel*slider_width - 25;
        uicontrol('Parent',f,'Style','text', ...
            'Position',[x,slider_bottom+25,55,15], ...
            'String',label_names{k}, ...
            'HorizontalAlignment','center');
        if ~isempty(percent_labels{k})
            uicontrol('Parent',f,'Style','text', ...
                'Position',[x,slider_bottom-20,55,15], ...
                'String',percent_labels{k}, ...
                'HorizontalAlignment','center');
        end
    end

    % initialize redo flag
    setappdata(f,'redo_flag',false);

    % Continue button
    uicontrol('Parent',f,'Style','pushbutton', ...
        'String','Continue', ...
        'Position',[150,30,100,30], ...
        'Callback',@continue_callback);

    % Redo Trial button
    uicontrol('Parent',f,'Style','pushbutton', ...
        'String','Redo Trial', ...
        'Position',[300,30,100,30], ...
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
