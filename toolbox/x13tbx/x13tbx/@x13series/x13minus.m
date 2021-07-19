% X13MINUS takes two x13series objects and returns a new x13series object
% that contains all time series both arguments have in common, but
% containing the difference of the values. This is useful to exactly
% compare the differences between two sets of specifications.
%
% Usage:
%   x3 = x13minus(x1,x2)
%
% x1, x2, x3 are x13series objects. x3 contains all time series objects
% that are common to x1 and x2, but with their differences as values. In
% addition, x3 will contain variables 'tr','sa','sf','ir','si','rsd' that
% contain the differences of the key variables, so that even if the key
% variables have different names in x1 and x2, you can still get a
% difference.
%
% Example1:
%   load BoxJenkinsG; dates = BoxJenkinsG.dates; data = BoxJenkinsG.data; 
%   spec1 = makespec('PICKFIRST','NOTRANS','EASTER','TD','X11', ...
%       'series','name','linear');
%   x1 = x13(dates,data,spec1);
%   spec2 = makespec(spec1,'LOG','series','name','log');
%   x2 = x13(dates,data,spec2);
%   x3 = x13minus(x1,x2);
%   ah = subplot(2,1,1); plot(ah,x1,x2,'e2','comb');
%   ah = subplot(2,1,2); plot(ah,x3,'e2');
%
% EXAMPLE 2:
%   spec1 = makespec('PICKFIRST','LOG','EASTER','TD','X11', ...
%       'series','name','X-11');
%   x1 = x13(dates,data,spec1);
%   spec2 = makespec(spec1,'SEATS','series','name','SEATS');
%   x2 = x13(dates,data,spec2);
%   x3 = x13minus(x1,x2);
%   ah = subplot(2,1,1); plot(ah,x1,x2,'d11','s11','comb','quiet');
%   ah = subplot(2,1,2); plot(ah,x3,'sa');
% Note that x3.sa is x1.e2 - x2.s11, because the seasonally adjusted
% variables have different names in in X11 and in SEATS.
%
% NOTE: This file is part of the X-13 toolbox.
%
% see also guix, x13, makespec, x13spec, x13series, x13composite, 
% x13series.plot,x13composite.plot, x13series.seasbreaks,
% x13composite.seasbreaks, fixedseas, spr, InstallMissingCensusProgram
%
% Author  : Yvan Lengwiler
% Version : 1.50
%
% If you use this software for your publications, please reference it as
%   Yvan Lengwiler, 'X-13 Toolbox for Matlab, Version 1.50', Mathworks File
%   Exchange, 2021.

% History:
% 2021-04-27    Version 1.50    First version.

function z = x13minus(x,y)

    Lx = x.listofitems;
    Ly = y.listofitems;
    L = intersect(Lx,Ly);
    
    D = intersect(x.dat.dates,y.dat.dates);
    Dx = ismember(x.dat.dates,D);
    Dy = ismember(y.dat.dates,D);
    
    z = x13series;

    allkeyv = {'dat','tr','sa','sf','ir','si','rsd'};
    for v = 1:numel(allkeyv)
        try
            vx = x.(x.keyv.(allkeyv{v})).(x.keyv.(allkeyv{v}));
            vy = y.(y.keyv.(allkeyv{v})).(y.keyv.(allkeyv{v}));
            ts = vx(Dx) - vy(Dy);
            z.addvariable(allkeyv{v},D,ts,allkeyv{v},1);
        catch
        end
    end
    
    for v = 1:numel(L)
        try
            ts = x.(L{v}).(L{v})(Dx) - y.(L{v}).(L{v})(Dy);
            z.addvariable(L{v},D,ts,L{v},1);
        catch
        end
    end
    
    [~,tx] = fileparts(x.prog);
    [~,ty] = fileparts(y.prog);
    
    z.title = [tx, ' minus ', ty];

end
