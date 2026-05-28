clear; clc; close all;

%% Aircraft Pitch Control System
% Input  : delta_e = elevator deflection angle
% Output : theta   = pitch angle

s = tf('s');

G1 = (1.151*s + 0.1774) / (s^3 + 0.739*s^2 + 0.921*s);

G1.InputName = 'delta_e';
G1.OutputName = 'theta';

%% Output folder
here = fileparts(mfilename('fullpath'));
out_dir = fullfile(here, 'figures');

if ~exist(out_dir, 'dir')
    mkdir(out_dir);
end

%% Uncompensated system
% Sebelum kompensasi berarti C(s) = 1
C = 1;

%% Open-loop transfer function
L = C*G1;

disp('====================================');
disp('Open-loop transfer function L(s) = C(s)G1(s)');
disp('Uncompensated system: C(s) = 1');
disp('====================================');
L

disp('Open-loop poles:');
pole(L)

disp('Open-loop zeros:');
zero(L)

disp('Open-loop stable:');
isstable(L)

%% Root Locus
fig = figure('Name', 'Root Locus - Uncompensated');
rlocus(L);
grid on;
title('Root Locus of Uncompensated Aircraft Pitch System');
saveas(fig, fullfile(out_dir, 'root_locus_uncompensated.png'));

%% Bode Plot and Stability Margins
fig = figure('Name', 'Bode Plot - Uncompensated');
margin(L);
grid on;
title('Bode Plot of Uncompensated Aircraft Pitch System');
saveas(fig, fullfile(out_dir, 'bode_uncompensated.png'));

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

%% Nyquist Plot
fig = figure('Name', 'Nyquist Plot - Uncompensated');
nyquist(L);
grid on;
title('Nyquist Plot of Uncompensated Aircraft Pitch System');
saveas(fig, fullfile(out_dir, 'nyquist_uncompensated.png'));

%% Closed-loop uncompensated system
% Unity feedback tanpa controller tambahan
T = feedback(L, 1);
T = minreal(T);

disp('====================================');
disp('Closed-loop uncompensated transfer function');
disp('T(s) = G1(s) / (1 + G1(s))');
disp('====================================');
T

disp('Closed-loop poles:');
pole(T)

disp('Closed-loop zeros:');
zero(T)

disp('Closed-loop stable:');
stable_cl = isstable(T)

%% Step Response
t = 0:0.001:50;

fig = figure('Name', 'Step Response - Uncompensated');
step(T, t);
grid on;
title('Closed-loop Step Response of Uncompensated Aircraft Pitch System');
xlabel('Time (s)');
ylabel('Pitch Angle \theta (rad)');
saveas(fig, fullfile(out_dir, 'step_uncompensated.png'));

%% Performance Evaluation
if stable_cl
    info = stepinfo(T);
    ess = abs(1 - dcgain(T));

    fprintf('\nClosed-loop Uncompensated Performance:\n');
    fprintf('Steady-state error : %.4g\n', ess);
    fprintf('Rise time          : %.4g s\n', info.RiseTime);
    fprintf('Settling time      : %.4g s\n', info.SettlingTime);
    fprintf('Overshoot          : %.4g %%\n', info.Overshoot);
    fprintf('Peak               : %.4g\n', info.Peak);
    fprintf('Peak time          : %.4g s\n', info.PeakTime);
else
    fprintf('\nClosed-loop uncompensated system is unstable. Step response metrics are not valid.\n');
end

%% Save model
save('aircraft_pitch_uncompensated_tf.mat', ...
     'G1', 'C', 'L', 'T');