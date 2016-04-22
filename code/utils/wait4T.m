function wait4T(keybs)

ch = '';
while ~strcmp(ch,'t');
    [ keyIsDown, timeSecs, keyCode ] = KbCheck(keybs);
    keyPressed= KbName(keyCode);
    if ~isempty(keyPressed)
        keyPressed
        ch = keyPressed(end);
    end
end

