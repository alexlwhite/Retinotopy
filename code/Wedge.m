% c = Wedge(display, carrier, time)
%
% Alex White, using code from Paola Binda & Geoff Boynton
%
% For retinotopic mapping, displays the "Wedge" stimulus: rotating wedge of
% radial checkerboard.
%
% Input: a structure "c" with the following substucture fields: 
% - display: structure for psychtoolbox screen
% - carrier: structure with parameters for carrier texture (radial
% checkerboard)
% - fixpt: structure with parameters for fixation point 
% - time: structure with paramters for stimulus timing
% - task: structure with paramters for task
%
%
% Outputs:
% - c: structure containing all the inputs, as well as c.recorded.onsets,
% which has time stamps of stimulus onsets
% 
% %Feb 5 2016: edited so that Wedge starts vertically (c.mask.startAngle = -90)

function c = Wedge(c)

commandwindow

%% parameters of the stimuli: visible wedge

c.mask = c.wedgeMask; % load parameters of mask from preset wedgeMask;

if ~c.mask.clockwise
    c.mask.Angles = c.mask.Angles(end:-1:1);
end

%% make task events
c = makeRetinotopyTask(c);

%% start PTB loop
c.recorded.escaped = false;

try
    % open PTB
    if ~c.display.open
        c.display = OpenWindow(c.display);
    end
    
    % make it so keypresses during experiment dont show up in Matlab
    % command window or text editor 
    ListenChar(2);
    
    % initializations
    c.recorded.onsets = NaN(c.time.NCycles,length(c.mask.Angles));
    
    %% make carrier texture
    [Carrier_TxtPtr,x,y] = makeRetinotopyCarrier(c);
    
    %% make visible mask
    rad = sqrt(x.^2+y.^2).^.5; %"radius" of each pixel
    ang = atan2(y,x);          %polar angle of each pixel
    img = ~(abs(ang) < (c.mask.widthAngle/2) & rad <= 1);
    img = cat(3,ones(size(img))*c.display.bkColor(1),ones(size(img))*c.display.bkColor(2),...
        ones(size(img))*c.display.bkColor(3),img*255);
    c.mask.img = img;
    
    % texture is homog background, transparent only at wedge location
    Mask_TxtPtr = Screen('MakeTexture', c.display.windowPtr, img);
    
    %% make fixation point
    c = makeRetinotopyFixationMark(c);
    
     %% setup eyelink
    %Initialize eyelink:
    [el, elStatus] = initializeEyelinkRetinotopy(c);
    
    if c.EYE > 0
        if elStatus == 1
            fprintf(1,'\nEyelink initialized with edf file: %s.edf\n\n',c.edfFileName);
        else
            fprintf(1,'\nError in connecting to eyelink!\n');
        end
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Calibrate eye-tracker
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if c.EYE > 0
        
        calibresult = EyelinkDoTrackerSetup(el);
        if calibresult==el.TERMINATE_KEY
            return
        end
        
        
        %also need to re-load normalized gamma table.
        %eyelink calibration seems to screw with it
        BackupCluts;
        %Re-Load calibration file
        if ~isempty(c.display.normlzdGammaTable)
            Screen('LoadNormalizedGammaTable', c.display.windowPtr, c.display.normlzdGammaTable);
        end
        
        Screen('Flip',c.display.windowPtr);                       	% flip to erase
    end
    
    %% Draw text:
    drawRetinotopyTextStart(c,'Wedge');
    
    %% wait for trigger
    wait4T(c.display.keybs)
    if c.display.nScreens==2 && ~c.display.mirrored, Screen('Flip',c.display.otherWindow); end
    
    %% Start eyelink recording!
    record      = c.EYE==-1;
    if ~record
        record = startEyelinkRecording(el,c);
    end
    
    %Tell Eyelink that trial is starting 
    if c.EYE>-1
        Eyelink('command','clear_screen');
        
        if c.EYE>0
            if Eyelink('isconnected')==el.notconnected
                fprintf(1,'\n\n\n\nWARNING! EYELINK CONNECTION LOST\n\n\n');
                if ~c.MRI %cancel if eyeLink is not connected
                    return
                end
            end
        end
        
        % This supplies a title at the bottom of the eyetracker display
        Eyelink('command', 'record_status_message ''Retinotopy Wedge Scan %d''', c.scanNum);
    end
    
    %% start counting time
    runStim = true;
    
    t0 = GetSecs; t = GetSecs - t0;
    while runStim
        escape = escPressed(c.display.keybs);
        if ~escape
            if t <= c.time.DummyDur
                %% dummy scans
                % non fa niente
            else
                %% actual stimulus
                elapsedTime = t-c.time.DummyDur;
                thisCycle = ceil(elapsedTime/c.time.CycleDur);
                flickState =  round( mod( elapsedTime * c.carrier.flickerHz, 1) ) +1;
                tInCycle = mod(elapsedTime,c.time.CycleDur);
                
                if c.mask.discreteAngles
                    thisBlock = ceil(tInCycle/(c.time.CycleDur/length(c.mask.Angles)));
                    rotationAngle = c.mask.Angles(thisBlock); % discrete angles
                else
                    rotationAngle = sign(c.mask.clockwise-.5)*mod(tInCycle*360*(1/c.time.CycleDur),360)+c.mask.startAngle; % continuous rotation
                end
                
                 %task events 
                taskChunk = ceil(elapsedTime/c.task.timeUnits);
                taskEvent = c.task.events(taskChunk);
                taskEventNum = c.task.respEventIs(taskChunk);
                taskFeedback = c.task.feedback(taskChunk);
                
                %fixation color indices:
                outerColorI = 1 + taskFeedback;
                innerColorI = 1 + (taskEvent == 1); 
                
                %checkerborad contrast index
                carrierContrastI = 1 + (taskEvent == 2);
                
                %What correct resp is for this segment:
                correctResp = c.task.correctResps(taskChunk);
                
                if thisCycle <= c.time.NCycles
                    Screen('DrawTexture', c.display.windowPtr, Carrier_TxtPtr(carrierContrastI,flickState),[],...
                        [0 0 c.display.resolution], rotationAngle);
                    Screen('DrawTexture', c.display.windowPtr, Mask_TxtPtr,[],...
                        [0 0 c.display.resolution], rotationAngle);
                    
                    %save onset time:
                    if c.mask.discreteAngles
                        if isnan(c.recorded.onsets(thisCycle,thisBlock))
                            c.recorded.onsets(thisCycle,thisBlock) = elapsedTime;
                            if c.EYE>0, Eyelink('message', 'Onset of block %d in cycle number %d', thisBlock, thisCycle); end
                        end
                    else
                        if isnan(c.recorded.onsets(thisCycle,1))
                            c.recorded.onsets(thisCycle,1) = elapsedTime; % record the beginning of the block
                            if c.EYE>0, Eyelink('message', 'Onset of cycle number %d', thisCycle); end
                        end
                    end
                end
            end
            %draw fixation mark 
            drawFixation_Retinotopy(c, innerColorI, outerColorI);
            Screen('Flip',c.display.windowPtr);
            
            % check for keypress and determine response correctness:
            c = retinotopyCheckTaskResponse(c, correctResp, taskEventNum, taskChunk, elapsedTime);
            
            %Update time counter and check whether time is up
            t = GetSecs - t0;
            runStim = t < c.time.totaldur;
            
        else %if escaped, end the stimulus
            c.recorded.escaped = true;
            runStim = false;
            %sca; no need to do this here 
            %c.display.open = false;
        end
    end
    c.recorded.stimEnd = GetSecs - t0;
    c.recorded.stimStart = c.recorded.onsets(1);
    c.recorded.stimDurtn = c.recorded.stimEnd - c.recorded.stimStart;
    
     % end eye-movement recording
    if c.EYE>0
        Screen(el.window,'FillRect',el.backgroundcolour);   % hide display
        Eyelink('stoprecording');
        Screen('Flip',c.display.windowPtr);
        Eyelink('command','clear_screen');
        Eyelink('command', 'record_status_message ''ENDE''');

        status = Eyelink('ReceiveFile');
        if status == 0
            fprintf(1,'\n\nFile transfer went pretty well\n\n');
        elseif status < 0
            fprintf(1,'\n\nError occurred during file transfer\n\n');
        else
            fprintf(1,'\n\nFile has been transferred (%i Bytes)\n\n',status)
        end
        
        % Eyelink runterfahren
        Eyelink('closefile');
        Eyelink('shutdown');
        
        %move edf file to data folder
        [success, message] = movefile(sprintf('%s.edf',c.edfFileName),sprintf('%s.edf',c.datFileName));
    end
    
    %task performance
    lastEvent = max(c.task.respEventIs(1:taskChunk));
    c = retinotopyAnalyzeTaskPerformance(c, lastEvent);

    %re-enable typing into Matlab 
    ListenChar(1);
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca; c.display.open = false;
    commandwindow;
    myerr.message
    myerr.stack.line
    
end %try..catch.

