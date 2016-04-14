function wait4X(keybs,key)


FlushEvents('keyDown');

tar = KbName(key);
ch = -999;
while ~any(tar==ch)
    [ keyIsDown, timeSecs, keyCode ] = KbCheck(keybs);
    pressed = find(keyCode);
    if ~isempty(pressed)
        pressed
        ch = pressed;
    end
end

