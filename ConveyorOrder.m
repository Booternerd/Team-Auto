function ConveyorOrder(order,Px,Py,orie)
%Fufill order to conveyor
%Assume conveyor is empty

Pxcb = box.b(1);
Pycb = box.b(2);
conveyorcounter = 1;
Pzz = 154;

for i=1:4
    zp = 37;
    %zp = box.z
    xp = Pxcb(i);
    yp = Pycb(i);
    if order(i) > 0                           
        for j=1:order(i)
            Pxx = Px(conveyorcounter);
            Pyy = Py(conveyorcounter);
            StringName=sprintf('C MF %.2f %.2f %.2f %.2f %.2f %.2f %.2f %.2f',Pxx,Pyy,Pzz,rad2deg(orie(i) + box.b(4)),xp,yp,zp,v);
            fwrite(socket, StringName);
        conveyorcounter = conveyorcounter + 1;
        zp = zp + 14.5;
        end
    end
end