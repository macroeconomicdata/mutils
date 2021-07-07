# mutils

Matlab utilities for time series (and other) data developed in collaboration the the [BCC](www.bccprogramme.org)

## Description

These utilities perform basic functions like processing data and estimating simple models, including OLS models, vector autoregressions, and unrestricted MIDAS models for monthly/quarterly mixed frequency data. Examples are included in the sample\_scripts folder. All functions work with base Matlab, however, seasonal adjustment requires the (free) [X-13 toolbox](https://www.mathworks.com/matlabcentral/fileexchange/49120-x-13-toolbox-for-seasonal-filtering).

## Functions

- `[A] = comp_form(B)` Put the matrix B in companion form
- `[Xf, Xp, T] = detrend(Y, varargin)` Remove low frequency trends and outliers from data Y
- `FEVD = fevd(irf)` Calculate forecast error variance decomposition
- `[ind] = finite_index(X)` Find the indexes of rows containing only finite values
- `[smoothed] = fLOESS(noisy,span) ` Loess function by [Gabriel Marsh](https://ww2.mathworks.cn/matlabcentral/profile/authors/4257860)
- `[irf] = IRF(B, Q, horz, chol_id, unit_var)` Calculate impulse response functions (IRFs)
- `[irf, irf_upper, irf_lower] = IRF_local(X, lags, horz, ridge, chol_id, unit_var)` Calculate locally estimated IRFs (i.e. local projection)
- `[beta, sigma, sd_beta, t_val, sig_beta] = OLS(X,Y, varargin)` Estimate an OLS model
-  `[beta, sigma, sd_beta, t_val, sig_beta] = OLS_HAC(X,Y, varargin)` Heteroskedasticity and autocorrelation consistent OLS estimation
- `[Xf, Xp, Tnd, X_saf, X_level, X_scale, X_center] = process(Xtable, lib)` Process timeseries data to insure stationarity
- `status = run_R_script(script_path, args)` Run an R script from Matlab
- `[X, x_mean, x_scale] = scale(X)` Scale and center data
- `[X,Y] = sim_MIDAS(T)` Simulate MIDAS data to test the function `UMIDAS()`
- `[X,Y] = sim_OLS(T, B, q)` Simulate OLS data to test the function `OLS()`
- `X = sim_VAR(T, B, Q)` Simulate VAR data to test the function `VAR()`
- `[zz] = stack_obs(z,p, drop_last)` Stack observations in VAR or DFM format
- `[fit, err, B, RHS, lhs, Time, sigma, sig_beta, t_val] = UMIDAS(yf, Xf, lags, ridge, include_months, intercept, verbose)` Simple unrestricted MIDAS estimation for monthly/quarterly mixed frequency data
- `[X_sa, X_nsa] = unprocess(Xtimetable, lib, X_level, Tnd, X_saf, X_scale, X_center)` Undo processing from the `process()` function
- `[B, Sig, Sig_B, fit] = VAR(X, lags, varargin)` Estimate a vector autoregression (VAR)




