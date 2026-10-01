function [p] = parameters(eg, ae, mug, amu, lamg, alam, cg, ac, epsg, aeps, temp, tempg, alpha)
    Tc = min(max(temp, tempg-15), tempg+15);   % used only for E, mu, lam, C, eps_l
    p.E = eg * exp(ae*((tempg/Tc)-1));
    p.mu = mug * exp(amu*((tempg/Tc)-1));
    p.lam = lamg * exp(alam*((tempg/Tc)-1));
    p.C = cg * exp(ac*((tempg/Tc)-1));
    p.el = epsg * exp(-aeps*((tempg/Tc)-1));
    p.alpha = alpha;
end