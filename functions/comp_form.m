function [A] = comp_form(B)
% Put an m x mp transition matrix into companion form where m is the number 
% of series and p the number of lags
[r,c] = size(B);
A = [B; eye(c-r), zeros(c-r, r)];
end