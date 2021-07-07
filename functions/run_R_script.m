function status = run_R_script(script_path, args)
%% Description
%Run an Rscript from the system command line
%% Inputs
% script_path - path to R script
% args - additional arguments to pass to R script
%% Output
% status - status of command. Typically, the R script will save a .csv file
% that you can then use for other applications.
status = system(strcat("Rscript --vanilla ", script_path, " ", args));
end


