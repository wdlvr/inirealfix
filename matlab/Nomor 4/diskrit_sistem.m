clear; clc; close all;

here = fileparts(mfilename('fullpath'));
model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'inverted_pendulum_tf.mat');
if exist(mat_path, 'file')
    load(mat_path, 'P_pend');
else
    load('inverted_pendulum_tf.mat');
end

Ts = 0.02;
G = P_pend;
Gd = c2d(G, Ts, 'zoh');

out_dir = fullfile(here, 'figures');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

disp('Discrete model (ZOH):');
Gd

fig = figure('Name', 'Root Locus - DT Uncompensated');
rlocus(Gd); grid on;
saveas(fig, fullfile(out_dir, 'root_locus_dt_uncomp.png'));

fig = figure('Name', 'Bode - DT Uncompensated');
margin(Gd); grid on;
saveas(fig, fullfile(out_dir, 'bode_dt_uncomp.png'));

fig = figure('Name', 'Nyquist - DT Uncompensated');
nyquist(Gd); grid on;
saveas(fig, fullfile(out_dir, 'nyquist_dt_uncomp.png'));

Td = feedback(Gd, 1);
stable_d = isstable(Td);

disp('Closed-loop stable (DT):');
stable_d

[Gm, Pm, Wcg, Wcp] = margin(Gd);
if isfinite(Gm)
    Gm_db = 20*log10(Gm);
else
    Gm_db = Inf;
end

if stable_d
    info = stepinfo(Td);
    ess = abs(1 - dcgain(Td));
else
    info = struct('RiseTime', NaN, 'SettlingTime', NaN, 'Overshoot', NaN, ...
        'Peak', NaN, 'PeakTime', NaN);
    ess = NaN;
end

fprintf('Steady-state error (DT): %.4g\n', ess);
fprintf('Rise time (DT): %.4g s\n', info.RiseTime);
fprintf('Settling time (DT): %.4g s\n', info.SettlingTime);
fprintf('Overshoot (DT): %.4g %%\n', info.Overshoot);
fprintf('Peak (DT): %.4g at %.4g s\n', info.Peak, info.PeakTime);
fprintf('Gain margin (DT): %.4g (%.4g dB)\n', Gm, Gm_db);
fprintf('Phase margin (DT): %.4g deg\n', Pm);
fprintf('Gain crossover (DT): %.4g rad/s\n', Wcg);
fprintf('Phase crossover (DT): %.4g rad/s\n', Wcp);

Tc = feedback(G, 1);
if isstable(Tc) && stable_d
    fig = figure('Name', 'Step CT vs DT');
    step(Tc, Td); grid on;
    legend('CT', 'DT', 'Location', 'best');
    saveas(fig, fullfile(out_dir, 'step_ct_vs_dt.png'));
else
    disp('Compare skipped (unstable).');
end
