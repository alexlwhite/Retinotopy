function drawFixation_Retinotopy(c,innerColorI,outerColorI)
% Draws a dot with a ring around it 
% 
% Inputs: 
% - c: structure with stimulus and screen info
% - innerColorI: index of color for inner dot, to pull out a row from
%   c.fixpt.colors
% - outerColorI: index of color for outer ring, to pull out a row from
%   c.fixpt.ringColors

Screen('FillOval', c.display.windowPtr, c.display.bkColor, c.fixpt.ringRect);  
Screen('DrawDots', c.display.windowPtr, c.fixpt.pos, c.fixpt.innerSize, c.fixpt.colors(innerColorI,:), [], c.fixpt.dotType);
Screen('FrameOval',c.display.windowPtr, c.fixpt.ringColors(outerColorI,:), c.fixpt.ringRect, c.fixpt.ringThick, c.fixpt.ringThick);

