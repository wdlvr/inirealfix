% digital_rootL_Nyquist_BodeP.m
% Deskripsi: Memplot Bode dan Nyquist dari sistem digital yang didiskritisasi
Ts = 0.001;
num_p = [1.151 0.1774];
den_p = [1 0.739 0.921 0];

% 1. Gunakan format ZPK (Zero-Pole-Gain) 
% Ini mencegah error numerik "lonjakan aneh" di frekuensi rendah
Gp_s = zpk(tf(num_p, den_p)); 
Kp = 17; 
Ki = 1.6343; 
Kd = 6.5713;
C_s = zpk(pid(Kp, Ki, Kd));

% 2. Diskritisasi
Gp_z = c2d(Gp_s, Ts, 'zoh');
C_z  = c2d(C_s,  Ts, 'tustin');

% 3. Open-loop digital
OpenLoop_z = C_z * Gp_z;

% PLOTTING YANG SUDAH DISESUAIKAN (ZOOMING)


% --- 1. BODE PLOT ---
figure('Name', 'Bode Plot Digital yang Benar', 'NumberTitle', 'off');
bode(OpenLoop_z, 'r');
title('Bode Plot - Sistem Digital');
grid on;
% Penjelasan: Berkat zpk(), garis merah di frekuensi rendah 
% sekarang akan terus lurus tanpa lonjakan palsu.

% --- 2. NYQUIST PLOT ---
figure('Name', 'Nyquist Plot Digital (Zoomed)', 'NumberTitle', 'off');
nyquist(OpenLoop_z, 'r');
title('Nyquist Plot - Sistem Digital (Fokus Titik Kritis)');
axis([-5 5 -5 5]); % <-- KUNCI PERBAIKAN
grid on;
% Penjelasan: axis() memotong garis yang melesat ke nilai tak terhingga (10^8).
% Sekarang kita bisa melihat bagaimana kurva melingkari area kritis (-1, 0).

% --- 3. ROOT LOCUS ---
figure('Name', 'Root Locus Digital (Zoomed)', 'NumberTitle', 'off');
rlocus(OpenLoop_z);
title('Root Locus - Sistem Digital (Fokus Kluster z=1)');
axis([0.995 1.005 -0.005 0.005]); % <-- KUNCI PERBAIKAN (Zoom Ekstrem)
grid on;
% Penjelasan: Karena Ts = 0.001 sangat kecil, semua dinamika sistem terhimpit di z=1.
% axis() ini melakukan zoom ekstrem 100x lipat tepat di koordinat (1,0) 
% sehingga lengkungan akar sistemnya akhirnya bisa mekar dan terlihat jelas.