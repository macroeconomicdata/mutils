function [ind] = finite_index(X)
% Identify rows of X which contain only finite values
ind = all(isfinite(X), 2);
end