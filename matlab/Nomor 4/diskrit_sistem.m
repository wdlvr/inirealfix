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

t = 0:Ts:1;
phi_stable = deg2rad(180);

[y_step, t_step] = step(Td, t);
[y_imp, t_imp] = impulse(Td, t);

phi_step = y_step;
phi_imp = y_imp;

phi_step_wrap = mod(phi_step + pi, 2*pi) - pi;
phi_imp_wrap = mod(phi_imp + pi, 2*pi) - pi;

fall_step_idx = find(abs(phi_step) >= phi_stable, 1, 'first');
if ~isempty(fall_step_idx)
    a_step = phi_step(fall_step_idx);
    t_fall_step = t_step(fall_step_idx);
    a_step_wrap = mod(a_step + pi, 2*pi) - pi;
    fprintf('Unstable at t = %.4g s (DT step)\n', t_fall_step);
else
    a_step_wrap = [];
    t_fall_step = [];
    fprintf('Unstable not reached (DT step)\n');
end

fall_imp_idx = find(abs(phi_imp) >= phi_stable, 1, 'first');
if ~isempty(fall_imp_idx)
    a_imp = phi_imp(fall_imp_idx);
    t_fall_imp = t_imp(fall_imp_idx);
    a_imp_wrap = mod(a_imp + pi, 2*pi) - pi;
    fprintf('Unstable at t = %.4g s (DT impulse)\n', t_fall_imp);
else
    a_imp_wrap = [];
    t_fall_imp = [];
    fprintf('Unstable not reached (DT impulse)\n');
end

fig = figure('Name', 'Step - DT Uncompensated (rad)');
plot(t_step, phi_step_wrap); grid on; hold on;
plot([t_step(1) t_step(end)], [0 0], 'k--');
plot([t_step(1) t_step(end)], [pi pi], 'b--');
plot([t_step(1) t_step(end)], [-pi -pi], 'b--');
plot([t_step(1) t_step(end)], [phi_stable phi_stable], 'm--');
plot([t_step(1) t_step(end)], [-phi_stable -phi_stable], 'm--');
if ~isempty(t_fall_step)
    plot(t_fall_step, a_step_wrap, 'ro');
end
hold off;
ylim([-pi pi]);
xlabel('Time (s)');
ylabel('phi (rad)');
saveas(fig, fullfile(out_dir, 'step_dt_uncomp.png'));

fig = figure('Name', 'Impulse - DT Uncompensated (rad)');
plot(t_imp, phi_imp_wrap); grid on; hold on;
plot([t_imp(1) t_imp(end)], [0 0], 'k--');
plot([t_imp(1) t_imp(end)], [pi pi], 'b--');
plot([t_imp(1) t_imp(end)], [-pi -pi], 'b--');
plot([t_imp(1) t_imp(end)], [phi_stable phi_stable], 'm--');
plot([t_imp(1) t_imp(end)], [-phi_stable -phi_stable], 'm--');
if ~isempty(t_fall_imp)
    plot(t_fall_imp, a_imp_wrap, 'ro');
end
hold off;
ylim([-pi pi]);
xlabel('Time (s)');
ylabel('phi (rad)');
saveas(fig, fullfile(out_dir, 'impulse_dt_uncomp.png'));

if ~stable_d
    disp('Closed-loop unstable, responses may diverge.');
end

Tc = feedback(G, 1);
if isstable(Tc) && stable_d
    fig = figure('Name', 'Step CT vs DT');
    step(Tc, Td); grid on;
    legend('CT', 'DT', 'Location', 'best');
    saveas(fig, fullfile(out_dir, 'step_ct_vs_dt.png'));
else
    disp('Compare skipped (unstable).');
end
