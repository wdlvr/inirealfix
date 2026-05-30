% analisis_sistem.m
% Analisis open-loop dan closed-loop untuk Nomor 2 (kendali pitch pesawat).
% Penggunaan: Melakukan analisi root locus,
% Bode Plot, Nyquist, serta respons closed-loop (step, impulse, ramp, parabolik).
clear; clc; close all;

% Load model dari Nomor 1
here = fileparts(mfilename('fullpath'));
if isempty(here)
    p = which('analisis_sistem.m');
    if ~isempty(p)
        here = fileparts(p);
    else
        here = pwd;
    end
end

model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'aircraft_pitch_tf.mat');
if exist(mat_path, 'file')
    loaded = load(mat_path);
else
    loaded = load('aircraft_pitch_tf.mat');
end

if isfield(loaded, 'G1')
    G1 = loaded.G1;
elseif isfield(loaded, 'sys_tf')
    G1 = loaded.sys_tf;
elseif isfield(loaded, 'num') && isfield(loaded, 'den')
    G1 = tf(loaded.num, loaded.den);
else
    error('aircraft_pitch_tf.mat does not contain expected variables');
end

% Set nama input/output
G1.InputName = 'delta_e';
G1.OutputName = 'theta';
C = 1;
L = C*G1;
% Analisis open-loop untuk sistem tanpa kompensasi (Nomor 2).
disp('Open-loop transfer function L(s) = C(s)G1(s)');
disp('Uncompensated system: C(s) = 1');
L

disp('Open-loop poles:');
pole(L)

disp('Open-loop zeros:');
zero(L)

disp('Open-loop stable:');
isstable(L)

% Root locus, Bode, Nyquist untuk sistem uncompensated
figure('Name', 'Root Locus - Uncompensated');
rlocus(L); grid on;
title('Root Locus Sistem Uncompensated');

figure('Name', 'Bode Plot - Uncompensated');
margin(L); grid on;
title('Bode Plot Sistem Uncompensated');

[Gm, Pm, Wcg, Wcp] = margin(L);

if isfinite(Gm)
    Gm_db = 20*log10(Gm);
else
    Gm_db = Inf;
end

fprintf('\nStability Margins from Open-loop L(s):\n');
fprintf('Gain margin     : %.4g atau %.4g dB\n', Gm, Gm_db);
fprintf('Phase margin    : %.4g deg\n', Pm);
fprintf('Gain crossover  : %.4g rad/s\n', Wcg);
fprintf('Phase crossover : %.4g rad/s\n', Wcp);
figure('Name', 'Nyquist Plot - Uncompensated');
nyquist(L);
grid on;
title('Nyquist Plot Sistem Uncompensated');

T = feedback(L, 1);
T = minreal(T);

disp('Closed-loop uncompensated transfer function');
disp('T(s) = G1(s) / (1 + G1(s))');
T

disp('Poles Sistem Closed-loop:');
pole(T)

disp('Zeros Sistem Closed-loop:');
zero(T)
t = 0:0.001:50;

% Respons unit step
figure('Name', 'Respons Step - Uncompensated');
step(T, t); grid on;
title('Respons Closed-loop Step Uncompensated');
xlabel('Time (s)');
ylabel('Pitch Angle \\\theta (rad)');

if stable_cl
    info = stepinfo(T);
    ess = abs(1 - dcgain(T));

    fprintf('\nHasil Closed-loop Uncompensated:\n');
    fprintf('Steady-state error : %.4g\n', ess);
    fprintf('Rise time          : %.4g s\n', info.RiseTime);
    fprintf('Settling time      : %.4g s\n', info.SettlingTime);
    fprintf('Overshoot          : %.4g %%\n', info.Overshoot);
    fprintf('Peak               : %.4g\n', info.Peak);
    fprintf('Peak time          : %.4g s\n', info.PeakTime);
else
    fprintf('\nClosed-loop uncompensated system unstable. Step response metrics are not valid.\n');
    info = struct('RiseTime', NaN, 'SettlingTime', NaN, 'Overshoot', NaN, ...
        'Peak', NaN, 'PeakTime', NaN);
    ess = NaN;
end

save(fullfile(here, 'aircraft_pitch_uncompensated_tf.mat'), ...
     'G1', 'C', 'L', 'T');

save(fullfile(out_dir, 'analysis_metrics.mat'), ...
    'Gm', 'Pm', 'Wcg', 'Wcp', 'Gm_db', 'info', 'ess', 'stable_cl');

fprintf('Saved model to %s and metrics to %s\n', ...
    fullfile(here, 'aircraft_pitch_uncompensated_tf.mat'), ...
    fullfile(out_dir, 'analysis_metrics.mat'));

% Respons unit impuls
figure;
impulse(T, t);
grid on;
title('Respons Impuls Sistem Uncompensated');
xlabel('Time (s)');
ylabel('Pitch Angle \theta (rad)');

% Respons unit ramp
r_ramp = t;
[y_ramp, t_ramp] = lsim(T, r_ramp, t);

figure;
plot(t_ramp, r_ramp, '--'); hold on;
plot(t_ramp, y_ramp);
grid on;
title('Respons Ramp Sistem Uncompensated');
xlabel('Time (s)');
ylabel('Pitch Angle \theta (rad)');
legend('Input Ramp', 'Output');

% Respons parabolik
r_parabolic = 0.5*t.^2;
[y_para, t_para] = lsim(T, r_parabolic, t);

figure;
plot(t_para, r_parabolic, '--'); hold on;
plot(t_para, y_para);
grid on;
title('Respons Parabolik Sistem Uncompensated');
xlabel('Time (s)');
ylabel('Pitch Angle \theta (rad)');
legend('Input Parabolic', 'Output');