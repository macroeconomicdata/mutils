function [irf] = IRF(B, Q, horz, chol_id, unit_var) 
%% Description
% Estimate impulse response functions
% This simple example uses a Cholesky ordering
%% Inputs
% B - parameter estimates
% Q - covariance of shocks
% chol_id - logical, should we use a cholesky decomposition to identify
% shocks (if false shocks are correlated)
% unit_var - logical, should we scale shocks to be one unit of the
% vairable?
%% Output
% irf - impulse responses organized as response (row), shock (column),
%       period (slice) using zero indexing (i.e. entry is contemporaneous).
%% Function
[pk,k] = size(B);
irf = zeros(k,k,horz+1);
J    = zeros(k,pk);
J(1:k,1:k) = eye(k);

if unit_var
    if chol_id
% --- for one unit shocks --------
       P = chol(Q,'lower');
       Di = diag(diag(P).^-1); % This is used to scale shocks
       H = P*Di; % One unit shock
% --------------------------
% Test scaling
% Hi = H\eye(2);
% Hi*Q*Hi'
% D = diag(diag(P));
% D*D

% ---- for standard deviation ---------
%        Di = diag(Q).^.5; % standard deviation
%        Di = diag(Di./diag(P)); %Matrix to scale shocks
%        H = P*Di; % One unit shock
% -----------------------------
% D = diag( diag(P)./(diag(Q).^.5) )
% D*D
    else
       % One unit correlated shocks
       Di = diag(diag(Q).^-1);
       H = Q*Di;
    end
else
    H = chol(Q, 'lower');
end
irf(:,:,1) = H;
A = comp_form(B');
Aj = A;
for j=2:horz+1 % +1 to include contemporaneous vals
    irf(:,:,j) = (J*Aj*J')*H;
    Aj = A*Aj;
end
end