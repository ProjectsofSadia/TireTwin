# TireTwin

[![DOI](https://zenodo.org/badge/1330403416.svg)](https://doi.org/10.5281/zenodo.21959622)

## Modeling Tire Thermal Effects in Formula 1

TireTwin v2 is the corrected research implementation following an external audit of the original model. It uses real 2024 Formula 1 qualifying telemetry, event weather, track curvature, a transparent effective thermal model, a smooth residual-grip formulation, iterative thermal/performance coupling, and paired uncertainty analysis.

### What it fixes

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

## Research Paper

[Read the TireTwin Research Paper](paper/TireTwin_Final_ResearchPaper.pdf)

---

## Citation

If you use TireTwin in academic, engineering, or analytical work, please cite the archived software release:

**Anowar, Kazi Sadia. (2026). TireTwin: Modeling Tire Thermal Effects in Formula 1 (v1.0.0) [Computer software]. Zenodo.**

- **All-versions DOI:** https://doi.org/10.5281/zenodo.21959622
- **Version v1.0.0 DOI:** https://doi.org/10.5281/zenodo.21959623

The all-versions DOI should be used when referencing the TireTwin project generally. The version DOI identifies the archived v1.0.0 release specifically.
