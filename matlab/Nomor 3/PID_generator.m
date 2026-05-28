clear; clc; close all;

%% Load Fungsi Transfer
here = fileparts(mfilename('fullpath'));
model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'aircraft_pitch_tf.mat');
load(mat_path, 'G1');

%% Output folder
here = fileparts(mfilename('fullpath'));
out_dir = fullfile(here, 'figures');

if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

s = tf('s');

%% Design Parameters
percent_overshoot = 10;     % percent overshoot dalam persen
settling_time = 2;          % settling time dalam detik
zero_Ki = 0.1;                % Nilai z pada (s+z)/s untuk pengendali I

%% Calculate damping ratio zeta
OS = percent_overshoot / 100;

zeta = -log(OS) / sqrt(pi^2 + (log(OS))^2);


%% Calculate desired pole location
sigma_d = 4 / settling_time;

wn = sigma_d / zeta;

wd = wn * sqrt(1 - zeta^2);

pole_dominan = -sigma_d + 1i*wd;

%% Display results
fprintf('Parameter Desain:\n');
fprintf('Percent Overshoot = %.4f %%\n', percent_overshoot);
fprintf('Settling Time     = %.4f s\n\n', settling_time);

fprintf('Parameter Didapat:\n');
fprintf('zeta              = %.6f\n', zeta);
fprintf('sigma_d           = %.6f\n', sigma_d);
fprintf('wn                = %.6f rad/s\n', wn);
fprintf('wd                = %.6f rad/s\n', wd);
fprintf('dominant pole     = %.6f %+.6fj\n', real(pole_dominan), imag(pole_dominan));

%% Calculate angle deficiency / compensation angle

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

%% Display angle results
fprintf('\nAngle Calculation:\n');
fprintf('Nilai fungsi transfer pada pole dominan = %.6f %+.6fj\n', real(G_pole_dominan), imag(G_pole_dominan));
fprintf('Sudut kompensasi dibutuhkan  = %.6f deg\n', sudut_kompensasi);

Zc = wd/tan(deg2rad(sudut_kompensasi)) + sigma_d;

%% PD
G_comp = G1*(s+Zc);
G_comp_pole_dominan = evalfr(G_comp, pole_dominan);
K_comp_PD = -1/G_comp_pole_dominan;

%% PID
G_comp = G_comp * (s+zero_Ki)/s;
G_comp_pole_dominan = evalfr(G_comp, pole_dominan);
K_comp_PID = -1/G_comp_pole_dominan;
G_comp = G_comp * real(K_comp_PID);


fprintf('\nNilai kompensasi PD dan PID:\n');
fprintf('Zero kompensasi pada s = %.6f\n', -Zc);
fprintf('K_comp_PD = %.6f\n', K_comp_PD);
fprintf('Fungsi transfer PD: %.6f(s + %.6f)\n', K_comp_PD, Zc);
fprintf('K_comp_PID = %.6f\n', K_comp_PID);
fprintf('Fungsi transfer PID: %.6f(s + %.6f)(s + %.6f)/s\n', K_comp_PD, Zc, zero_Ki);
G_comp

save('aircraft_pitch_tf_PID_comp.mat', 'G_comp');