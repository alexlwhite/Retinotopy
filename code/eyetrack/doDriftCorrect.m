Screen('TextSize',scr.main,24);

ptbDrawText('Eye position check', dva2scrPx(0, 0),task.textColor);
Screen(scr.main,'Flip');
WaitSecs(0.75);

rubber([]);
Screen(scr.main,'Flip');

EyelinkDoTrackerSetup(el,'d');

%re-set the heuristic filter
Eyelink('command', 'heuristic_filter = 1 1');
prevDidDriftCorr = true;

drawFixation(1,1);
Screen(scr.main,'Flip');
WaitSecs(0.5);