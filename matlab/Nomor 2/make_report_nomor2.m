% make_report_nomor2.m
% Run `analisis_sistem.m`, collect figures and metrics, and write a Markdown report.
clear; clc;

here = fileparts(mfilename('fullpath'));
if isempty(here)
    p = which('make_report_nomor2.m');
    if ~isempty(p)
        here = fileparts(p);
    else
        here = pwd;
    end
end

% Run analysis script (will save figures and metrics)
run(fullfile(here, 'analisis_sistem.m'));

fig_dir = fullfile(here, 'figures');
metrics_file = fullfile(fig_dir, 'analysis_metrics.mat');

metrics = struct();
if exist(metrics_file, 'file')
    metrics = load(metrics_file);
else
    warning('Metrics file not found: %s. Attempting to assemble from workspace variables.', metrics_file);
    maybe = {'Gm','Pm','Wcg','Wcp','Gm_db','info','ess','stable_cl'};
    for k=1:numel(maybe)
        v = maybe{k};
        if exist(v, 'var')
            metrics.(v) = eval(v); %#ok<EVLCT>
        end
    end
end

% Prepare report folder
report_dir = fullfile(here, 'report');
if ~exist(report_dir, 'dir')
    mkdir(report_dir);
end

report_path = fullfile(report_dir, 'laporan_nomor2.md');
fid = fopen(report_path, 'w');
if fid == -1
    error('Cannot open report file for writing: %s', report_path);
end

fprintf(fid, '# Laporan Analisis Sistem — Nomor 2\n\n');

% System model
fprintf(fid, '## Model Sistem\n\n');
try
    [num, den] = tfdata(G1, 'v');
    fprintf(fid, '- Numerator: %s\n', mat2str(num));
    fprintf(fid, '- Denominator: %s\n\n', mat2str(den));
catch
    fprintf(fid, 'Model TF tidak tersedia di workspace.\n\n');
end

% Figures
fprintf(fid, '## Plot\n\n');
figs = {'root_locus_uncomp.png','bode_uncomp.png', ...
    'nyquist_uncomp.png','step_uncomp.png','impulse_uncomp.png'};
for i=1:numel(figs)
    figName = figs{i};
    src = fullfile(fig_dir, figName);
    rel = fullfile('..', 'figures', figName);
    if exist(src, 'file')
        fprintf(fid, '![%s](%s)\n\n', figName, rel);
    else
        fprintf(fid, '- Gambar %s tidak ditemukan di %s\n\n', figName, fig_dir);
    end
end

% Metrics and quick analysis
fprintf(fid, '## Hasil Analisis\n\n');
if isfield(metrics, 'Gm')
    gm = metrics.Gm;
    if isfinite(gm)
        gm_db = 20*log10(gm);
    else
        gm_db = Inf;
    end
    fprintf(fid, '- Gain margin: %g (%.2f dB)\n', gm, gm_db);
end
if isfield(metrics, 'Pm')
    fprintf(fid, '- Phase margin: %g deg\n', metrics.Pm);
end
if isfield(metrics, 'Wcg')
    fprintf(fid, '- Gain crossover: %g rad/s\n', metrics.Wcg);
end
if isfield(metrics, 'Wcp')
    fprintf(fid, '- Phase crossover: %g rad/s\n', metrics.Wcp);
end
if isfield(metrics, 'info')
    info = metrics.info;
    if isstruct(info)
        fprintf(fid, '- Rise time: %g s\n', info.RiseTime);
        fprintf(fid, '- Settling time: %g s\n', info.SettlingTime);
        fprintf(fid, '- Overshoot: %g %%\n', info.Overshoot);
    end
end
if isfield(metrics, 'ess')
    fprintf(fid, '- Steady-state error: %g\n', metrics.ess);
end

fprintf(fid, '\n## Analisis Singkat\n\n');
if isfield(metrics, 'Pm')
    Pm = metrics.Pm;
    if Pm < 30
        fprintf(fid, 'Phase margin rendah (%.2g deg) — sistem berisiko overshoot dan kurang stabil. Rekomendasi: desain controller (lead/lag atau PID) untuk menaikkan phase margin.\n\n', Pm);
    elseif Pm < 45
        fprintf(fid, 'Phase margin moderat (%.2g deg) — mungkin perlu tuning tergantung spesifikasi performa transient.\n\n', Pm);
    else
        fprintf(fid, 'Phase margin baik (%.2g deg).\n\n', Pm);
    end
end

if isfield(metrics, 'info') && isstruct(metrics.info)
    if metrics.info.Overshoot > 20
        fprintf(fid, 'Overshoot tinggi (%.2g%%). Pertimbangkan pengurangan overshoot melalui pengetatan controller.\n\n', metrics.info.Overshoot);
    end
end

fprintf(fid, '---\nLaporan dibuat otomatis oleh `make_report_nomor2.m`.\n');
fclose(fid);

fprintf('Report written: %s\n', report_path);
