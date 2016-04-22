function pressed = mykeyPressed(keybs,mykeyname)
%Returns 1 if mykeyname key is pressed, 0 otherwise

[ keyIsDown, timeSecs, keyCode ] = KbCheck(keybs);
if keyIsDown
    keyPressed = KbName(keyCode);
    if iscell(keyPressed)
        for i = 1:length(keyPressed)
            pressed = ~isempty(strfind(keyPressed{i},mykeyname));
        end
    else
        pressed = ~isempty(strfind(keyPressed,mykeyname));
    end
else
    pressed = 0;
end
