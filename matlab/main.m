% EL3015 - Tugas Besar: Inverted Pendulum Control
% Anggota (Nama/NIM):
% 1. Rafi Ihsan Alfathin / 13223018
% 2. Maghryza Milchan Fayumi / 13223036
% 3. William Anthony / 13223048
%
% Sources:
% - CTMS Inverted Pendulum system modeling example
% - MIT OCW Systems Modeling and Control materials

clear; clc; close all;

root_dir = fileparts(mfilename('fullpath'));
addpath(root_dir);

out_dir = fullfile(root_dir, 'figures');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

params = params_inverted_pendulum();
[plant_ct, Gx, Gth] = model_continuous(params);

disp('Continuous-time state-space (outputs: x and theta):');
plant_ct

disp('Continuous-time transfer function (x/F):');
Gx

disp('Continuous-time transfer function (theta/F):');
Gth

% Analysis and controller (continuous-time)
run_analysis(Gth, [], 'CT uncompensated', out_dir);

bw_target = 5;
[Cct, info_ct] = design_pid_controller(Gth, bw_target);

disp('Continuous-time PID controller:');
Cct

disp('PID tuning info:');
info_ct

run_analysis(Gth, Cct, 'CT compensated', out_dir);

Tx_ct = minreal(Gx / (1 + Cct * Gth));
plot_cart_impulse(Tx_ct, 'CT cart position', ...
    'CT Cart Position - Impulse', ...
    'CT Cart Position - Impulse Response (disturbance)', out_dir);

% Discretization
Ts = 0.02;
plant_dt = c2d(plant_ct, Ts, 'zoh');
Gth_dt = c2d(Gth, Ts, 'zoh');
Gx_dt = minreal(tf(plant_dt(1)));

disp('Discrete-time state-space (ZOH):');
plant_dt

disp('Discrete-time transfer function (theta/F):');
Gth_dt

% Controller design (discrete-time)
[Cdt, info_dt] = design_pid_controller(Gth_dt, bw_target);

disp('Discrete-time PID controller:');
Cdt

disp('PID tuning info:');
info_dt

% Discrete analysis
run_analysis(Gth_dt, [], 'DT uncompensated', out_dir);
run_analysis(Gth_dt, Cdt, 'DT compensated', out_dir);

Tx_dt = minreal(Gx_dt / (1 + Cdt * Gth_dt));
plot_cart_impulse(Tx_dt, 'DT cart position', ...
    'DT Cart Position - Impulse', ...
    sprintf('DT Cart Position - Impulse Response (Ts = %.3f s)', Ts), out_dir);

% Comparison between continuous and discrete
Tc = feedback(Cct * Gth, 1);
Td = feedback(Cdt * Gth_dt, 1);
compare_continuous_discrete(Tc, Td, out_dir, Ts);

T = minreal(feedback(Cct * Gth, 1), 1e-6);
isstable(T)
pole(T)

function metrics = run_analysis(G, C, label, out_dir)
metrics = analysis_siso(G, C, label, 'theta (rad)', out_dir);
print_metrics(label, metrics);
end

function plot_cart_impulse(Tx, tag_label, fig_name, plot_title, out_dir)
tag = make_tag(tag_label);
fig = figure('Name', fig_name);
impulse(Tx);
grid on;
title(plot_title);
xlabel('Time (s)');
ylabel('x (m)');
legend('x (m)', 'Location', 'best');
saveas(fig, fullfile(out_dir, [tag '_impulse.png']));
end