function [C, info] = design_pid_controller(G, target_bw)
%DESIGN_PID_CONTROLLER PID tuning helper.

opts = [];
try
    opts = pidtuneOptions('PhaseMargin', 60, 'DesignFocus', 'disturbance-rejection');
catch
    try
        opts = pidtuneOptions('PhaseMargin', 60);
    catch
        % Fallback for older MATLAB versions without pidtuneOptions.
        opts = [];
    end
end

max_bw = 10; % robustness-focused cap

if nargin < 2 || isempty(target_bw)
    base_bw = max_bw;
    candidates = logspace(-3, log10(base_bw), 12); % 0.001 to max_bw rad/s
else
    base_bw = min(target_bw, max_bw);
    candidates = unique(base_bw * [1 1/2 1/4 1/8 2 4]);
    candidates = unique([candidates logspace(-3, log10(base_bw), 8)]); % add a low-band fallback
end
candidates = candidates(candidates > 0 & isfinite(candidates) & candidates <= max_bw);

signs = [1 -1];
scale_candidates = logspace(-3, 0, 7); % 0.001 to 1

best = struct('found', false, 'has_gm', false, 'gm', -Inf, 'has_pm', false, ...
    'pm', -Inf, 'settle', Inf, 'C', [], 'info', struct(), 'bw', NaN, ...
    'sign', 1, 'scale', NaN);

for s = signs
    G_use = s * G;
    for k = 1:numel(candidates)
        w = candidates(k);
        [C_try, info_try] = try_pidtune(G_use, w, opts);
        if isempty(C_try)
            continue;
        end

        for scale = scale_candidates
            L = (scale * C_try) * G_use;
            T = feedback(L, 1);
            Tm = minreal(T, 1e-6);
            if ~isstable(Tm)
                continue;
            end

            warn_state = warning('off', 'all');
            [Gm, Pm] = margin(L);
            warning(warn_state);
            has_gm = isinf(Gm) || (isfinite(Gm) && (Gm > 1));
            has_pm = isfinite(Pm) && (Pm > 0);

            if ~(has_gm && has_pm)
                continue;
            end

            s_info = stepinfo(Tm);
            settle = s_info.SettlingTime;
            if ~isfinite(settle)
                settle = Inf;
            end

            C_out = scale * C_try;
            if s < 0
                C_out = -C_out;
            end

            if ~best.found
                best = pack_best(C_out, info_try, w, s, scale, has_gm, Gm, has_pm, Pm, settle);
                continue;
            end

            if Gm > best.gm + 1e-3
                best = pack_best(C_out, info_try, w, s, scale, has_gm, Gm, has_pm, Pm, settle);
            elseif abs(Gm - best.gm) <= 1e-3
                if Pm > best.pm + 1e-3
                    best = pack_best(C_out, info_try, w, s, scale, has_gm, Gm, has_pm, Pm, settle);
                elseif abs(Pm - best.pm) <= 1e-3 && settle < best.settle
                    best = pack_best(C_out, info_try, w, s, scale, has_gm, Gm, has_pm, Pm, settle);
                end
            end
        end
    end
end

if best.found
    C = best.C;
    info = best.info;
    info.SelectedBandwidth = best.bw;
    info.SelectedGainMargin = best.gm;
    info.SelectedPhaseMargin = best.pm;
    info.SelectedSign = best.sign;
    info.SelectedScale = best.scale;
    info.ClosedLoopStable = true;
    return;
end

% Last resort: return the default pidtune result (may be unstable).
[C, info] = try_pidtune(G, [], opts);
if isempty(C)
    info.ClosedLoopStable = false;
else
    info.ClosedLoopStable = isstable(feedback(C * G, 1));
end

end

function [C, info] = try_pidtune(G, w, opts)
C = [];
info = struct();

warn_state = warning('off', 'all');
try
    if isempty(w)
        if isempty(opts)
            [C, info] = pidtune(G, 'PID');
        else
            [C, info] = pidtune(G, 'PID', opts);
        end
    else
        if isempty(opts)
            [C, info] = pidtune(G, 'PID', w);
        else
            [C, info] = pidtune(G, 'PID', w, opts);
        end
    end
catch
    C = [];
    info = struct();
end
warning(warn_state);
end

function best = pack_best(C, info, bw, sign, scale, has_gm, gm, has_pm, pm, settle)
best = struct('found', true, 'has_gm', has_gm, 'gm', gm, 'has_pm', has_pm, ...
    'pm', pm, 'settle', settle, 'C', C, 'info', info, 'bw', bw, 'sign', sign, ...
    'scale', scale);
end
