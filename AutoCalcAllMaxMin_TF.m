function [Auto_Max_Power_PLP,Auto_Max_Frequency_PLP, Auto_Max_Time_PLP, ...
    Auto_Max_Power_ITPC,Auto_Max_Frequency_ITPC, Auto_Max_Time_ITPC, h] = AutoCalcAllMaxMin_TF( ...
    x_tf, frequencies, dat2plot_ITPC, CzAvg,times, ...
    cbar_label_ITPC, color_edges_ITPC,dat2plot_PLP, cbar_label_PLP, color_edges_PLP)

%% Phase Locked
[PLP_row_max_val, PLP_row_max_ind] = max(dat2plot_PLP(:,351:751)); % Look in time interval 30ms to end
[PLP_Max_Power, PLP_power_total_max_ind] = max(PLP_row_max_val);
PLP_freq_total_max_ind = PLP_row_max_ind(PLP_power_total_max_ind);  % Correctly index row_max_ind
PLP_Max_Frequency = frequencies(PLP_freq_total_max_ind);
PLP_Max_Time = x_tf(351 + PLP_power_total_max_ind - 1);  % Adjusted index to x_tf

Auto_Max_Power_PLP = PLP_Max_Power;
Auto_Max_Frequency_PLP = PLP_Max_Frequency;
Auto_Max_Time_PLP = PLP_Max_Time;

%% ITPC
[ITPC_row_max_val, ITPC_row_max_ind] = max(dat2plot_ITPC(:,351:751)); % Look in time interval 30ms to end
[ITPC_Max_Power, ITPC_power_total_max_ind] = max(ITPC_row_max_val);
ITPC_freq_total_max_ind = ITPC_row_max_ind(ITPC_power_total_max_ind);  % Correctly index row_max_ind
ITPC_Max_Frequency = frequencies(ITPC_freq_total_max_ind);
ITPC_Max_Time = x_tf(351 + ITPC_power_total_max_ind - 1);  % Adjusted index to x_tf

Auto_Max_Power_ITPC = ITPC_Max_Power;
Auto_Max_Frequency_ITPC = ITPC_Max_Frequency;
Auto_Max_Time_ITPC = ITPC_Max_Time;

%% PLOTTING
h = figure('units','normalized','outerposition',[0.3 0.04 0.5 0.96]);
t = tiledlayout("vertical", "TileSpacing","tight", "Padding","tight");

% phase locked
ax3 = nexttile;
contourf(x_tf, frequencies, dat2plot_PLP,40,'linecolor', 'none')
hold on
xlim([-10 100]);
ylabel('Frequency')
xlabel('Time (ms)')
title("Phase Locked")
set(ax3, 'clim', color_edges_PLP);
c3 = colorbar;
colormap("jet");
c3.Label.String = string(cbar_label_PLP);
plot(Auto_Max_Time_PLP, Auto_Max_Frequency_PLP, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
hold off

% ITPC
ax4 =  nexttile;
contourf(x_tf, frequencies, dat2plot_ITPC,40,'linecolor', 'none')
hold on
xlim([-10 100]);
ylabel('Frequency')
xlabel('Time (ms)')
title("ITPC")
set(ax4, 'clim', color_edges_ITPC);
c4 = colorbar;
colormap("jet");
c4.Label.String = string(cbar_label_ITPC);
plot(Auto_Max_Time_ITPC, Auto_Max_Frequency_ITPC, 'bo', 'MarkerSize', 10, 'LineWidth', 2)
hold off

% Time domain Trace
ax6 = nexttile;
plot(times, CzAvg)
title("Average")
xlim([-10 100]);
xlabel('Time (ms)')
ylabel('Amplitude (µV)')
set(ax6, 'Ydir','reverse', 'YColor', 'k')

% main_title = append(PartNum, ' ', Setup);
% title(t, main_title)