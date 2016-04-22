function c = makeRetinotopyFixationMark(c)

c.fixpt.pos = myPix([0 0],[],c.display);
c.fixpt.size = myPix([],[c.fixpt.sizeDeg],c.display);

angles = [0 90];
allxy = [];
for ai = 1:2
    startxy = myPix([0 0]-0.5*c.fixpt.sizeDeg*[cosd(angles(ai)) sind(angles(ai))],[],c.display);
    endxy = myPix([0 0]+0.5*c.fixpt.sizeDeg*[cosd(angles(ai)) sind(angles(ai))],[],c.display);
    newxy = [startxy' endxy'];
    allxy = [allxy newxy];
end
c.fixpt.allxy = allxy;