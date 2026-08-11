# TireTwin v2 Methodology

TireTwin v2 corrects the model-form and uncertainty-design issues identified during external review of v1.

## Key corrections

- Actual lateral acceleration proxy from track curvature: `a_y = v^2 * kappa`, with curvature derived from FastF1 X/Y position data.
- Longitudinal acceleration `a_x = v * dv/ds` is kept separate and is no longer mislabeled as lateral load.
- Telemetry is resampled to a common 1 m distance grid before smoothing and differentiation.
- Braking heat proxy uses deceleration magnitude: `Brake * max(-a_x,0) * v`.
- Convective cooling increases with speed: `hA(v) = hA0 + hA1*v^0.8`.
- The Gaussian grip curve has a smooth residual-friction asymptote and no hard clamp.
- The thermal/performance calculation uses fixed-point iteration so speed changes feed back into thermal state.
- Event-specific air and track temperature are exported from FastF1 and used when available.
- The output metric is renamed **modeled thermal-grip deficit relative to the telemetry-integrated baseline**. It is not described as seconds actually lost to tire temperature.
- Results are reported in seconds, percent of telemetry-integrated lap time, and seconds per kilometre.
- Monte Carlo uses common random numbers: the same parameter draw is applied to every circuit.
- Full Monte Carlo samples are retained, enabling paired circuit differences and `P(A > B)` estimates.
- A standardized regression coefficient table provides a global sensitivity screen.
- Full OAT per-circuit outputs and rank-stability metrics are retained rather than only reporting cross-circuit means.

## Remaining abstraction

The model still represents an effective vehicle-level tire thermal/grip state. It is not a four-corner tire model, does not use proprietary tire measurements, and does not claim to reconstruct actual Formula 1 tire temperatures.
