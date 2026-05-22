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
margin(L);
grid on;
title([label ' - Bode Plot']);
saveas(fig, fullfile(output_dir, [tag '_bode.png']));

fig = figure('Name', [label ' - Nyquist']);
nyquist(L);
grid on;
title([label ' - Nyquist Plot']);
saveas(fig, fullfile(output_dir, [tag '_nyquist.png']));

T = feedback(L, 1);

fig = figure('Name', [label ' - Step']);
step(T);
grid on;
title([label ' - Closed-loop Step Response']);
xlabel('Time (s)');
ylabel(y_label);
legend(y_label, 'Location', 'best');
saveas(fig, fullfile(output_dir, [tag '_step.png']));

fig = figure('Name', [label ' - Impulse']);
impulse(T);
grid on;
title([label ' - Closed-loop Impulse Response']);
xlabel('Time (s)');
ylabel(y_label);
legend(y_label, 'Location', 'best');
saveas(fig, fullfile(output_dir, [tag '_impulse.png']));

info = stepinfo(T);
ess = abs(1 - dcgain(T));
[Gm, Pm, Wcg, Wcp] = margin(L);

metrics = struct( ...
    'label', label, ...
    'step_info', info, ...
    'steady_state_error', ess, ...
    'gain_margin', Gm, ...
    'phase_margin', Pm, ...
    'gain_cross_freq', Wcg, ...
    'phase_cross_freq', Wcp);
