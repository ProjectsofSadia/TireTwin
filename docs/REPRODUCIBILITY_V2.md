# TireTwin v2 Reproducibility

## 1. Extract telemetry

From PowerShell in the project root:

```powershell
py -3.12 -m pip install -r requirements.txt
py -3.12 extract_f1_telemetry.py
```

This regenerates all five CSVs with X/Y position and event-specific weather and writes `data/processed/telemetry_manifest_v2.csv`.

## 2. Verify the model

In MATLAB:

```matlab
run("tests/runModelChecks.m")
```

Expected:

```text
Running TireTwin v2 checks...
All TireTwin v2 checks passed.
```

## 3. Run the full analysis

```matlab
run("experiments/runResearchAnalysisV2.m")
```

The script saves baseline, complete OAT sensitivity, rank stability, common-draw Monte Carlo inputs, full Monte Carlo circuit samples, paired circuit differences, standardized sensitivity coefficients, 300 dpi figures, and a run manifest containing MATLAB/version/toolbox/seed/git information.
