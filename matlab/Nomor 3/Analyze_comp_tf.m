clear; clc; close all;

load('aircraft_pitch_tf_LeadLag_comp.mat', 'G_comp');
L = G_comp;

disp('Open-loop transfer function L(s) = G_comp(s)');
L

disp('Open-loop poles:');
pole(L)

disp('Open-loop zeros:');
zero(L)

disp('Open-loop stable:');
isstable(L)

fig = figure('Name', 'Root Locus - compensated');
rlocus(L); grid on;
title('Root Locus of compensated Aircraft Pitch System');

fig = figure('Name', 'Bode Plot - compensated');
margin(L); grid on;
title('Bode Plot of compensated Aircraft Pitch System');

[Gm, Pm, Wcg, Wcp] = margin(L);

if isfinite(Gm)
    Gm_db = 20*log(Gm);
else
    Gm_db = Inf;
end

fprintf('\nStability Margins from Open-loop L(s):\n');
fprintf('Gain margin     : %.4g atau %.4g dB\n', Gm, Gm_db);
fprintf('Phase margin    : %.4g deg\n', Pm);
fprintf('Gain crossover  : %.4g rad/s\n', Wcg);
fprintf('Phase crossover : %.4g rad/s\n', Wcp);
fig = figure('Name', 'Nyquist Plot - compensated');
nyquist(L);
grid on;
title('Nyquist Plot of compensated Aircraft Pitch System');

T = feedback(L, 1);
T = minreal(T);

disp('Closed-loop compensated transfer function');
disp('T(s) = G_comp(s) / (1 + G_comp(s))');
T

disp('Closed-loop poles:');
pole(T)

disp('Closed-loop zeros:');
zero(T)

stable_cl = isstable(T);

t = 0:0.001:50;

fig = figure('Name', 'Step Response - compensated');
step(T, t); grid on;
title('Closed-loop Step Response of compensated Aircraft Pitch System');
xlabel('Time (s)');
ylabel('Pitch Angle \\\theta (rad)');

if stable_cl
    info = stepinfo(T);
    ess = abs(1 - dcgain(T));

    fprintf('\nClosed-loop compensated Performance:\n');
    fprintf('Steady-state error : %.4g\n', ess);
    fprintf('Rise time          : %.4g s\n', info.RiseTime);
    fprintf('Settling time      : %.4g s\n', info.SettlingTime);
    fprintf('Overshoot          : %.4g %%\n', info.Overshoot);
    fprintf('Peak               : %.4g\n', info.Peak);
    fprintf('Peak time          : %.4g s\n', info.PeakTime);
else
    fprintf('\nClosed-loop compensated system is unstable. Step response metrics are not valid.\n');
    info = struct('RiseTime', NaN, 'SettlingTime', NaN, 'Overshoot', NaN, ...
        'Peak', NaN, 'PeakTime', NaN);
    ess = NaN;
end