clear; clc; close all;

here = fileparts(mfilename('fullpath'));
if isempty(here)
    p = which('diskrit_sistem_comp.m');
    if ~isempty(p)
        here = fileparts(p);
    else
        here = pwd;
    end
end

model_dir = fullfile(here, '..', 'Nomor 3');
mat_path = fullfile(model_dir, 'aircraft_pitch_tf_PID_comp.mat');
if exist(mat_path, 'file')
    loaded = load(mat_path);
else
    abs_path = 'D:\LinkedinProjects\TubesSisken\inirealfix\matlab\Nomor 3\aircraft_pitch_tf_PID_comp.mat';
    if exist(abs_path, 'file')
        loaded = load(abs_path);
    else
        error('MAT-file not found: %s', mat_path);
    end
end

% Try to locate the compensated model variable
if isfield(loaded, 'G_comp')
    Gc = loaded.G_comp;
elseif isfield(loaded, 'G')
    Gc = loaded.G;
elseif isfield(loaded, 'Gc')
    Gc = loaded.Gc;
else
    vars = fieldnames(loaded);
    if ~isempty(vars)
        Gc = loaded.(vars{1});
        warning('Using variable %s from MAT-file as the compensated model', vars{1});
    else
        error('No usable variables found inside the MAT-file.');
    end
% Determine a recommended sampling period Ts automatically.
% Rule of thumb: sample at ~10x the system bandwidth (crossover freq).
oversampling = 10; % adjust to 10-20 for better fidelity

% Try to estimate a characteristic frequency (rad/s): prefer gain crossover.
[~,~,Wcg_ct,~] = margin(Gc);
w_est = Wcg_ct;
if isempty(w_est) || ~isfinite(w_est) || w_est <= 0
    % fallback: try 3-dB bandwidth
    try
        w_bw = bandwidth(Gc); % rad/s
    catch
        w_bw = [];
    end
    if isempty(w_bw) || ~isfinite(w_bw) || w_bw <= 0
        % last-resort: estimate from dominant pole
        p = pole(Gc);
        if ~isempty(p)
            w_bw = max(abs(real(p)));
            if w_bw <= 0
                w_bw = 1; % fallback numeric value
            end
        else
            w_bw = 1;
        end
    end
    w_est = w_bw;
end

fc = w_est/(2*pi); % estimated continuous bandwidth in Hz
if fc <= 0 || ~isfinite(fc)
    Ts = 0.02; % conservative default
    warning('Unable to estimate system bandwidth; using default Ts = %g s', Ts);
else
    Ts = 1/(oversampling * fc);
end

% Suggest a recommended range for Ts (between 8x and 20x oversampling)
if isfinite(fc) && fc > 0
    Ts_range_fast = 1/(20 * fc);
    Ts_range_slow = 1/(8 * fc);
    fprintf('Estimated fc = %.4g Hz (omega = %.4g rad/s).\n', fc, w_est);
    fprintf('Recommended Ts = %.6g s (oversampling = %d). Range: [%.6g, %.6g] s\n', Ts, oversampling, Ts_range_fast, Ts_range_slow);
else
    fprintf('Using default Ts = %.6g s\n', Ts);
end

Gd = c2d(Gc, Ts, 'zoh');

out_dir = fullfile(here, 'figures');
if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

disp('Discrete compensated model (ZOH):');
Gd

% Root locus, Bode/Margin, Nyquist
fig = figure('Name', 'Root Locus - DT Compensated');
rlocus(Gd); grid on;
saveas(fig, fullfile(out_dir, 'root_locus_dt_comp.png'));

fig = figure('Name', 'Bode/Margin - DT Compensated');
margin(Gd); grid on;
saveas(fig, fullfile(out_dir, 'bode_dt_comp.png'));

fig = figure('Name', 'Nyquist - DT Compensated');
nyquist(Gd); grid on;
saveas(fig, fullfile(out_dir, 'nyquist_dt_comp.png'));

% Closed-loop (unity feedback) and stability
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

% Time responses
t = 0:Ts:5;
fig = figure('Name', 'Step - DT Compensated');
step(Td, t); grid on;
xlabel('Time (s)'); ylabel('Output');
saveas(fig, fullfile(out_dir, 'step_dt_comp.png'));

fig = figure('Name', 'Impulse - DT Compensated');
impulse(Td, t); grid on;
xlabel('Time (s)'); ylabel('Output');
saveas(fig, fullfile(out_dir, 'impulse_dt_comp.png'));

if ~stable_d
    disp('Closed-loop unstable (DT), responses may diverge.');
end

% Compare with continuous-time closed-loop if available
Tc = feedback(Gc, 1);
if isstable(Tc) && stable_d
    fig = figure('Name', 'Step CT vs DT - Compensated');
    step(Tc, Td); grid on;
    legend('CT', 'DT', 'Location', 'best');
    saveas(fig, fullfile(out_dir, 'step_ct_vs_dt_comp.png'));
else
    disp('Compare skipped (unstable).');
end

% Save analysis data for later comparison
save(fullfile(out_dir, 'dt_comp_analysis.mat'), 'Gc', 'Gd', 'Tc', 'Td', 'Gm', 'Pm', 'Wcg', 'Wcp');

disp('Diskritisasi dan analisis selesai.');
