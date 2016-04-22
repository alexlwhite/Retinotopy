function [x,y] = getCoord

global task scr

if task.EYE == 0
	[x,y,dummy] = GetMouse( scr.main );         % get gaze position from mouse							
else
	evt = Eyelink( 'newestfloatsample');	
	x   = evt.gx(task.DOMEYE);			
	y   = evt.gy(task.DOMEYE);			
end
