% Nama / NIM : 
% Rafi Ihsan Alfathin     / 13223018
% Maghryza Milchan Fayumi / 13223036
% William Anthony         / 13223048
%% Deskripsi: PD generator menggunakan matematika dari buku Nise,
%% dari Ts dan %OS akan otomatis digenerasikan kompensasi PID yang dibutuhkan
clear; clc; close all;

% Load plant terkompensasi yang ingin dianalisis
here = fileparts(mfilename('fullpath'));
model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'aircraft_pitch_tf.mat');
load(mat_path, 'G1');
s = tf('s');

% Parameter Desain (Nilai sebenarnya akan berbeda karena ini asumsi
% pendekatan orde 2, oleh karena itu desain parameternya berbeda dengan
% spesifikasi asli, ini adalah hasil akhir dari iterasi beberapa kali)
percent_overshoot = 0.01;     % percent overshoot dalam persen
settling_time = 0.85;          % settling time dalam detik

% Kalkulasi nilai zeta
OS = percent_overshoot / 100;
zeta = -log(OS) / sqrt(pi^2 + (log(OS))^2);


% Kalkulasi pole yang diinginkan (dominan)
sigma_d = 4 / settling_time;
wn = sigma_d / zeta;
wd = wn * sqrt(1 - zeta^2);
pole_dominan = -sigma_d + 1i*wd;

% Tampilkan parameter yang didapat
fprintf('Parameter Desain:\n');
fprintf('Percent Overshoot = %.4f %%\n', percent_overshoot);
fprintf('Settling Time     = %.4f s\n\n', settling_time);

fprintf('Parameter Didapat:\n');
fprintf('zeta              = %.6f\n', zeta);
fprintf('sigma_d           = %.6f\n', sigma_d);
fprintf('wn                = %.6f rad/s\n', wn);
fprintf('wd                = %.6f rad/s\n', wd);
fprintf('dominant pole     = %.6f %+.6fj\n', real(pole_dominan), imag(pole_dominan));

%% Kalkulasi sudut kompensasi yang dibutuhkan
% Substitusi pole dominan ke open-loop plant G1(s)
G_pole_dominan = evalfr(G1, pole_dominan);

% Sudut G1(s) pada pole dominan
sudut_G_rad = angle(G_pole_dominan);
sudut_G_deg = rad2deg(sudut_G_rad);

% Ubah ke rentang 0 sampai 360 derajat
if sudut_G_deg < 180 && sudut_G_deg > 0
    sudut_kompensasi = 180 - sudut_G_deg;
elseif sudut_G_deg < 0
    sudut_kompensasi = 180 + sudut_G_deg;
end

% Tampilkan sudut kompensasi yang dibutuhkan
fprintf('\nAngle Calculation:\n');
fprintf('Nilai fungsi transfer pada pole dominan = %.6f %+.6fj\n', real(G_pole_dominan), imag(G_pole_dominan));
fprintf('Sudut kompensasi dibutuhkan  = %.6f deg\n', sudut_kompensasi);

% Nilai zero kompensasi PD
Zc = wd/tan(deg2rad(sudut_kompensasi)) + sigma_d;

%% Kompensasi PD
G_comp = G1*(s+Zc);
G_comp_pole_dominan = evalfr(G_comp, pole_dominan);
K_comp = -1/G_comp_pole_dominan;
K_comp_real = real(K_comp);
G_comp = K_comp_real*G_comp;

% Tampilkan hasil kompensasi yang didapat
fprintf('\nNilai kompensasi PD:\n');
fprintf('Zero kompensasi pada s = %.6f\n', -Zc);
fprintf('K_comp = %.6f\n', K_comp);
fprintf('Kp = %.6f\n', K_comp*Zc);
fprintf('Kd = %.6f\n', K_comp);
fprintf('Fungsi transfer PD: %.6f(s + %.6f)\n', K_comp, Zc);
fprintf('Fungsi transfer setelah kompensasi: \n');
G_comp

% Simpan file .mat nya
save('aircraft_pitch_tf_PD_comp.mat', 'G_comp');