function p = defaultParams()
%DEFAULTPARAMS Transparent development parameters for TireTwin v2.
% These are not proprietary Formula 1 tire parameters.

p.mass_kg = 10.0;
p.cp_JkgK = 1500.0;

% Speed-dependent convective cooling: hA = hA0 + hA1*v^0.8
p.hA0_WK = 12.0;
p.hA1_WK_per_v08 = 1.20;
p.kTrack_WK = 18.0;

% Fallback only; real telemetry files should carry event-specific weather.
p.Tambient_C = 25.0;
p.Ttrack_C = 40.0;
p.T0_C = 80.0;

% Smooth residual-friction model. No hard grip floor.
p.Topt_C = 95.0;
p.sigmaT_C = 30.0;
p.muMax = 1.70;
p.residualGripFraction = 0.80;

% Telemetry-derived heat-load proxy coefficients.
p.kBrake = 45.0;
p.kTraction = 20.0;
p.kLateral = 18.0;

% Preprocessing / solver settings.
p.gridSpacing_m = 1.0;
p.speedSmoothWindow_m = 15.0;
p.positionSmoothWindow_m = 21.0;
p.maxIterations = 8;
p.convergenceTol_s = 1e-3;
p.minSpeed_kph = 20.0;
end
