% c = Rings(c)
%
% Alex White, using code from Paola Binda & Geoff Boynton
%
% For retinotopic mapping, displays the "Rings" stimulus: gradually contracting (or expanding)
% rings of radial checkerboards.
%
% Input: structure "c" with the following sub-structure fields: 
% - display: structure for psychtoolbox screen
% - carrier: structure with parameters for carrier texture (radial
% checkerboard)
% - fixpt: structure with parameters for fixation point 
% - time: structure with paramters for stimulus timing
% - task: structure with paramters for task
%
% Outputs:
% - c: structure containing all the inputs, as well as c.recorded.onsets,
% which has time stamps of stimulus onsets

function c = Rings(c)

commandwindow


%% Stimulus parameters: visible ring

c.mask              = c.ringsMask; %load parameters for mask preset in c.ringsMask
c.mask.nRings       = c.carrier.nRings-c.mask.thickNRings+1;
c.time.nConds       = c.mask.nRings;

%% make task events
c = makeRetinotopyTask(c);


%% start ptb loop
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
    c.recorded.onsets = NaN(c.time.NCycles,c.time.nConds);
    
    %% make carrier texture
    [Carrier_TxtPtr, x, y]= makeRetinotopyCarrier(c);
    
    %% make visible mask
    rad = sqrt(x.^2+y.^2); %"eccentricity" of each pixel
    dim = round(c.display.resolution);
    
    if c.carrier.fitInScreen
        radmax = myDeg([],min(dim),c.display)/2; %maximum radius in dva. constrained by smaller of screen dimension (horiz vs vert)
    else
        radmax = myDeg([],max(dim),c.display)/2; %maximum radius in dva. constrained by larger of screen dimension (horiz vs vert)
    end
    
    nr = c.carrier.nRings;
    %edges of band in units of carrienr rings:
    innerRingEdges = 0:1:(nr-c.mask.thickNRings);
    outerRingEdges = c.mask.thickNRings:1:nr;
    
    %edges of band in dva. Squared so as to match magnification of carrier rings at increasing eccentricity
    innerEdges = radmax*(innerRingEdges/nr).^2;
    outerEdges = radmax*(outerRingEdges/nr).^2;
    
    %store ring edges:
    c.mask.Rings(:,1) = innerEdges';
    c.mask.Rings(:,2) = outerEdges';
    
    %should ring expand or contract?
    if ~c.mask.expand
        c.mask.Rings = c.mask.Rings(end:-1:1,:);
    end
    
    Mask_TxtPtr = c.mask.Rings(:,1)*NaN;
    for j = 1:c.time.nConds
        img = rad >= c.mask.Rings(j,1)/radmax & rad < c.mask.Rings(j,2)/radmax;
        img = double(~img);
        img = cat(3,ones(size(img))*c.display.bkColor(1),ones(size(img))*c.display.bkColor(2),...
            ones(size(img))*c.display.bkColor(3),img*255);
        % texture is homog background, transparent only at wedge location
        Mask_TxtPtr(j) = Screen('MakeTexture', c.display.windowPtr, img);
    end
    
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
    drawRetinotopyTextStart(c,'Rings');
    
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
        Eyelink('command', 'record_status_message ''Retinotopy Rings Scan %d''', c.scanNum);

    end
    
    %% start counting time
    rotationAngle = 0;
    runStim = true;
    
    t0 = GetSecs; t = GetSecs - t0;
        
    %% run stimulus
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
                thisCond = ceil(tInCycle/(c.time.CycleDur/c.time.nConds));
                
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
                    Screen('DrawTexture', c.display.windowPtr, Mask_TxtPtr(thisCond),[],...
                        [0 0 c.display.resolution], rotationAngle);
                    
                    if isnan(c.recorded.onsets(thisCycle,thisCond))
                        c.recorded.onsets(thisCycle,thisCond) = elapsedTime;
                        if c.EYE>0, Eyelink('message', 'Onset of condition %d in cycle number %d', thisCond, thisCycle); end
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
            runStim = false;  %to break out of this while loop
            %sca; %no need to do that, it happens later anyway
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
    sca;
    commandwindow;
    myerr.message
    myerr.stack.line
    keyboard
    
end %try..catch.


