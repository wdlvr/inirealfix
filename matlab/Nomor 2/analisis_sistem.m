clear; clc; close all;

% Referensi wlmoi:
% 1) CTMS Inverted Pendulum (single pendulum model)
%    https://ctms.engin.umich.edu/CTMS/index.php?example=InvertedPendulum&section=SystemModeling
% 2) MIT OCW 2.004 PS10 (stability + performance metrics workflow)
%    https://ocw.mit.edu/courses/2-004-systems-modeling-and-control-ii-fall-2007/a4390e1ba19c0b986fcd24f15e3b7420_ps10.pdf
% 3) MIT OCW 2.04A Lecture 18 (frequency response + margins)
%    https://ocw.mit.edu/courses/2-04a-systems-and-controls-spring-2013/cec516593e76ea28d76655ab3b64f472_MIT2_04AS13_Lecture18.pdf

here = fileparts(mfilename('fullpath'));
model_dir = fullfile(here, '..', 'Nomor 1');
mat_path = fullfile(model_dir, 'inverted_pendulum_tf.mat');
if exist(mat_path, 'file')
    load(mat_path, 'P_pend');
else
    load('inverted_pendulum_tf.mat');
end

G = P_pend;

out_dir = fullfile(here, 'figures');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

disp('Open-loop poles:');
pole(G)

disp('Open-loop stable:');
isstable(G)

fig = figure('Name', 'Root Locus - Uncompensated');
rlocus(G); grid on;
saveas(fig, fullfile(out_dir, 'root_locus_uncomp.png'));

fig = figure('Name', 'Bode - Uncompensated');
margin(G); grid on;
saveas(fig, fullfile(out_dir, 'bode_uncomp.png'));

fig = figure('Name', 'Nyquist - Uncompensated');
nyquist(G); grid on;
saveas(fig, fullfile(out_dir, 'nyquist_uncomp.png'));

T = feedback(G, 1);
stable_cl = isstable(T);

disp('Closed-loop stable:');
stable_cl

[Gm, Pm, Wcg, Wcp] = margin(G);
if isfinite(Gm)
    Gm_db = 20*log10(Gm);
else
    Gm_db = Inf;
end

if stable_cl
    info = stepinfo(T);
    ess = abs(1 - dcgain(T));
else
    info = struct('RiseTime', NaN, 'SettlingTime', NaN, 'Overshoot', NaN, ...
        'Peak', NaN, 'PeakTime', NaN);
    ess = NaN;
end

fprintf('Steady-state error: %.4g\n', ess);
fprintf('Rise time: %.4g s\n', info.RiseTime);
fprintf('Settling time: %.4g s\n', info.SettlingTime);
fprintf('Overshoot: %.4g %%\n', info.Overshoot);
fprintf('Peak: %.4g at %.4g s\n', info.Peak, info.PeakTime);
fprintf('Gain margin: %.4g (%.4g dB)\n', Gm, Gm_db);
fprintf('Phase margin: %.4g deg\n', Pm);
fprintf('Gain crossover: %.4g rad/s\n', Wcg);
fprintf('Phase crossover: %.4g rad/s\n', Wcp);

t = 0:0.01:2;

[y_step, t_step] = step(T, t);
[y_imp, t_imp] = impulse(T, t);

phi_step = rad2deg(y_step);
phi_imp = rad2deg(y_imp);

phi_step = mod(phi_step + 180, 360) - 180;
phi_imp = mod(phi_imp + 180, 360) - 180;

fig = figure('Name', 'Step - Uncompensated (deg)');
plot(t_step, phi_step); grid on; hold on;
plot([t_step(1) t_step(end)], [0 0], 'k--');
hold off;
ylim([-180 180]);
xlabel('Time (s)');
ylabel('phi (deg)');
saveas(fig, fullfile(out_dir, 'step_uncomp.png'));

fig = figure('Name', 'Impulse - Uncompensated (deg)');
plot(t_imp, phi_imp); grid on; hold on;
plot([t_imp(1) t_imp(end)], [0 0], 'k--');
hold off;
ylim([-180 180]);
xlabel('Time (s)');
ylabel('phi (deg)');
saveas(fig, fullfile(out_dir, 'impulse_uncomp.png'));

if ~stable_cl
    disp('Closed-loop unstable, responses may diverge.');
end
