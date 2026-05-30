% Nama / NIM : 
% Rafi Ihsan Alfathin     / 13223018
% Maghryza Milchan Fayumi / 13223036
% William Anthony         / 13223048
% Deskripsi: Kode ini akan menghasilkan sistem diskritnya

Ts = 0.005; % Time sampling
num_p = [1.151 0.1774]; %ini plant pembilang
den_p = [1 0.739 0.921 0]; %ini plant penyebut
Gp_s = tf(num_p, den_p); % ini plant akhir

% komponen kontroller PID
Kp = 17;
Ki = 1.6343;
Kd = 6.5713;
C_s = pid(Kp, Ki, Kd); % controller pid

OpenLoop_s = C_s * Gp_s; % open loop system
ClosedLoop_s = feedback(OpenLoop_s, 1); % closed loop unity

% Proses diskritisasinya
Gp_z = c2d(Gp_s, Ts, 'zoh'); % plant menggunakan ZOH
C_z = c2d(C_s, Ts, 'tustin'); % controller menggunakan Tustin

% system closed loop diskrit
OpenLoop_z = C_z * Gp_z;
ClosedLoop_z = feedback(OpenLoop_z, 1);
info_digital = stepinfo(ClosedLoop_z)
info_analog = stepinfo(ClosedLoop_s)

figure;
t_sim = 0:0.01:6; % waktu simulasi 6 detik

% respon analog
step(ClosedLoop_s, t_sim);
hold on; % Menahan grafik pertama agar tidak tertimpa

% respon digital
t_sim_z = 0:Ts:6;
step(ClosedLoop_z, t_sim_z);

% tambahan keterangan
title('Perbandingan Sistem Analog vs Digital');
legend('Sistem Analog (Continuous)', 'Sistem Digital (Discrete)', 'Location', 'southeast');
grid on;
hold off;