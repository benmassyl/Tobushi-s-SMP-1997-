function [sig, eps] = tobushi(sig, eps, eps_s, t_dot, dt, ctrl, mode, p)
% sig, eps : current state
% ctrl     : the imposed rate (eps_dot if mode = 'strain', sig_dot if 'stress')
% p        : struct with fields E, mu, lam

    switch mode
        case 'etape1' %chargement a sigma_dot constant, temperature constante
            eps_dot = ctrl;
            eps = eps + eps_dot*dt 
            
        case 'etape2' %refroidissement a eps et eps_dot constants (0)

        case 'etape3' %retour élastique
        
        case 'etape4' %réchauffement sans contraintes
    end
end

            % eps_dot = ctrl;
            % sig_dot = p.E*(eps_dot + (eps-eps_s)/p.lam - sig/p.mu -alpha*t_dot);
            % eps_dot = sig_dot/p.E + sig/p.mu - (eps-eps_s)/p.lam+alpha*t_dot;