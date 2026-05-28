clear; clc; close all;

%% Aircraft Pitch Control Transfer Function
num = [11.7304 22.578];
den = [1 4.9676 12.941 0];

G1 = tf(num, den);

G1.InputName = 'delta_e';
G1.OutputName = 'theta';

sys_tf = G1;

disp('Aircraft pitch control transfer function system:');
sys_tf

disp('G1 = theta / delta_e:');
G1

save('aircraft_pitch_tf.mat', 'G1', 'sys_tf', 'num', 'den');