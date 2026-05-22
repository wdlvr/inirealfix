function [sys, Gx, Gtheta] = model_continuous(p)
%MODEL_CONTINUOUS Continuous-time state-space and transfer functions.

M = p.M;
m = p.m;
b = p.b;
I = p.I;
g = p.g;
l = p.l;
q = p.q;

A = [0 1 0 0;
     0 -(I + m * l^2) * b / q   (m^2 * g * l^2) / q  0;
     0 0 0 1;
     0 -(m * l * b) / q         m * g * l * (M + m) / q  0];

B = [0;
     (I + m * l^2) / q;
     0;
     (m * l) / q];

C = [1 0 0 0;
     0 0 1 0];

D = [0;
     0];

sys = ss(A, B, C, D);
Gx = minreal(tf(sys(1)));
Gtheta = minreal(tf(sys(2)));
