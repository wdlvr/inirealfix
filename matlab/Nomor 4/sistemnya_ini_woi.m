Ts = 0.001; 
num_p = [1.151 0.1774]; %iniplant pembilang
den_p = [1 0.739 0.921 0]; %inipant penyebut
Gp_s = tf(num_p, den_p); %iniplant


Kp = 17;
Ki = 1.6343;
Kd = 6.5713;
C_s = pid(Kp, Ki, Kd); %controller pid


OpenLoop_s = C_s * Gp_s;
ClosedLoop_s = feedback(OpenLoop_s, 1);

% 5. Proses Diskritisasi (C to D)
Gp_z = c2d(Gp_s, Ts, 'zoh');
C_z = c2d(C_s, Ts, 'tustin');

% 6. Membentuk Sistem Closed-Loop Diskrit (Digital)
OpenLoop_z = C_z * Gp_z;
ClosedLoop_z = feedback(OpenLoop_z, 1);
info_digital = stepinfo(ClosedLoop_z)
info_analog = stepinfo(ClosedLoop_s)
% 7. Analisis dan Plotting (Overlay)
figure;

% Waktu simulasi agar kedua grafik sejajar rapi (misal 0 sampai 6 detik)
t_sim = 0:0.01:6; 

% Plot respon analog (garis biru solid)
step(ClosedLoop_s, t_sim);
hold on; % Menahan grafik pertama agar tidak tertimpa

% Plot respon digital (garis merah putus-putus atau tangga)
% Menggunakan waktu simulasi yang disesuaikan dengan sampling Ts
t_sim_z = 0:Ts:6;
step(ClosedLoop_z, t_sim_z);

title('Perbandingan Sistem Analog vs Digital');
% Menambahkan legenda untuk memperjelas grafik
legend('Sistem Analog (Continuous)', 'Sistem Digital (Discrete)', 'Location', 'southeast');
grid on;
hold off; % Melepas penahanan grafik