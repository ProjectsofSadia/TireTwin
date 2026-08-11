clear; clc; close all;
addpath("src");
p=defaultParams();
telemetryFile="";
if strlength(telemetryFile)>0 && isfile(telemetryFile)
    tbl=loadTelemetry(telemetryFile);
else
    fprintf("No telemetry file configured; using synthetic verification data.\n");
    tbl=generateSyntheticTelemetry();
end
tbl=preprocessTelemetry(tbl,p);
sim=runSimulation(tbl,p);
s=summarizeSimulation(sim,tbl,p);
disp(s);
