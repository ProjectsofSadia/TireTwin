# TireTwin v2

## Uncertainty-Aware Tire Thermal-Grip Sensitivity Analysis Using Formula 1 Telemetry

TireTwin v2 is the corrected research implementation following an external audit of the original model. It uses real 2024 Formula 1 qualifying telemetry, event weather, track curvature, a transparent effective thermal model, a smooth residual-grip formulation, iterative thermal/performance coupling, and paired uncertainty analysis.

### What v2 fixes

- real curvature-based lateral acceleration instead of `v*dv/ds` mislabeled as lateral load;
- 1 m distance-domain resampling before smoothing;
- magnitude-aware braking load;
- speed-dependent cooling;
- no arbitrary hard grip clamp;
- iterative thermal-speed feedback;
- event-specific air/track temperatures;
- normalized outputs (% lap and s/km);
- common-random-number Monte Carlo with paired differences;
- saved full Monte Carlo samples and run metadata;
- full sensitivity/rank-stability reporting.

### Important interpretation

TireTwin does **not** predict measured Formula 1 tire temperature. It simulates an effective thermal state and reports an **idealized modeled thermal-grip deficit** relative to the telemetry-integrated baseline. The model is an engineering sensitivity framework, not a proprietary Formula 1 tire model.

## Run

```powershell
py -3.12 -m pip install -r requirements.txt
py -3.12 extract_f1_telemetry.py
```

Then in MATLAB:

```matlab
run("tests/runModelChecks.m")
run("experiments/runResearchAnalysisV2.m")
```

Do not publish v1 paper numbers as v2 results. The corrected model must be rerun before the final manuscript is generated.
