clear; clc;
testFolder=fileparts(mfilename("fullpath")); projectRoot=fileparts(testFolder);
addpath(fullfile(projectRoot,"src"));
fprintf("Running TireTwin v2 checks...\n");
p=defaultParams();

% 1. Curvature recovery on synthetic circle.
tbl=preprocessTelemetry(generateSyntheticTelemetry(),p);
expected=1/800;
med=median(abs(tbl.Curvature_1pm(50:end-50)));
assert(abs(med-expected)/expected < 0.15,"Curvature test failed.");

% 2. Lateral acceleration is non-zero around a constant-radius path.
assert(median(tbl.AbsLatAccel_mps2)>0.1,"Lateral acceleration test failed.");

% 3. Cooling test.
time=(0:0.5:120)'; speed=150*ones(size(time)); q=zeros(size(time));
p1=p; p1.T0_C=100; p1.Tambient_C=20; p1.Ttrack_C=20;
T=tireThermalModel(time,speed,q,p1);
assert(T(end)<T(1),"Cooling test failed.");

% 4. Residual grip is smooth and never below residual fraction.
[~,ratio]=gripModel([p.Topt_C; p.Topt_C+100],p);
assert(abs(ratio(1)-1)<1e-12,"Grip optimum failed.");
assert(ratio(2)>=p.residualGripFraction-1e-12,"Residual grip failed.");

% 5. Coupled simulation converges and deficit is non-negative by definition.
sim=runSimulation(tbl,p);
s=summarizeSimulation(sim,tbl,p);
assert(s.Converged,"Fixed-point solver failed to converge.");
assert(s.ModeledGripDeficit_s>=-1e-9,"Deficit sign test failed.");

fprintf("All TireTwin v2 checks passed.\n");
