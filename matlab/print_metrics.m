function print_metrics(label, metrics)
%PRINT_METRICS Print step and stability metrics.

info = metrics.step_info;

fprintf('\n%s\n', label);
fprintf('Closed-loop stable: %s\n', logical_to_text(metrics.closed_loop_stable));

if metrics.closed_loop_stable
    fprintf('Steady-state error: %.6f\n', metrics.steady_state_error);
    fprintf('Rise time: %.4f s\n', info.RiseTime);
    fprintf('Settling time: %.4f s\n', info.SettlingTime);
    fprintf('Overshoot: %.2f %%\n', info.Overshoot);
    fprintf('Peak: %.4f at %.4f s\n', info.Peak, info.PeakTime);
else
    fprintf('Steady-state error: N/A\n');
    fprintf('Rise time: N/A\n');
    fprintf('Settling time: N/A\n');
    fprintf('Overshoot: N/A\n');
    fprintf('Peak: N/A\n');
end

fprintf('Gain margin: %s\n', format_gain_margin(metrics.gain_margin));
fprintf('Phase margin: %s\n', format_phase_margin(metrics.phase_margin));
fprintf('Gain crossover: %.4f rad/s\n', metrics.gain_cross_freq);
fprintf('Phase crossover: %.4f rad/s\n', metrics.phase_cross_freq);

end

function s = format_gain_margin(Gm)
if isnan(Gm)
    s = 'NaN';
elseif isinf(Gm)
    s = 'Inf';
else
    s = sprintf('%.4f (%.2f dB)', Gm, 20 * log10(Gm));
end
end

function s = format_phase_margin(Pm)
if isnan(Pm)
    s = 'NaN';
elseif isinf(Pm)
    s = 'Inf';
else
    s = sprintf('%.2f deg', Pm);
end

end

function s = logical_to_text(v)
if v
    s = 'yes';
else
    s = 'no';
end
end
