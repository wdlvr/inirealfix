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

script_dir = fileparts(mfilename('fullpath'));
addpath(script_dir);

output_dir = fullfile(script_dir, 'figures');
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

p = params_inverted_pendulum();

[sys, Gx, Gtheta] = model_continuous(p);

disp('Continuous-time state-space (outputs: x and theta):');
sys

disp('Continuous-time transfer function (x/F):');
Gx

disp('Continuous-time transfer function (theta/F):');
Gtheta

% Analysis before compensation
metrics_uncomp = analysis_siso(Gtheta, [], 'CT uncompensated', 'theta (rad)', output_dir);
print_metrics('CT uncompensated', metrics_uncomp);

% Controller design (continuous-time)
target_bw = 5;
[C, info_c] = design_pid_controller(Gtheta, target_bw);

disp('Continuous-time PID controller:');
C

disp('PID tuning info:');
info_c

% Analysis after compensation
metrics_comp = analysis_siso(Gtheta, C, 'CT compensated', 'theta (rad)', output_dir);
print_metrics('CT compensated', metrics_comp);

% Discretization
Ts = 0.02;
sysd = c2d(sys, Ts, 'zoh');
Gd = c2d(Gtheta, Ts, 'zoh');

disp('Discrete-time state-space (ZOH):');
sysd

disp('Discrete-time transfer function (theta/F):');
Gd

% Controller design (discrete-time)
[Cd, info_d] = design_pid_controller(Gd, target_bw);

disp('Discrete-time PID controller:');
Cd

disp('PID tuning info:');
info_d

% Discrete analysis
metrics_uncomp_d = analysis_siso(Gd, [], 'DT uncompensated', 'theta (rad)', output_dir);
print_metrics('DT uncompensated', metrics_uncomp_d);

metrics_comp_d = analysis_siso(Gd, Cd, 'DT compensated', 'theta (rad)', output_dir);
print_metrics('DT compensated', metrics_comp_d);

% Comparison between continuous and discrete
Tc = feedback(C * Gtheta, 1);
Td = feedback(Cd * Gd, 1);
compare_continuous_discrete(Tc, Td, output_dir, Ts);
