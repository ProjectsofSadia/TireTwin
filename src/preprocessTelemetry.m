function tbl = preprocessTelemetry(tbl,p)
%PREPROCESSTELEMETRY Resample all circuits onto the same physical distance grid.

if nargin < 2
    p = defaultParams();
end

tbl = sortrows(tbl,"Distance");
valid = isfinite(tbl.Distance) & isfinite(tbl.Speed) & isfinite(tbl.Time) & ...
        isfinite(tbl.X) & isfinite(tbl.Y);
tbl = tbl(valid,:);
[~,ia] = unique(tbl.Distance,"stable");
tbl = tbl(ia,:);

s = (ceil(min(tbl.Distance)):p.gridSpacing_m:floor(max(tbl.Distance)))';
if numel(s) < 100
    error("Insufficient telemetry distance range after cleaning.");
end

out = table;
out.Distance = s;
continuous = ["Time","Speed","Throttle","RPM","X","Y"];
for c = continuous
    out.(c) = interp1(tbl.Distance,tbl.(c),s,"linear","extrap");
end

discrete = ["Brake","Gear","DRS"];
for c = discrete
    out.(c) = interp1(tbl.Distance,double(tbl.(c)),s,"nearest","extrap");
end

% Preserve event weather as constant per-lap metadata when present.
for c = ["AirTemp_C","TrackTemp_C"]
    if ismember(c,string(tbl.Properties.VariableNames))
        vals = tbl.(c);
        vals = vals(isfinite(vals));
        if isempty(vals); val = NaN; else; val = median(vals); end
        out.(c) = repmat(val,height(out),1);
    end
end

speedWin = max(3,round(p.speedSmoothWindow_m/p.gridSpacing_m));
posWin = max(5,round(p.positionSmoothWindow_m/p.gridSpacing_m));
out.SpeedSmooth = movmean(out.Speed,speedWin,"omitnan");
out.XSmooth = movmean(out.X,posWin,"omitnan");
out.YSmooth = movmean(out.Y,posWin,"omitnan");

% FastF1 XY units are rescaled so XY path length agrees with telemetry distance.
dxy = hypot(diff(out.XSmooth),diff(out.YSmooth));
rawArc = sum(dxy(isfinite(dxy)));
trackLength = out.Distance(end)-out.Distance(1);
if rawArc <= 0 || ~isfinite(rawArc)
    error("Invalid XY path geometry.");
end
scale = trackLength/rawArc;
x = (out.XSmooth-out.XSmooth(1))*scale;
y = (out.YSmooth-out.YSmooth(1))*scale;

% Curvature with distance as the independent variable.
dx = gradient(x,p.gridSpacing_m);
dy = gradient(y,p.gridSpacing_m);
d2x = gradient(dx,p.gridSpacing_m);
d2y = gradient(dy,p.gridSpacing_m);
den = (dx.^2 + dy.^2).^(3/2);
kappa = zeros(size(den));
mask = den > 1e-8;
kappa(mask) = (dx(mask).*d2y(mask)-dy(mask).*d2x(mask))./den(mask);

v = out.SpeedSmooth/3.6;
dvds = gradient(v,p.gridSpacing_m);
out.LongAccel_mps2 = v.*dvds;
out.Curvature_1pm = kappa;
out.LatAccel_mps2 = v.^2 .* kappa;
out.AbsLatAccel_mps2 = abs(out.LatAccel_mps2);
out.Brake = double(out.Brake > 0);
out.Throttle = max(0,min(100,out.Throttle));
out.X_m = x;
out.Y_m = y;

tbl = out;
end
