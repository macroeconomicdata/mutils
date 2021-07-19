clc

disp('------------------------------------');

s = x13spec('transform','power',1);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('....................................');

s = x13spec('transform','power',0.5);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('....................................');

s = x13spec('transform','power',0);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('------------------------------------');

s = x13spec('transform','function','none','transform','power',1);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('....................................');

s = x13spec('transform','function','none','transform','power',0.5);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('....................................');

s = x13spec('transform','function','none','transform','power',0);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('------------------------------------');

s = x13spec('transform','function','log','transform','power',1);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('....................................');

s = x13spec('transform','function','log','transform','power',0.5);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('....................................');

s = x13spec('transform','function','log','transform','power',0);
disp(s);
s1 = s.TransformPowerToFunction;
disp(s1);

disp('------------------------------------');
