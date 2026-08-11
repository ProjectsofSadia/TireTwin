function lapTime_s = calculateLapTime(distance_m,speed_kph)
v = speed_kph/3.6;
ds = diff(distance_m);
vmid = 0.5*(v(1:end-1)+v(2:end));
valid = isfinite(ds)&isfinite(vmid)&ds>0&vmid>0;
lapTime_s = sum(ds(valid)./vmid(valid));
end
