function [img mask stim] = myMakeImg(stim,display,SFincrement)
% [img mask stim] = myMakeImg(stim,display [,SFincrement])

% stim=c.stim;display=c.display;
if nargin < 1
    help myMakeImg
    return
end
if nargin < 3
    SFincrement = 0;
    % if defined, creates 2 gratings of different SF and masks the
    % transition
end

% set defaults
if ~isfield(stim.carrier,'phase')
    stim.carrier.phase = 0;
end
if ~isfield(stim.envelope,'type')
    stim.envelope.type = 'square';
end  
if strcmp(stim.carrier.type,'squarewave')
    stim.carrier.type = 'grating';
    dorounding = 1;
end


% make basis fun
dims = stim.envelope.basesize/2;
npix = myPix([],stim.envelope.basesize,display)+1;
[x y] = meshgrid( linspace(-dims(1),dims(1),npix(1)) , linspace(-dims(2),dims(2),npix(2)) );

% compute carrier image
a = cos(deg2rad(-stim.carrier.tilt-90)) * 2*pi * stim.carrier.SF;
b = sin(deg2rad(-stim.carrier.tilt-90)) * 2*pi * stim.carrier.SF;


switch stim.carrier.type
    case 'flat' % dark if phase < 0
        img = (x*0 + y*0) + double(stim.carrier.phase > 0);
    case 'grating'
        img = sin(a*x + b*y + deg2rad(stim.carrier.phase)) * .5 + .5 ;
        if SFincrement
            a2 = cos(deg2rad(-stim.carrier.tilt-90)) * 2*pi * (stim.carrier.SF+SFincrement);
            b2 = sin(deg2rad(-stim.carrier.tilt-90)) * 2*pi * (stim.carrier.SF+SFincrement);
            img2 = sin(a2*x + b2*y + deg2rad(stim.carrier.phase)) * .5 + .5 ;
            img = img .* (y>0) + img2 .* (y<=0);
        end
end
if exist('dorounding','var')
    img = round(img);
end

% compute trasparency mask
switch stim.envelope.type
    case 'square'
        mask = img*0+1;
    case 'oval'
        mask = abs(x/dims(1)).^2 + abs(y/dims(2)).^2 < 1;
    case 'gauss'
        sd = dims/3; % std of the Gaussian = 1/3 of the basis dimension
        mask = exp(-((x.^2)/(sd(1)^2) + (y.^2)/(sd(2)^2)));
end
if SFincrement
    sd = min(stim.carrier.SF)/2;
    masktransition = 1-exp(-((y.^2)/(sd^2)));
    mask = mask .* masktransition;
end

mask = double(mask);

% %%
% figure(1); clf
% % imagesc(masktransition)
% imagesc(img(:,:,1) .* mask)
% % imshow(img(:,:,1) .* mask)
% colorbar


% display.pxPERdeg = myPix([],1,display);
% 
% stim.basisdim_px = stim.basisdim .* display.pxPERdeg;
% stim.outline.size_px = stim.outline.size .* display.pxPERdeg;
% if length(stim.carrier.SF)<2, stim.carrier.SF(2) = stim.carrier.SF(1); end
% 
% dims = round(stim.basisdim_px/2);
% [x y] = meshgrid(-dims(1)+1:dims(1),-dims(2)+1:dims(2));
% 
% switch stim.carrier.type
%     case 'flat'
%         
%         img = (x*0 + y*0) + sign(stim.carrier.phase);
%         
%         stim.carrier.SF = NaN;
%         stim.carrier.tilt = NaN;
%         
%     case 'grating'
%         
%         stim.carrier.SF_px = stim.carrier.SF * 2*pi ./ display.pxPERdeg;
%         
%         a = cos(stim.carrier.tilt)*stim.carrier.SF_px(1);
%         b = sin(stim.carrier.tilt)*stim.carrier.SF_px(2);
%         
%         img = sin(a*x + b*y + stim.carrier.phase) ;
%         
%     case 'stripes'
%         
%         stim.carrier.SF_px = stim.carrier.SF * 2*pi ./ display.pxPERdeg;
%         
%         a = cos(stim.carrier.tilt)*stim.carrier.SF_px(1);
%         b = sin(stim.carrier.tilt)*stim.carrier.SF_px(2);
%         
%         img = sin(a*x + b*y + stim.carrier.phase) ;
%         img = sign(img);
%         
%     case 'checkerboard'
%         
%         stim.carrier.SF_px = stim.carrier.SF./ display.pxPERdeg;
%         
%         ncycles = ceil(stim.carrier.SF_px .* stim.basisdim_px);
%         img = paola_imresize(repmat(eye(2),ncycles),stim.basisdim_px,'nearest');
%         
%         img = [zeros(size(img,1),1) img];
%         img = [zeros(1,size(img,2)); img];
%         %         img = imresize(repmat(eye(2),ncycles),stim.basisdim_px,'box');
%         img = img';
%         minsize = [min([size(img,1),size(x,1)]) min([size(img,2),size(x,2)])];
%         disp([size(img) size(x)])
%         if ~all(size(img) == size(x))
%             img = img(1:size(x,1),1:size(x,2));
%         end
%         
%         if stim.carrier.phase<0
%             img = img == 0;
%         end
%         img = double(img)*2 - 1;
%         %         img(size(img,1)+1:size(base,1),size(img,2)+1:size(base,2)) = 1;
%         
%         
%     case 'checkerboard_M'
%         [x,y] = meshgrid(linspace(-1,1,sum(dims)));
%         
%         ang = atan2(y,x);
%         rad = sqrt(x.^2+y.^2);
%         
%         img = sign( sin(stim.carrier.nSubRing*ang/2).*sin(pi*stim.carrier.nSubWedge*rad) );
%         
%         if stim.carrier.phase<0, j = 1; else j = 2; end
%         img = ((-1)^j*img+1)*0.5; % scales between 0 and 1 + inverts polarity if phase<0
%         
%         
%         img = double(img)*2 - 1;
%         
% end
% 
% switch stim.outline.type
%     case 'rect'
%         
%         stim.outline.size_px = stim.outline.size_px/2;
%         mask = abs(x) <= stim.outline.size_px(1) & abs(y) <= stim.outline.size_px(2);
%         
%     case 'oval'
%         
%         stim.outline.size_px = stim.outline.size_px/2;
%         %             mask = (x.^2 + y.^2).^0.5 <= mean(stim.outline.size_px)/2;
%         mask = abs(x/stim.outline.size_px(1)).^2 + abs(y/stim.outline.size_px(2)).^2 < 1;
%         
%     case 'meridian'
%         
%         ang = atan2(y,x);
%         rad = sqrt(x.^2+y.^2);
%         
%         phase = stim.carrier.tilt;
%         mask = mod(ang-phase-pi + pi*stim.carrier.ringWidth/4 , 1*pi) < (2*pi*stim.carrier.ringWidth)/4;
%         mask(rad>1 | rad<stim.carrier.fixGap) = 0;
%         
%         img(rad < 0.0051) = 1;
%         mask(rad < 0.0051) = 1;
%         
%     case 'ring'
%         
%         rad = sqrt(x.^2+y.^2);
%         
%         phase = stim.carrier.tilt;
%         mask = mod(rad-phase,1) < stim.carrier.ringWidth;
%         mask(rad>1 | rad<stim.carrier.fixGap) = 0;
%         
%         img(rad < 0.0051) = 1;
%         mask(rad < 0.0051) = 1;
%         
%     case 'gauss'
%         
%         stim.outline.size_px = stim.outline.size_px/3;
%         
%         mask = exp(-((x.^2)/(stim.outline.size_px(1)^2) + (y.^2)/(stim.outline.size_px(2)^2)));
% end
% mask = double(mask);
% mat = img .* mask;
% mat = mat * stim.carrier.contrast ;
% 
% bkg = mean(display.bkColor);
% mat( mat > 0 ) = mat( mat > 0 ) * (255-bkg) + bkg ;
% mat( mat <= 0 ) = mat( mat <= 0 ) * bkg + bkg;
% 
% 
