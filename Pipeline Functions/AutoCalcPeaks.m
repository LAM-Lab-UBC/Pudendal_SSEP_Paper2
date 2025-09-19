function [Peak_amp,Peak_index, n] = AutoCalcPeaks(CzAvg, times, Peak, frequencies, dat2plot_ITPC,...
    dat2plot_PhaseLocked, color_edges_PhaseLocked, color_edges_ITPC, cbar_label_PhaseLocked, cbar_label_ITPC,...
    GFP_times, GFP_data, x_tf)
if strcmp(Peak, "P1") % Set range to find P1 in the range of 32ms to 47ms post stim
    Lower = 411; 
    Upper = 486;
elseif strcmp(Peak, "P2") % Set range to find P2 in the range of 52ms to 67ms post stim
    Lower = 511;
    Upper = 586;
elseif strcmp(Peak, "N1") % Set range to find N1 in the range of 47ms to 58ms post stim
    Lower = 486;
    Upper = 541;
elseif strcmp(Peak, "N2") % Set range to find N2 in the range of 67ms to 88ms post stim
    Lower = 586;
    Upper = 691;
end

%% Auto-Cacluate P40
%calculates P40
temp = CzAvg; %make variable called temp which holds the y data temporarily
temp100 = temp + 100; %add 100 to temp to deal with signal being mis-centered around 0
if strcmp(Peak, "P2") ||  strcmp(Peak, "P1")
    [Peak_amp100, Peak_index100] = max(temp100(Lower:Upper)); %look for the most positive value bewteen line 411 and 486, which corresponds to ~32-47ms. Most positive b/c it's not flipped. reports amplitude and location of data point.
elseif strcmp(Peak, "N2") ||  strcmp(Peak, "N1")
    [Peak_amp100, Peak_index100] = min(temp100(Lower:Upper));
end
Peak_amp = Peak_amp100 - 100; %take the amplitude and subtract by 100 to get correct value
Peak_indexframes = Peak_index100 + Lower -1; %takes the index fo best value, and adds 431 to it b/c of search range
Peak_index = times(Peak_indexframes); %figures out the corresponding time to the frame

n = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

% First Tile: "Phase locked"
ax1 =  nexttile;
contourf(x_tf, frequencies, dat2plot_PhaseLocked,40,'linecolor', 'none')
ylabel('Frequency')
xlabel('Time (ms)')
title("Phase locked")
xlim([-10 100]);
set(ax1, 'clim', color_edges_PhaseLocked);
c2 = colorbar;
colormap("jet");
c2.Label.String = string(cbar_label_PhaseLocked);

% Second tile: "ITPC"
ax2 =  nexttile;
contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
ylabel('Frequency')
xlabel('Time (ms)')
title("ITPC")
xlim([-10 100]);
set(ax2, 'clim', color_edges_ITPC);
c4 = colorbar;
colormap("jet");
c4.Label.String = string(cbar_label_ITPC)';

% Third tile: Global Field Potential
ax3 = nexttile;
plot(GFP_times, GFP_data,'-k', 'LineWidth', 1.5)
title("Global Field Potential")
xlim([-10 100]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')

% Fourth tile: Time domain average
ax4 = nexttile;
%CzAvg_limits = CzAvg(201:751);
plot(times, CzAvg,'-r', 'LineWidth', 1.5)
hold on
title("Average")
xlim([-10 100]);
plot(Peak_index, Peak_amp, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
set(ax4, 'Ydir','reverse', 'YColor', 'k')








