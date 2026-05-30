% Nama / NIM : 
% Rafi Ihsan Alfathin     / 13223018
% Maghryza Milchan Fayumi / 13223036
% William Anthony         / 13223048
% Deskripsi: Kode ini akan menghasilkan Bode plot, Root locus, dan Nyquist

Ts = 0.001;
num_p = [1.151 0.1774];
den_p = [1 0.739 0.921 0];

% membuat sistem analog (s-domainnya)
Gp_s = zpk(tf(num_p, den_p)); 
Kp = 17; 
Ki = 1.6343; 
Kd = 6.5713;

% controller PID nya
C_s = zpk(pid(Kp, Ki, Kd));

% diskritisasi fungsi plant dan controller
Gp_z = c2d(Gp_s, Ts, 'zoh');
C_z  = c2d(C_s,  Ts, 'tustin');

% open loop digital
OpenLoop_z = C_z * Gp_z;

% BODE PLOT 
figure('Name', 'Bode Plot Digital', 'NumberTitle', 'off');
bode(OpenLoop_z, 'r');
title('Bode Plot - Sistem Digital');
grid on;

% NYQUIST PLOT
figure('Name', 'Nyquist Plot Digital (Zoomed)', 'NumberTitle', 'off');
nyquist(OpenLoop_z, 'r');
title('Nyquist Plot - Sistem Digital (Fokus Titik Kritis)');
axis([-5 5 -5 5]); % dilakukan zoom agar lebih jelas
grid on;

% ROOT LOCUS
figure('Name', 'Root Locus Digital (Zoomed)', 'NumberTitle', 'off');
rlocus(OpenLoop_z);
title('Root Locus - Sistem Digital (Fokus Kluster z=1)');
axis([0.995 1.005 -0.005 0.005]); % zoom extrem untuk meliihat polenya
grid on;