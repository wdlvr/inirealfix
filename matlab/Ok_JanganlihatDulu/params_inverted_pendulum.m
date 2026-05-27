function p = params_inverted_pendulum()
%PARAMS_INVERTED_PENDULUM Parameter set for inverted pendulum on a cart.

p.M = 0.5;    % cart mass (kg)
p.m = 0.2;    % pendulum mass (kg)
p.b = 0.1;    % cart friction coefficient (N/m/s)
p.I = 0.006;  % pendulum inertia (kg*m^2)
p.g = 9.8;    % gravity (m/s^2)
p.l = 0.3;    % distance to pendulum COM (m)

p.q = (p.M + p.m) * (p.I + p.m * p.l^2) - (p.m * p.l)^2;
