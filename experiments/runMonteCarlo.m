clear; clc; close all; addpath("src");
rng(7);
tbl = preprocessTelemetry(generateSyntheticTelemetry());
base=defaultParams();
N=1000;
penalty=zeros(N,1);

for i=1:N
    p=base;
    p.Topt_C=base.Topt_C+4*randn;
    p.sigmaT_C=max(5,base.sigmaT_C+2*randn);
    p.hA_WK=max(5,base.hA_WK*(1+0.15*randn));
    p.cp_JkgK=max(500,base.cp_JkgK*(1+0.10*randn));
    p.muMax=max(0.8,base.muMax*(1+0.05*randn));

    s=summarizeSimulation(runSimulation(tbl,p),p);
    penalty(i)=s.LapTimePenalty_s;
end

if ~exist("results","dir"); mkdir("results"); end
if ~exist("figures","dir"); mkdir("figures"); end
writetable(table((1:N)',penalty,'VariableNames',{'Run','LapTimePenalty_s'}), ...
    "results/monte_carlo.csv");

q=prctile(penalty,[2.5 50 97.5]);
fprintf("2.5%% %.4f s | Median %.4f s | 97.5%% %.4f s\n",q(1),q(2),q(3));

figure; histogram(penalty,35);
xlabel("Modeled Lap-Time Penalty (s)"); ylabel("Count");
title("Monte Carlo Uncertainty Distribution"); grid on;
saveas(gcf,"figures/monte_carlo_distribution.png");
