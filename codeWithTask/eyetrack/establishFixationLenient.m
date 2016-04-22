% function [status, newFix] = establishFixationLenient()% At start of trial, establish new fixation point. % This version returns the current fixation position (newFix) even if outside of acceptable region.% status: 1 = all good, fixation established within bounds. %         0 = fixation extablished but out of bounds %        -1 = gaze position not measureable function [status, newFix] = establishFixationLenient()global scr task % determine recorded eye if not already set if ~isfield(task,'DOMEYE') && task.EYE>0    task.DOMEYE = [];    while isempty(task.DOMEYE)        evt = Eyelink('newestfloatsample');        task.DOMEYE = find(evt.gx ~= -32768);    endend%1. Wait until eye is within some boundary region, initlFixChkRad, % for minimum amount of time (minFixTime)cxm = task.fixation.posX(1); %1 is central fixtaion cym = task.fixation.posY(1);rad = scr.intlFixCkRad;%if intlFixCheckRad has length 1, it's a circular acceptance region; %if intlFixCheckRad has length 2, it's a rectangular acceptance region circleCheck = length(rad)==1; if circleCheck %circle    Eyelink('command','draw_box %d %d %d %d 15', cxm-rad, cym-rad, cxm+rad, cym+rad);else %rectangle    Eyelink('command','draw_box %d %d %d %d 15', cxm-rad(1), cym-rad(2), cxm+rad(1), cym+rad(2));enddrawFixation(1,1);Screen(scr.main,'Flip');Eyelink('message', 'EVENT_FixationCheck');tStart=GetSecs;fixtnMeasured=0; corStart=0; tCor=0;t=tStart;while ((t-tStart) < task.maxFixCheckTime && tCor<=task.minFixTime)    [xs,ys] = getCoord;    goodfixs = zeros(1,length(xs));     for ci=1:length(xs)        x = xs(ci);        y = ys(ci);                 if circleCheck            goodfixs(ci) = sqrt((x-cxm)^2+(y-cym)^2)<rad;        else            goodfixs(ci) = abs(x-cxm)<rad(1) && abs(y-cym)<rad(2);         end    end    if isempty(goodfixs)        fixtnMeasured = -1;    elseif all(goodfixs)        fixtnMeasured = 1;    else        fixtnMeasured = 0;    end    	if fixtnMeasured == 1 && corStart == 0		tCorStart = GetSecs; 		corStart = 1;	elseif fixtnMeasured == 1 && corStart == 1		tCor = GetSecs-tCorStart;	else		corStart = 0;	end		t=GetSecs;end%% 2. Find the mean gaze position in some time window to define %% as new fixation position if fixtnMeasured>=0 %as long as some gaze position was measured     mex = 0; mey = 0;    for ei = 1:task.nMeanEyeSamples        if task.EYE>0            while ~Eyelink('Newfloatsampleavailable')==1; % wait till new sample            end;        end        [xi,yi] = getCoord;        mex = mex+xi;        mey = mey+yi;    end        fixX = mex/task.nMeanEyeSamples;    fixY = mey/task.nMeanEyeSamples;         badEye = isnan(fixX) || isnan(fixY);        cxm = task.fixation.posX(1); %1 is central fixtaion    cym = task.fixation.posY(1);        if circleCheck        badFix = sqrt((fixX-cxm)^2+(fixY-cym)^2)>scr.intlFixCkRad;    else        badFix = abs(fixX-cxm)>rad(1) || abs(fixY-cym)>rad(2);     end       newFix = [fixX fixY];        if badEye        status = -1;        newFix = [task.fixation.posX(1) task.fixation.posY(1)]; %set to default if not measureable    else        status = ~badFix;    endelse    newFix = [task.fixation.posX(1) task.fixation.posY(1)]; %set to default if not measureable     status = -1;end