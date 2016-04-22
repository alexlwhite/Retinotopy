% c = Rings(display, carrier, time)
%
% Alex White, using code from Paola Binda & Geoff Boynton
%
% For retinotopic mapping, displays the "Rings" stimulus: gradually contracting (or expanding)
% rings of radial checkerboards.
%
% Inputs:
% - display: structure for psychtoolbox screen
% - carrier: structure with parameters for carrier texture (radial
% checkerboard)
% - time: structure with paramters for stimulus timing
%
% Outputs:
% - c: structure containing all the inputs, as well as c.recorded.onsets,
% which has time stamps of stimulus onsets

function c = Rings(display, carrier, time)

commandwindow

c.display   = display;
c.carrier   = carrier;
c.time      = time;

%% Stimulus parameters: visible ring
c.mask.expand       = 0; %ring expands or contracts
c.mask.thickNRings  = 3; %thickness of carrier in number of rings
c.mask.nRings       = c.carrier.nRings-c.mask.thickNRings+1;

c.time.nConds       = c.mask.nRings;

%% start ptb loop
c.recorded.escaped = false;
try
    % open PTB
    if ~c.display.open
        c.display = OpenWindow(c.display);
    end
    
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
    c.fixpt.pos = myPix([0 0],[],c.display);
    c.fixpt.size = myPix([],[.3],c.display);
    c.fixpt.type = 1; %0 (default) squares, 1 circles (with anti-aliasing), 2 circles (with high-quality anti-aliasing, if supported by your hardware). If you use dot_type = 1 you'll also need to set a proper blending mode with the Screen('BlendFunction') command!
    
    %% Draw text:
    drawRetinotopyTextStart(c,'Rings');
    
    %% wait for trigger
    wait4T(c.display.keybs)
    if c.display.nScreens==2 && ~c.display.mirrored, Screen('Flip',c.display.otherWindow); end
    
    
    %% start counting time
    rotationAngle = 0;
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
                thisCond = ceil(tInCycle/(c.time.CycleDur/c.time.nConds));
                
                if thisCycle <= c.time.NCycles
                    Screen('DrawTexture', c.display.windowPtr, Carrier_TxtPtr(flickState),[],...
                        [0 0 c.display.resolution], rotationAngle);
                    Screen('DrawTexture', c.display.windowPtr, Mask_TxtPtr(thisCond),[],...
                        [0 0 c.display.resolution], rotationAngle);
                    
                    if isnan(c.recorded.onsets(thisCycle,thisCond))
                        c.recorded.onsets(thisCycle,thisCond) = elapsedTime;
                    end
                end
            end
            Screen('DrawDots',c.display.windowPtr,c.fixpt.pos,c.fixpt.size,[255 0 0]);
            Screen('Flip',c.display.windowPtr);
            
            %Update time counter and check whether time is up
            t = GetSecs - t0;
            runStim = t < c.time.totaldur;

        else %if escaped, end the stimulus 
            c.display.open = false;
            c.recorded.escaped = true;
            runStim = false;  %to break out of this while loop
            sca;
        end
    end
    c.recorded.stimEnd = GetSecs - t0;
    c.recorded.stimStart = c.recorded.onsets(1);
    c.recorded.stimDurtn = c.recorded.stimEnd - c.recorded.stimStart;
catch myerr
    %this "catch" section executes in case of an error in the "try" section
    %above.  Importantly, it closes the onscreen window if its open.
    sca;
    commandwindow;
    myerr.message
    myerr.stack.line
    
end %try..catch.

