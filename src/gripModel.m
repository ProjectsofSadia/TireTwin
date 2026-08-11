function [mu,ratio] = gripModel(T_C,p)
%GRIPMODEL Smooth residual-friction thermal response; no hard clamp.
core = exp(-((T_C-p.Topt_C).^2)./(2*p.sigmaT_C^2));
ratio = p.residualGripFraction + (1-p.residualGripFraction).*core;
mu = p.muMax.*ratio;
end
