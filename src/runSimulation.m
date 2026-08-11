function sim = runSimulation(tbl,p)
%RUNSIMULATION Fixed-point coupled thermal/performance simulation.

% Event-specific weather when available.
if ismember("AirTemp_C",string(tbl.Properties.VariableNames)) && isfinite(tbl.AirTemp_C(1))
    p.Tambient_C = tbl.AirTemp_C(1);
end
if ismember("TrackTemp_C",string(tbl.Properties.VariableNames)) && isfinite(tbl.TrackTemp_C(1))
    p.Ttrack_C = tbl.TrackTemp_C(1);
end

baseSpeed = tbl.SpeedSmooth;
workingSpeed = baseSpeed;
baseLap = calculateLapTime(tbl.Distance,baseSpeed);
prevDeficit = inf;
converged = false;

for iter = 1:p.maxIterations
    v = workingSpeed/3.6;
    ds = [0; diff(tbl.Distance)];
    dt = ds./max(v,1);
    time = cumsum(dt);
    qdot = estimateEnergyInput(tbl,workingSpeed,p);
    T = tireThermalModel(time,workingSpeed,qdot,p);
    [mu,ratio] = gripModel(T,p);
    newSpeed = vehiclePerformanceModel(tbl,baseSpeed,ratio,p);
    thermalLap = calculateLapTime(tbl.Distance,newSpeed);
    deficit = thermalLap-baseLap;
    if abs(deficit-prevDeficit) < p.convergenceTol_s
        converged = true;
        workingSpeed = newSpeed;
        break;
    end
    workingSpeed = newSpeed;
    prevDeficit = deficit;
end

% Final state at converged/last speed.
v = workingSpeed/3.6;
ds = [0; diff(tbl.Distance)];
time = cumsum(ds./max(v,1));
qdot = estimateEnergyInput(tbl,workingSpeed,p);
T = tireThermalModel(time,workingSpeed,qdot,p);
[mu,ratio] = gripModel(T,p);
finalSpeed = vehiclePerformanceModel(tbl,baseSpeed,ratio,p);
thermalLap = calculateLapTime(tbl.Distance,finalSpeed);

sim = table(tbl.Distance,baseSpeed,finalSpeed,qdot,T,mu,ratio, ...
    'VariableNames',{'Distance','SpeedObserved_kph','SpeedThermal_kph','HeatInputProxy_W', ...
    'EffectiveThermalState_C','MuEffective','MuRatio'});
sim.ObservedLapTime_s = repmat(baseLap,height(tbl),1);
sim.ThermalLapTime_s = repmat(thermalLap,height(tbl),1);
sim.Iterations = repmat(iter,height(tbl),1);
sim.Converged = repmat(converged,height(tbl),1);
end
