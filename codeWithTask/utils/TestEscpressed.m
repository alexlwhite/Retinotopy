clc
KbName('UnifyKeyNames') 
t0 = GetSecs;
t = GetSecs - t0;
id = 0;
while t < 2 && ~id
    id = escPressed(keybs);
    t = GetSecs - t0;
end