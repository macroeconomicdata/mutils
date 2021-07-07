function [X,Y] = sim_MIDAS(T)
%% Description
% Simulate data and estimate it to test the UMIDAS function
%% Inputs
% T - number of periods to simulate
%% Outputs
% X - RHS data
% Y - LHS data

%% Parameters
B = [.3; -.5; 0; .2; 1;   .4; -.5; 0; .1; .9;  .5; -.4; 0; .3; 1.1];

%% Create data
[X, Y] = sim_OLS(T,B,1);

t1 = datetime(2000,01,01);
t = dateshift(t1,'end','month',0:3*T-1);
XX = zeros(3*T,5);
idx = 1;
for j=1:T
    XX(idx:idx+2,:) = reshape(X(j,:),5,3)';
    idx = idx + 3;
end

tmp = ones(3,1);
tmp(1:2,1) = nan;
Y = kron(Y,tmp);

Y = timetable(t',Y);
X = timetable(t',XX);
end