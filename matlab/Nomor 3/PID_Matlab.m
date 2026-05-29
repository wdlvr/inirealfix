clear; clc; close all;

%% Load Fungsi Transfer
here = fileparts(mfilename('fullpath'));
model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'aircraft_pitch_tf.mat');
load(mat_path, 'G1');

s = tf('s');

%% Plant
G = G1;

disp('Plant transfer function:');
G

Kp = 24.3161;
Ki = 15.4352;
Kd = 9.5767;

%% PID Controller
C_PID = Kp + Ki/s + Kd*s;

disp('PID Controller hasil PID Tuner:');
C_PID

fprintf('Kp = %.6f\n', Kp);
fprintf('Ki = %.6f\n', Ki);
fprintf('Kd = %.6f\n', Kd);
G_comp = G * C_PID;
G_comp


%% Save hasil
save('aircraft_pitch_tf_PID_comp_Matlab.mat', 'G_comp');