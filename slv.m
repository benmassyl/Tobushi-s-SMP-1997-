function [sig_dot, eps_dot] = slv(sig, eps, eps_s, t_dot, ctrl, mode, p)
% sig, eps : current state
% ctrl     : the imposed rate (eps_dot if mode = 'strain', sig_dot if 'stress')
% p        : struct with fields E, mu, lam

    switch mode
        case 'strain'
            eps_dot = ctrl;
            sig_dot = p.E*(eps_dot + (eps-eps_s)/p.lam - sig/p.mu -alpha*t_dot);
        case 'stress'
            sig_dot = ctrl;
            eps_dot = sig_dot/p.E + sig/p.mu - (eps-eps_s)/p.lam-alpha*t_dot;
    end
end