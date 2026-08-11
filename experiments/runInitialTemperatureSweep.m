clear; clc; close all; addpath("src");
tbl = preprocessTelemetry(generateSyntheticTelemetry());
base = defaultParams();
vals = [60 70 80 90 100]';
rows = table();

for T0 = vals'
    p=base; p.T0_C=T0;
    s=summarizeSimulation(runSimulation(tbl,p),p);
    rows=[rows; table(T0,s.PeakTemperature_C,s.MeanTemperature_C, ...
        s.PercentInThermalWindow,s.MeanMu,s.LapTimePenalty_s, ...
        'VariableNames',{'T0_C','PeakTemp_C','MeanTemp_C','PercentInWindow','MeanMu','LapTimePenalty_s'})]; %#ok<AGROW>
end

if ~exist("results","dir"); mkdir("results"); end
if ~exist("figures","dir"); mkdir("figures"); end
writetable(rows,"results/initial_temperature_sweep.csv");
figure; plot(rows.T0_C,rows.LapTimePenalty_s,"-o","LineWidth",1.3);
xlabel("Initial Temperature (°C)"); ylabel("Modeled Lap-Time Penalty (s)");
title("Initial Temperature Sensitivity"); grid on;
saveas(gcf,"figures/initial_temperature_sensitivity.png");
disp(rows);
