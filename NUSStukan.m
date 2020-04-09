%rosinit
pos = rossubscriber('turtle1/pose');
cont= rospublisher( '/turtle1/cmd_vel' );
msg = rosmessage( cont.MessageType );

msg.Linear.Y=0; %zerowaie na wszelki wypadek
msg.Linear.X=0;
msg.Angular.Z=0;
send(cont,msg);

k=0;
T=0;
clock = tic

%% Poruszanie sie po okrêgu
while T<4.2 & k==0    % mo¿na by zrobic w oparciu o dotarcie do punktu pocztatkowego
    T = toc(clock);    % obrót w okó³ osi , ale uzna³em ze tak bedzie wygodniej
    msg.Linear.X=4;
    msg.Angular.Z=2.4;
    send(cont,msg);
    if T>=4.1
        msg.Linear.Y=0;
        msg.Linear.X=0;
        msg.Angular.Z=0;
        send(cont,msg);
        k=1             % zeby z automatu przeszed³ do prostowania
    end
end

%% Wyprostowywanie / torche kiepskie bo nie chce dzia³ac na dowolny k¹t , tylko do 0.0
while k==1
    po= receive(pos,1)
         if (~po.Theta>-0.001 & ~po.Theta<0.001)
         msg.Angular.Z=-3*po.Theta;
         send(cont,msg);
         end
         if po.Theta>-0.001 & po.Theta<0.001
              msg.Angular.Z=0;
             k=2
         end
    send(cont,msg)
end

T=0;
clock = tic
while k==2 & T<1
    T = toc(clock);
    msg.Angular.Z=-1;
    send(cont,msg);
    if T>=0.9
        k=3
    end
end
msg.Linear.Y=0;
msg.Linear.X=0;
msg.Angular.Z=0;
send(cont,msg)
%% Pokonanie dowolnego odcinka na wprost
po= receive(pos,1)
Xp=po.X;
Yp=po.Y;
L=0
LL=2
while k==3
    po= receive(pos,1);
    L=sqrt((po.X-Xp)^2+(po.Y-Yp)^2)
    if L>=LL
       msg.Linear.X=0;
       send(cont,msg);
       k=4;
       break
    end
    msg.Linear.X=2;
    send(cont,msg);
end

%% Wyprostowywanie 
while k==4
    po= receive(pos,1)
         if (~po.Theta>-0.001 & ~po.Theta<0.001)
         msg.Angular.Z=-3*po.Theta;
         send(cont,msg);
         end
         if po.Theta>-0.001 & po.Theta<0.001
              msg.Angular.Z=0;
             k=5
         end
    send(cont,msg)
end

%% Pokonanie dowolnego odcinka na wprost
po= receive(pos,1)
Xp=po.X;
Yp=po.Y;
L=0
LL=2
while k==5
    po= receive(pos,1);
    L=sqrt((po.X-Xp)^2+(po.Y-Yp)^2)
    if L>=LL
       msg.Linear.X=0;
       send(cont,msg);
       break
    end
    msg.Linear.X=2;
    send(cont,msg);
end