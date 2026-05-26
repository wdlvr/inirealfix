clc;
clear;
close all;
% NAMA : William Anthony, NIM  : 13223048
s = tf('s');
K = 47.7;
% Membuat lag compensator
G1 = K/(s*(s+7));
Gc = (s+0.528)/(s+0.072);
G2 = Gc*G1;
Kv1 = dcgain(s*G1)
Kv2 = dcgain(s*G2)
%% Bode Plot
figure;
margin(G1);
grid on;
title('Uncompensated System');
figure;
margin(G2);
grid on;
title('Compensated System');
%% Perbandingan Step Response
T1 = feedback(G1,1);
T2 = feedback(G2,1);
figure;
step(T1);
hold on;
step(T2);
legend('Uncompensated','Compensated');
grid on;
title('Step Response Comparison');