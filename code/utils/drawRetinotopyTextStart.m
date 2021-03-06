function drawRetinotopyTextStart(c,stimType)

textColr = [0 10 255];
str = sprintf('Scan %i of %i',c.scanNum, c.totalScans);
ptbDrawText(c.display.windowPtr,str,c.display.center.*[1 0.85],textColr);

%draw fixation mark
drawFixation_Retinotopy(c,1,1);

%if there's another screen open (operators screen), draw slightly different text
if c.display.nScreens==2 && ~c.display.mirrored
    str = sprintf('Scan %i of %i: %s',c.scanNum, c.totalScans, stimType);
    ptbDrawText(c.display.otherWindow,str,c.display.otherCenter,textColr);
    
    str2 = '[press t to start]';
    ptbDrawText(c.display.otherWindow,str2,c.display.otherCenter+[0 30],textColr);
    Screen('Flip',c.display.otherWindow);
elseif c.display.nScreens==1 %if there's only 1 screen, also say to press t
    str2 = '[press t to start]';
    ptbDrawText(c.display.windowPtr,str2,c.display.center+[0 30],textColr);
end

Screen('Flip',c.display.windowPtr);
