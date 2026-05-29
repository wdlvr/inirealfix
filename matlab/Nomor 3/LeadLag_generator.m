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
percent_overshoot = 0.04;     % percent overshoot
settling_time = 0.8;          % settling time dalam detik
zero_lead     = 3;            % nilai a pada (s+a)/(s+b) lead comp, pilih dikiri pole dominan
pole_lag      = 0.01;         % nilai d pada (s+c)/(s+d) lag comp, pilih dekat nol

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
G_pole_dominan = evalfr(G1*(s+zero_lead), pole_dominan);

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
fprintf('Sudut kompensasi dibutuhkan dari Pc= %.6f deg\n', -sudut_kompensasi);

Pc = wd/tan(deg2rad(sudut_kompensasi)) + sigma_d;

%% Lead
G_comp = G1*(s+zero_lead)/(s+Pc);
G_comp_pole_dominan = evalfr(G_comp, pole_dominan);
K_comp_Lead = -1/G_comp_pole_dominan;

%% Lag
zero_lag = 0.1;   % cari dari ess yang diinginkan
G_comp = G_comp * (s+zero_lag)/(s+pole_lag);
G_comp_pole_dominan = evalfr(G_comp, pole_dominan);
K_comp_LeadLag = -1/G_comp_pole_dominan;
G_comp = G_comp * real(K_comp_LeadLag);

fprintf('\nNilai kompensasi Lead dan Lead-Lag:\n');
fprintf('Zero dan Pole kompensasi pada s = %.6f dan s = %.6f\n', -zero_lead, -Pc);
fprintf('K_comp_Lead = %.6f\n', K_comp_Lead);
fprintf('Fungsi transfer Lead: %.6f(s + %.6f)/(s + %.6f)\n', K_comp_Lead, zero_lead, Pc);
fprintf('K_comp_LeadLag = %.6f\n', K_comp_LeadLag);
fprintf('Fungsi transfer PID: %.6f(s + %.6f)/(s + %.6f) . (s + %.6f)/(s + %.6f)\n', K_comp_LeadLag, zero_lead, Pc, zero_lag, pole_lag);
G_comp

save('aircraft_pitch_tf_LeadLag_comp.mat', 'G_comp');