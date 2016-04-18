%ptbDrawText(str,posxy,c)
% Alex White, 2012

%Using psychtoolbox with open window "win", draw text "str" centered on "[x,y]" (in units of pixels relative
%to screen rect), with color "c"

function [] = ptbDrawText(win,str,posxy,c)

bounds = Screen(win,'TextBounds',str);
x  = posxy(1)-bounds(3)/2;     % x position
y  = posxy(2)-bounds(4)/2;     % y position

Screen(win,'Drawtext',str,x,y,c);