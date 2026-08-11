# Reproducibility

## Environment
Recommended: MATLAB R2024b or newer. Simulink is optional.

## Run
```matlab
main
```

## Real telemetry
Place CSV files in `data/processed/` with:
```text
Time,Distance,Speed,Throttle,Brake,RPM,Gear,DRS
```

Then set `telemetryFile` in `main.m`.

## Verification
```matlab
run("tests/runModelChecks.m")
```

## Experiments
```matlab
run("experiments/runInitialTemperatureSweep.m")
run("experiments/runMonteCarlo.m")
```

## Simulink
```matlab
run("simulink/build_simulink_model.m")
```

The synthetic demo is for pipeline verification only and must not be reported as an empirical motorsport finding.
