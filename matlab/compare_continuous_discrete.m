function compare_continuous_discrete(Tc, Td, output_dir, Ts)
%COMPARE_CONTINUOUS_DISCRETE Compare closed-loop continuous vs discrete.

if nargin < 3 || isempty(output_dir)
    output_dir = pwd;
end

if nargin < 4
    Ts = NaN;
end

tag = make_tag('compare');

fig = figure('Name', 'Step Comparison');
step(Tc, Td);
grid on;
if ~isnan(Ts)
    title(sprintf('Closed-loop Step Response (Ts = %.3f s)', Ts));
else
    title('Closed-loop Step Response');
end
xlabel('Time (s)');
ylabel('theta (rad)');
legend('Continuous', 'Discrete', 'Location', 'best');
saveas(fig, fullfile(output_dir, [tag '_step_compare.png']));

fig = figure('Name', 'Bode Comparison');
bode(Tc, Td);
grid on;
if ~isnan(Ts)
    title(sprintf('Closed-loop Bode Plot (Ts = %.3f s)', Ts));
else
    title('Closed-loop Bode Plot');
end
legend('Continuous', 'Discrete', 'Location', 'best');
saveas(fig, fullfile(output_dir, [tag '_bode_compare.png']));
