function speedNew_kph = vehiclePerformanceModel(tbl,baseSpeed_kph,muRatio,p)
%VEHICLEPERFORMANCEMODEL Idealized thermal-grip deficit relative to base trace.
% Weight only by actual lateral acceleration demand from track curvature.

v = baseSpeed_kph/3.6;
ay = abs(v.^2 .* tbl.Curvature_1pm);
% Demand weighting is bounded and dimensionless. 1 g corresponds to weight 1.
weight = min(1,ay/9.81);
gripScale = sqrt(max(muRatio,eps));
scale = 1 - weight.*(1-gripScale);
speedNew_kph = max(baseSpeed_kph.*scale,p.minSpeed_kph);
end
