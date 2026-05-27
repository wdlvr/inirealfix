function metrics = analysis_siso(G, C, label, y_label, output_dir)
%ANALYSIS_SISO Generate plots and metrics for a SISO loop.

if nargin < 2 || isempty(C)
    L = G;
else
    L = C * G;
end

if nargin < 4 || isempty(y_label)
    y_label = 'Output';
end

if nargin < 5 || isempty(output_dir)
    output_dir = pwd;
end

tag = make_tag(label);

fig = figure('Name', [label ' - Root Locus']);
rlocus(L);
grid on;
title([label ' - Root Locus']);
saveas(fig, fullfile(output_dir, [tag '_root_locus.png']));

fig = figure('Name', [label ' - Bode']);
warn_state = warning('off', 'all');
margin(L);
warning(warn_state);
grid on;
title([label ' - Bode Plot']);
saveas(fig, fullfile(output_dir, [tag '_bode.png']));

fig = figure('Name', [label ' - Nyquist']);
nyquist(L);
grid on;
title([label ' - Nyquist Plot']);
saveas(fig, fullfile(output_dir, [tag '_nyquist.png']));

T = feedback(L, 1);
T_plot = minreal(T, 1e-6);
is_stable = isstable(T_plot);

fig = figure('Name', [label ' - Step']);
step(T_plot);
grid on;
title([label ' - Closed-loop Step Response']);
xlabel('Time (s)');
ylabel(y_label);
legend(y_label, 'Location', 'best');
saveas(fig, fullfile(output_dir, [tag '_step.png']));

fig = figure('Name', [label ' - Impulse']);
impulse(T_plot);
grid on;
title([label ' - Closed-loop Impulse Response']);
xlabel('Time (s)');
ylabel(y_label);
legend(y_label, 'Location', 'best');
saveas(fig, fullfile(output_dir, [tag '_impulse.png']));

if is_stable
    info = stepinfo(T_plot);
    ess = abs(1 - dcgain(T_plot));
else
    info = struct('RiseTime', NaN, 'SettlingTime', NaN, 'Overshoot', NaN, ...
        'Peak', NaN, 'PeakTime', NaN);
    ess = NaN;
end
warn_state = warning('off', 'all');
[Gm, Pm, Wcg, Wcp] = margin(L);
warning(warn_state);

metrics = struct( ...
    'label', label, ...
    'step_info', info, ...
    'steady_state_error', ess, ...
    'closed_loop_stable', is_stable, ...
    'gain_margin', Gm, ...
    'phase_margin', Pm, ...
    'gain_cross_freq', Wcg, ...
    'phase_cross_freq', Wcp);
