function out = myDeg(pos,siz,display)
% pixels: [xpos,ypos];[xsize,ysize] -> makes a rect; or [xpos,ypos] -> gives
% position only
if ~isempty(siz) && ~isempty(pos)
    out(1) = display.center(1) + angle2pix(display, pos(1)-0.5*siz(1) );
    out(3) = display.center(1) + angle2pix(display, pos(1)+0.5*siz(1) );
    
    out(2) = display.center(2) + angle2pix(display, pos(2)-0.5*siz(2) );
    out(4) = display.center(2) + angle2pix(display, pos(2)+0.5*siz(2) );
elseif ~isempty(pos)
    out(:,1) = pix2angle(display, pos(:,1) - 1440 - display.center(1));
    if size(pos,2)>1
        out(:,2) = pix2angle(display, pos(:,2)- display.center(2));
    end
elseif ~isempty(siz)
    out(1) = pix2angle(display, siz(1));
    if length(siz)>1
        out(2) = pix2angle(display, siz(2));
    end
end

