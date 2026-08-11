clear; clc; close all;
scriptFolder=fileparts(mfilename("fullpath")); root=fileparts(scriptFolder);
addpath(fullfile(root,"src"));
dataFolder=fullfile(root,"data","processed");
resultsFolder=fullfile(root,"results"); figuresFolder=fullfile(root,"figures");
if ~exist(resultsFolder,"dir"); mkdir(resultsFolder); end
if ~exist(figuresFolder,"dir"); mkdir(figuresFolder); end

circuits={"Bahrain","bahrain.csv";"Monaco","monaco.csv";"Monza","monza.csv";"Silverstone","silverstone.csv";"Suzuka","suzuka.csv"};
p0=defaultParams();
D=struct();
for i=1:size(circuits,1)
    c=circuits{i,1}; f=fullfile(dataFolder,circuits{i,2});
    if ~isfile(f); error("Missing %s. Re-run extract_f1_telemetry.py",f); end
    D.(char(c))=preprocessTelemetry(loadTelemetry(f),p0);
end

fprintf("1/6 Baseline v2...\n");
base=runAll(D,circuits,p0,"Baseline");
writetable(base,fullfile(resultsFolder,"v2_baseline.csv"));

fprintf("2/6 Full OAT sensitivity...\n");
sens=table();
tests={
"thermalCapacity_low","cp_JkgK",p0.cp_JkgK*0.75;
"thermalCapacity_high","cp_JkgK",p0.cp_JkgK*1.25;
"coolingBase_low","hA0_WK",p0.hA0_WK*0.70;
"coolingBase_high","hA0_WK",p0.hA0_WK*1.30;
"coolingSpeed_low","hA1_WK_per_v08",p0.hA1_WK_per_v08*0.70;
"coolingSpeed_high","hA1_WK_per_v08",p0.hA1_WK_per_v08*1.30;
"trackExchange_low","kTrack_WK",p0.kTrack_WK*0.50;
"trackExchange_high","kTrack_WK",p0.kTrack_WK*1.50;
"Topt_low","Topt_C",p0.Topt_C-10;
"Topt_high","Topt_C",p0.Topt_C+10;
"sigma_low","sigmaT_C",p0.sigmaT_C*0.75;
"sigma_high","sigmaT_C",p0.sigmaT_C*1.25;
"residual_low","residualGripFraction",0.75;
"residual_high","residualGripFraction",0.90};
for i=1:size(tests,1)
    p=p0; p.(tests{i,2})=tests{i,3};
    sens=[sens;runAll(D,circuits,p,string(tests{i,1}))]; %#ok<AGROW>
end
for hs=[0.75 1.25]
    p=p0; p.kBrake=p0.kBrake*hs; p.kTraction=p0.kTraction*hs; p.kLateral=p0.kLateral*hs;
    sens=[sens;runAll(D,circuits,p,"heatScale_"+string(hs))]; %#ok<AGROW>
end
writetable(sens,fullfile(resultsFolder,"v2_parameter_sensitivity_full.csv"));

% Rank stability vs baseline
fprintf("3/6 Rank stability...\n");
rankRows=table(); baseOrder=rankVector(base);
scenarios=unique(sens.Scenario);
for i=1:numel(scenarios)
    sub=sens(sens.Scenario==scenarios(i),:);
    tau=kendallPermutationTau(baseOrder,rankVector(sub));
    [~,idx]=sort(sub.ModeledGripDeficit_s,"descend");
    ordering=strjoin(cellstr(sub.Circuit(idx)),">");
    rankRows=[rankRows;table(scenarios(i),tau,string(ordering),'VariableNames',{'Scenario','KendallTauVsBaseline','Ordering'})]; %#ok<AGROW>
end
writetable(rankRows,fullfile(resultsFolder,"v2_rank_stability.csv"));

fprintf("4/6 Shared-draw Monte Carlo...\n");
rng(42); N=2000;
% Shared random draws: identical parameter realization j is used for every circuit.
Z=randn(N,7);
% Lognormal multipliers with median 1 for strictly positive quantities.
mult=@(z,sig) exp(sig*z);
P=table;
P.cpMult=mult(Z(:,1),0.12);
P.hA0Mult=mult(Z(:,2),0.20);
P.hA1Mult=mult(Z(:,3),0.20);
P.kTrackMult=mult(Z(:,4),0.25);
P.Topt_C=p0.Topt_C+5*Z(:,5);
P.sigmaMult=mult(Z(:,6),0.12);
P.heatMult=mult(Z(:,7),0.15);
writetable(P,fullfile(resultsFolder,"v2_mc_parameter_draws.csv"));

pen=zeros(N,size(circuits,1)); pct=pen; spkm=pen;
for j=1:N
    p=p0; p.cp_JkgK=p0.cp_JkgK*P.cpMult(j); p.hA0_WK=p0.hA0_WK*P.hA0Mult(j); p.hA1_WK_per_v08=p0.hA1_WK_per_v08*P.hA1Mult(j);
    p.kTrack_WK=p0.kTrack_WK*P.kTrackMult(j); p.Topt_C=P.Topt_C(j); p.sigmaT_C=p0.sigmaT_C*P.sigmaMult(j);
    p.kBrake=p0.kBrake*P.heatMult(j); p.kTraction=p0.kTraction*P.heatMult(j); p.kLateral=p0.kLateral*P.heatMult(j);
    for i=1:size(circuits,1)
        c=circuits{i,1}; s=summarizeSimulation(runSimulation(D.(char(c)),p),D.(char(c)),p);
        pen(j,i)=s.ModeledGripDeficit_s; pct(j,i)=s.DeficitPctLap; spkm(j,i)=s.Deficit_s_per_km;
    end
end
names=string(circuits(:,1));
T=array2table(pen,'VariableNames',cellstr(names)); writetable(T,fullfile(resultsFolder,"v2_mc_penalty_samples.csv"));
T=array2table(pct,'VariableNames',cellstr(names)); writetable(T,fullfile(resultsFolder,"v2_mc_percent_samples.csv"));
T=array2table(spkm,'VariableNames',cellstr(names)); writetable(T,fullfile(resultsFolder,"v2_mc_s_per_km_samples.csv"));

mc=table();
for i=1:numel(names)
    q=percentile(pen(:,i),[2.5 50 97.5]);
    mc=[mc;table(names(i),mean(pen(:,i)),q(1),q(2),q(3),mean(pct(:,i)),mean(spkm(:,i)), ...
        'VariableNames',{'Circuit','MeanDeficit_s','P2_5_s','Median_s','P97_5_s','MeanPctLap','Mean_s_per_km'})]; %#ok<AGROW>
end
writetable(mc,fullfile(resultsFolder,"v2_mc_summary.csv"));

% Paired differences and probabilities.
pairs=table();
for a=1:numel(names)-1
    for b=a+1:numel(names)
        d=pen(:,a)-pen(:,b); q=percentile(d,[2.5 50 97.5]); prob=mean(d>0); se=sqrt(prob*(1-prob)/N);
        pairs=[pairs;table(names(a),names(b),mean(d),q(1),q(2),q(3),prob,se, ...
            'VariableNames',{'CircuitA','CircuitB','MeanDifference_s','P2_5_s','MedianDifference_s','P97_5_s','P_A_gt_B','ProbabilitySE'})]; %#ok<AGROW>
    end
end
writetable(pairs,fullfile(resultsFolder,"v2_mc_paired_differences.csv"));

% Standardized regression coefficients as low-cost global sensitivity screen.
fprintf("5/6 Global sensitivity screen...\n");
X=[P.cpMult P.hA0Mult P.hA1Mult P.kTrackMult P.Topt_C P.sigmaMult P.heatMult];
Xz=(X-mean(X,1))./std(X,0,1); params=["ThermalCapacity","CoolingBase","CoolingSpeed","TrackExchange","Topt","Sigma","HeatScale"];
src=table();
for i=1:numel(names)
    y=(pen(:,i)-mean(pen(:,i)))./std(pen(:,i)); beta=Xz\y;
    for k=1:numel(params)
        src=[src;table(names(i),params(k),beta(k),'VariableNames',{'Circuit','Parameter','SRC'})]; %#ok<AGROW>
    end
end
writetable(src,fullfile(resultsFolder,"v2_standardized_sensitivity.csv"));

fprintf("6/6 Figures and manifest...\n");
f1=figure; bar(categorical(base.Circuit),base.DeficitPctLap); ylabel("Modeled grip deficit (% of telemetry-integrated lap)"); xlabel("Circuit"); title("TireTwin v2 — Normalized Baseline Deficit"); grid on; exportgraphics(f1,fullfile(figuresFolder,"v2_baseline_percent_lap.png"),'Resolution',300);
f2=figure; x=1:height(mc); med=mc.Median_s; lo=med-mc.P2_5_s; hi=mc.P97_5_s-med; errorbar(x,med,lo,hi,'o','LineWidth',1.3); xlim([0.5 height(mc)+0.5]); xticks(x); xticklabels(mc.Circuit); ylabel("Modeled grip deficit (s)"); xlabel("Circuit"); title("Shared-Parameter Monte Carlo Intervals"); grid on; exportgraphics(f2,fullfile(figuresFolder,"v2_mc_intervals.png"),'Resolution',300);

manifest=struct; manifest.generated_at=char(datetime('now','Format','yyyy-MM-dd HH:mm:ss Z')); manifest.matlab_version=version; manifest.seed=42; manifest.mc_samples=N; manifest.parameters=p0; [st,out]=system('git rev-parse HEAD'); if st==0; manifest.git_hash=strtrim(out); else; manifest.git_hash='not_available'; end; manifest.toolbox_versions={ver().Name};
fid=fopen(fullfile(resultsFolder,"v2_run_manifest.json"),'w'); fwrite(fid,jsonencode(manifest,'PrettyPrint',true)); fclose(fid);

fprintf("\nDONE — TireTwin v2 outputs generated.\n");
fprintf("Interpret the metric as an idealized modeled thermal-grip deficit, not seconds actually lost to tire temperature.\n");

function R=runAll(D,circuits,p,scenario)
R=table();
for k=1:size(circuits,1)
    c=circuits{k,1}; tbl=D.(char(c)); sim=runSimulation(tbl,p); s=summarizeSimulation(sim,tbl,p);
    row=table(string(scenario),string(c),height(tbl),s.ObservedLapTime_s,s.ThermalLapTime_s,s.ModeledGripDeficit_s,s.DeficitPctLap,s.Deficit_s_per_km,s.PeakEffectiveState_C,s.MeanEffectiveState_C,s.PercentInNominalWindow,s.MeanMuRatio,s.MinMuRatio,s.MaxGripLossPct,s.AirTemp_C,s.TrackTemp_C,s.Iterations,s.Converged, ...
    'VariableNames',{'Scenario','Circuit','Samples','ObservedLapTime_s','IdealizedThermalLap_s','ModeledGripDeficit_s','DeficitPctLap','Deficit_s_per_km','PeakEffectiveState_C','MeanEffectiveState_C','PercentInNominalWindow','MeanMuRatio','MinMuRatio','MaxGripLossPct','AirTemp_C','TrackTemp_C','Iterations','Converged'});
    R=[R;row]; %#ok<AGROW>
end
end
function r=rankVector(T)
[~,ord]=sort(T.ModeledGripDeficit_s,'descend'); r=zeros(height(T),1); r(ord)=1:height(T); [~,idx]=sort(T.Circuit); r=r(idx);
end
function tau=kendallPermutationTau(a,b)
n=numel(a); c=0; d=0; for i=1:n-1; for j=i+1:n; s=sign((a(i)-a(j))*(b(i)-b(j))); if s>0; c=c+1; elseif s<0; d=d+1; end; end; end; tau=(c-d)/(n*(n-1)/2);
end
function q=percentile(x,pct)
x=sort(x(:)); n=numel(x); q=zeros(size(pct)); for ii=1:numel(pct); pos=1+(n-1)*pct(ii)/100; lo=floor(pos); hi=ceil(pos); if lo==hi; q(ii)=x(lo); else; q(ii)=x(lo)+(pos-lo)*(x(hi)-x(lo)); end; end
end
