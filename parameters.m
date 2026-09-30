function [p] = parameters(eg, ae, mug, amu, lamg, alam, cg, ac, epsg, aeps, temp, tempg)
    p.E = eg * exp(ae*((Tg/T)-1));
    p.mu = mug * exp(amu*((Tg/T)-1));
    p.lam = lamg * exp(alam*((Tg/T)-1));
    p.C = cg * exp(ac*((Tg/T)-1));
    p.el = epsg * exp(aeps*((Tg/T)-1));
end