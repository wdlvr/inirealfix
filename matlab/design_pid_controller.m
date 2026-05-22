function [C, info] = design_pid_controller(G, target_bw)
%DESIGN_PID_CONTROLLER PID tuning helper.

if nargin < 2 || isempty(target_bw)
    [C, info] = pidtune(G, 'PID');
else
    [C, info] = pidtune(G, 'PID', target_bw);
end
