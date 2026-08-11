# Methodology

## Objective
TireTwin studies how a simplified transient tire thermal state may influence modeled grip availability and lap-time sensitivity under telemetry-derived operating conditions.

## Thermal model
\[
m_t c_p \frac{dT}{dt}
=
\dot Q_{in}-hA(T-T_{amb})+kA_c(T_{track}-T)
\]

The heat-input term is a telemetry-derived operating-load proxy, not measured tire heat flow.

## Grip model
\[
\mu(T)=\mu_{max}\exp\left(-\frac{(T-T_{opt})^2}{2\sigma_T^2}\right)
\]

## Performance model
The observed speed profile is reduced in high-load regions according to the modeled grip ratio. This is a sensitivity model, not a full vehicle-dynamics solver.

## Lap time
\[
T=\int \frac{ds}{v(s)}
\]

## Planned empirical study
Use real telemetry from Bahrain, Monaco, Monza, Silverstone, and Suzuka, then compare:
- peak / mean modeled temperature,
- thermal-window occupancy,
- modeled friction state,
- modeled lap-time penalty,
- parameter sensitivity,
- Monte Carlo uncertainty.

No conclusion should be written until those experiments are run.
