function tbl = generateSyntheticTelemetry()
%GENERATESYNTHETICTELEMETRY Deterministic circular-track verification data.
rng(42);
R = 800;
L = 2*pi*R;
distance = (0:5:L)';
theta = distance/R;
X = R*cos(theta);
Y = R*sin(theta);
speed = 180 + 20*sin(3*theta) - 10*sin(7*theta);
v=speed/3.6;
time=cumsum([0;diff(distance)./max(v(1:end-1),1)]);
brake=double(gradient(speed)<-0.5);
throttle=100*ones(size(speed)); throttle(brake>0)=20;
rpm=7000+20*speed; gear=max(1,min(8,round(speed/35))); drs=zeros(size(speed));
AirTemp_C=25*ones(size(speed)); TrackTemp_C=40*ones(size(speed));
tbl=table(time,distance,speed,throttle,brake,rpm,gear,drs,X,Y,AirTemp_C,TrackTemp_C, ...
'VariableNames',{'Time','Distance','Speed','Throttle','Brake','RPM','Gear','DRS','X','Y','AirTemp_C','TrackTemp_C'});
end
