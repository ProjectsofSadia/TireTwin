function s = summarizeSimulation(sim,tbl,p)
%SUMMARIZESIMULATION Paper-facing metrics.
s.ObservedLapTime_s = sim.ObservedLapTime_s(1);
s.ThermalLapTime_s = sim.ThermalLapTime_s(1);
s.ModeledGripDeficit_s = s.ThermalLapTime_s-s.ObservedLapTime_s;
s.DeficitPctLap = 100*s.ModeledGripDeficit_s/s.ObservedLapTime_s;
length_km = (sim.Distance(end)-sim.Distance(1))/1000;
s.Deficit_s_per_km = s.ModeledGripDeficit_s/length_km;
s.PeakEffectiveState_C = max(sim.EffectiveThermalState_C);
s.MeanEffectiveState_C = mean(sim.EffectiveThermalState_C);
s.StdEffectiveState_C = std(sim.EffectiveThermalState_C);
lo = p.Topt_C-p.sigmaT_C;
hi = p.Topt_C+p.sigmaT_C;
s.PercentInNominalWindow = 100*mean(sim.EffectiveThermalState_C>=lo & sim.EffectiveThermalState_C<=hi);
s.MeanMuRatio = mean(sim.MuRatio);
s.MinMuRatio = min(sim.MuRatio);
s.MaxGripLossPct = 100*(1-s.MinMuRatio);
s.Iterations = sim.Iterations(1);
s.Converged = sim.Converged(1);
if ismember("AirTemp_C",string(tbl.Properties.VariableNames)); s.AirTemp_C=tbl.AirTemp_C(1); else; s.AirTemp_C=p.Tambient_C; end
if ismember("TrackTemp_C",string(tbl.Properties.VariableNames)); s.TrackTemp_C=tbl.TrackTemp_C(1); else; s.TrackTemp_C=p.Ttrack_C; end
end
