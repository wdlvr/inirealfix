% Nama / NIM : 
% Rafi Ihsan Alfathin     / 13223018
% Maghryza Milchan Fayumi / 13223036
% William Anthony         / 13223048
%% Deskripsi: PID generator menggunakan PID Tuner bawaan MATLAB,
%% nilai Kp, Ki, dan Kd didapat dari tuning dari MATLAB, ini hanya sebagai komparasi saja
%% bukan PID yang akan digunakan
clear; clc; close all;

% Load plant terkompensasi yang ingin dianalisis
here = fileparts(mfilename('fullpath'));
model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'aircraft_pitch_tf.mat');
load(mat_path, 'G1');
s = tf('s');

% Tampilkan fungsi transfer
disp('Plant transfer function:');
G1

% Nilai Kp, Ki, dan Kd yang didapat dari tuning pada PID Tuner
Kp = 24.3161;
Ki = 15.4352;
Kd = 9.5767;

% Fungsi transfer kontroler PID
C = Kp + Ki/s + Kd*s;

% Tampilkan fungsi transfer C(s)
disp('PID Controller hasil PID Tuner:');
C

% Tampilkan nilai Kp, Ki, dan Kd
fprintf('Kp = %.6f\n', Kp);
fprintf('Ki = %.6f\n', Ki);
fprintf('Kd = %.6f\n', Kd);

% Buat fungsi transfer plant terkompensasi
G_comp = G1 * C;
G_comp


% Simpan file .mat nya
save('aircraft_pitch_tf_PID_comp_Matlab.mat', 'G_comp');