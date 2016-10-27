function JengaTowerScat(Px,Py)
%Building jenga tower from scattered blocks
%Assumes conveyor is empty

%starting coordinates of the tower
xj = 100;
yj = 100;
zj = 154.82;
zp = zj;

%coordinates to move to the next level
xj1 = xj+37;
yj1 = yj+12.5;

currentblocks = 0;
totalblocks = length(Px);
jengacounter = 1;
Pzz = 154.82;

while currentblocks < totalblocks
    xp = xj;
    yp = yj;
    for i = 1:3
        if currentblocks == totalblocks
            break;
        end
        Pxx = Px(jengacounter);
        Pyy = Py(jengacounter);   
        StringName=sprintf('C MF %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Pxx,Pyy,Pzz,rad2deg(orie(i)),xp,yp,zp,v);
        fwrite(socket, StringName);
        yp = yp + 25;
        currentblocks = currentblocks + 1;
        jengacounter = jengacounter + 1;
    end
    xp = xj1;
    yp = yj1;
    zp = zp + 14.5;
    for i = 1:3
        if currentblocks == totalblocks
            break;
        end
        Pxx = Px(jengacounter);
        Pyy = Py(jengacounter);
        StringName=sprintf('C MF %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Pxx,Pyy,Pzz,rad2deg(orie(i))+90,xp,yp,zp,v);
        fwrite(socket, StringName);
        xp = xp + 25;
        currentblocks = currentblocks + 1;
        jengacounter = jengacounter + 1;
    end
    zp = zp + 14.5;
end