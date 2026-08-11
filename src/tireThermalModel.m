function T = tireThermalModel(time_s,speed_kph,qdot_W,p)
%TIRETHERMALMODEL One-state effective tire thermal model with speed cooling.

n = numel(time_s);
T = zeros(n,1);
T(1) = p.T0_C;
v = max(speed_kph/3.6,0);

for i = 2:n
    dt = time_s(i)-time_s(i-1);
    if ~isfinite(dt) || dt <= 0
        dt = 0.01;
    end
    hA = p.hA0_WK + p.hA1_WK_per_v08 * v(i-1)^0.8;
    qConv = hA*(T(i-1)-p.Tambient_C);
    qTrack = p.kTrack_WK*(p.Ttrack_C-T(i-1));
    dTdt = (qdot_W(i-1)-qConv+qTrack)/(p.mass_kg*p.cp_JkgK);
    T(i) = T(i-1)+dTdt*dt;
end
end
