% analisis_sistem_short.m
% Versi ringkas dari analisis_sistem.m — sama analisis, tidak menyimpan PNG
clear; clc; close all;

% Temukan folder skrip
here = fileparts(mfilename('fullpath'));
if isempty(here)
    p = which('analisis_sistem_short.m');
    if ~isempty(p)
        here = fileparts(p);
    else
        here = pwd;
    end
end

% Muat model dari Nomor 1
mat_path = fullfile(here, '..', 'Nomor 1', 'aircraft_pitch_tf.mat');
if exist(mat_path, 'file')
    S = load(mat_path);
else
    S = load('aircraft_pitch_tf.mat');
end

if isfield(S, 'G1')
    G1 = S.G1;
elseif isfield(S, 'sys_tf')
    G1 = S.sys_tf;
elseif isfield(S, 'num') && isfield(S, 'den')
    G1 = tf(S.num, S.den);
else
    error('aircraft_pitch_tf.mat does not contain expected variables');
end

G1.InputName = 'delta_e'; G1.OutputName = 'theta';
C = 1; L = C*G1;

disp('Open-loop L(s):'); disp(L)
disp('Open-loop poles:'); disp(pole(L))
disp('Open-loop zeros:'); disp(zero(L))
fprintf('Is stable (open-loop): %d\n', isstable(L));

% Plots (ditampilkan, tidak disimpan)
figure; rlocus(L); grid on; title('Root Locus - Uncompensated');
figure; margin(L); grid on; title('Bode / Gain & Phase Margin');
[Gm, Pm, Wcg, Wcp] = margin(L);
if isfinite(Gm)
    Gm_db = 20*log10(Gm);
else
    Gm_db = Inf;
end
fprintf('Gm=%.4g (%.4g dB), Pm=%.4g deg, Wcg=%.4g, Wcp=%.4g\n', Gm, Gm_db, Pm, Wcg, Wcp);
figure; nyquist(L); grid on; title('Nyquist - Uncompensated');

T = minreal(feedback(L, 1));
disp('Closed-loop T(s):'); disp(T)
disp('Closed-loop poles:'); disp(pole(T))
disp('Closed-loop zeros:'); disp(zero(T))
stable_cl = isstable(T);
fprintf('Is stable (closed-loop): %d\n', stable_cl);

t = 0:0.01:50;
figure; step(T, t); grid on; title('Closed-loop Step Response');
if stable_cl
    info = stepinfo(T);
    ess = abs(1 - dcgain(T));
    fprintf('Steady-state error = %.4g\nRise time = %.4g s\nSettling time = %.4g s\nOvershoot = %.4g %%\n', ...
        ess, info.RiseTime, info.SettlingTime, info.Overshoot);
else
    warning('Closed-loop unstable — step metrics not available');
    info = struct('RiseTime', NaN, 'SettlingTime', NaN, 'Overshoot', NaN);
    ess = NaN;
end

% Respons tambahan (hanya plot)
figure; impulse(T, t); grid on; title('Impulse Response');
ramp = t; [y_r, t_r] = lsim(T, ramp, t);
figure; plot(t_r, ramp, '--', t_r, y_r); grid on; title('Ramp Response'); legend('Input','Output');
parab = 0.5*t.^2; [y_p, t_p] = lsim(T, parab, t);
figure; plot(t_p, parab, '--', t_p, y_p); grid on; title('Parabolic Response'); legend('Input','Output');
