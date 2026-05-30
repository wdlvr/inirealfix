% Nama / NIM : 
% Rafi Ihsan Alfathin     / 13223018
% Maghryza Milchan Fayumi / 13223036
% William Anthony         / 13223048
%% Deskripsi: Model sistem (fungsi transfer) yang akan dipakai untuk Tubes ini
clear; clc; close all;

%% Fungsi transfer pitch control aircraft
num = [1.151 0.1774];
den = [1 0.739 0.921 0];
G1 = tf(num, den);

% Tampilkan fungsi transfer sistem
disp('Aircraft pitch control transfer function system:');
G1

% Simpan file .mat nya
save('aircraft_pitch_tf.mat', 'G1', 'num', 'den');