function c = makeRetinotopyFixationMark(c)

%January, 2017: fixation mark is now a dot with a ring around it. The subject must detect
%dimming of the inner dot. 
%The outer ring around it is for giving feedback: turns colors. 


c.fixpt.pos = myPix([0 0],[],c.display);
c.fixpt.innerSize = myPix([],[c.fixpt.diameter],c.display);
c.fixpt.ringRect =  myPix([0 0],c.fixpt.ringDiameter([1 1]),c.display);

% angles = [0 90];
% allxy = [];
% for ai = 1:2
%     startxy = myPix([0 0]-0.5*c.fixpt.sizeDeg*[cosd(angles(ai)) sind(angles(ai))],[],c.display);
%     endxy = myPix([0 0]+0.5*c.fixpt.sizeDeg*[cosd(angles(ai)) sind(angles(ai))],[],c.display);
%     newxy = [startxy' endxy'];
%     allxy = [allxy newxy];
% end
% c.fixpt.allxy = allxy;


