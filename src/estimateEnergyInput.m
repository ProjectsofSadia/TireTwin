function qdot = estimateEnergyInput(tbl,speed_kph,p)
%ESTIMATEENERGYINPUT Telemetry-derived load proxy, not measured tire heat flow.

v = speed_kph/3.6;
dvds = gradient(v,p.gridSpacing_m);
ax = v.*dvds;
ay = abs(v.^2 .* tbl.Curvature_1pm);
thr = tbl.Throttle/100;
brk = double(tbl.Brake>0);

% Magnitude-aware braking and traction terms; separate lateral channel.
qBrake = p.kBrake .* brk .* max(-ax,0) .* v;
qTraction = p.kTraction .* thr .* max(ax,0) .* v;
qLateral = p.kLateral .* ay .* v;
qdot = max(qBrake + qTraction + qLateral,0);
end
