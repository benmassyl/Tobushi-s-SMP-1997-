% coefficients pour les paramètres
eg    = 146;      % MPa
ae    = 38.1;
mug   = 14000;    % MPa·s
amu   = 44.2;
lamg  = 521;      % s
alam  = 35.4;
cg    = 0.112;
ac    = 38.7;
epsg  = 0.003;    % fraction
aeps  = 58.2;
tempg = 328;
t0 = tempg+20;
alpha = 11.6e-5;     % K
t_dot = 4/60; %K/s , dans le papier on avait 4/min
d1=48; % durée étape 1, s
d2=600; % durée étape 2, s
%d3=2; % durée étape 3, s
d4=600; % durée étape 2, s


dt   = 0.01;              % s
tend = d1+d2+d4;             % s
N    = round(tend/dt);

% preallocate history arrays
t   = (0:N)'*dt;
sig = zeros(N+1,1);
epsi = zeros(N+1,1);
temp = zeros(N+1,1);

% étape 01
% ---------- Stage 01 ------------
sig(1) = 0;
epsi(1) = 0;
temp(1) = t0;
eps_c =0;
eps_s =0;
eps_dot = 0.05/60; % 5% de def /min
T_dot_stage = 0; % temperature constante
p = parameters(eg, ae, mug, amu, lamg, alam, cg, ac, epsg, aeps, temp(1), tempg, alpha); %temperature change pas donc besoin de le calculer qu'une seule fois

for n=1:(d1/dt)
    epsi(n+1) = epsi(n) + dt*eps_dot;
    eps_c = max(epsi);
    if eps_c < p.el
        eps_s = 0;
    else
        eps_s = p.C * (eps_c - p.el);
    end
    sig_dot = p.E*(eps_dot + (epsi(n) -eps_s)/p.lam - sig(n)/p.mu-p.alpha*T_dot_stage);
    sig(n+1) = sig(n) + dt*sig_dot;
    temp(n+1)=temp(n);
end
% ---------- Stage 02 ------------
T_dot_stage = -t_dot; % refroidissement
for n = d1/dt+1 : round((d1+d2)/dt)
    eps_dot = 0;
    temp(n+1) = temp(n)-dt*t_dot;
    p = parameters(eg, ae, mug, amu, lamg, alam, cg, ac, epsg, aeps, temp(n+1), tempg, alpha);
    epsi(n+1) = epsi(n) + dt*eps_dot;
    sig_dot = p.E*(eps_dot + (epsi(n) -eps_s)/p.lam - sig(n)/p.mu-p.alpha*T_dot_stage);
    sig(n+1) = sig(n) + dt*sig_dot;
end
% ---------- Stage 03 ------------
n = n+2; %pour faire le retrait instantané sur une seule step
sig(n) = 0;
epsi(n) = epsi(n-1) - sig(n-1)/p.E;
temp(n) = temp(n-1);

% ---------- Stage 04 ------------
for n = n : round((d1+d2+d4)/dt)
    T_dot_stage = t_dot;
    sig_dot = 0;
    temp(n+1) = temp(n)+dt*t_dot;
    p = parameters(eg, ae, mug, amu, lamg, alam, cg, ac, epsg, aeps, temp(n+1), tempg, alpha); 
    sig(n+1) = sig(n) + dt*sig_dot;
    eps_dot = sig_dot/p.E + sig(n)/p.mu - (epsi(n)-eps_s)/p.lam+alpha*t_dot;
    epsi(n+1) = epsi(n) + eps_dot*dt;
end
% ---------- Stage indices and colours ----------
i1 = round(d1/dt) + 1;          % end of stage 1
i2 = round((d1+d2)/dt) + 1;     % end of stage 2
i3 = i2 + 1;                    % end of stage 3 (unloading)
idx  = {1:i1, i1:i2, i2:i3, i3:numel(sig)};
cols = {[0 0 0], [0.85 0.15 0.15], [0 0.35 0.85], [0 0.6 0.2]};   % black, red, blue, green
labs = {'① Loading (T_h)', '② Cooling (\epsilon fixed)', '③ Unloading (T_l)', '④ Heating (\sigma = 0)'};

% ---------- Fig. 5 : stress-strain ----------
figure('Color','w'); hold on; box on;
for k = 1:4
    plot(100*epsi(idx{k}), sig(idx{k}), '-', 'Color', cols{k}, 'LineWidth', 1.5);
end
xlabel('Strain %'); ylabel('Stress MPa');
xlim([0 5]); ylim([0 2.5]);
title('\epsilon_m = 4%'); legend(labs, 'Location', 'northwest');
exportgraphics(gcf, 'fig5_stress_strain.pdf', 'ContentType', 'vector');

% ---------- Fig. 6 : stress-temperature ----------
figure('Color','w'); hold on; box on;
for k = 1:4
    plot(temp(idx{k}), sig(idx{k}), '-', 'Color', cols{k}, 'LineWidth', 1.5);
end
xline(tempg, 'k--', 'T_g', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xlabel('Temperature K'); ylabel('Stress MPa');
xlim([300 360]); ylim([0 2.5]);
title('\epsilon_m = 4%'); legend(labs, 'Location', 'northeast');
exportgraphics(gcf, 'fig6_stress_temp.pdf',   'ContentType', 'vector');


% ---------- Fig. 7 : strain-temperature ----------
figure('Color','w'); hold on; box on;
for k = 1:4
    plot(temp(idx{k}), 100*epsi(idx{k}), '-', 'Color', cols{k}, 'LineWidth', 1.5);
end
xline(tempg, 'k--', 'T_g', 'LabelVerticalAlignment', 'top', 'HandleVisibility', 'off');
xlabel('Temperature K'); ylabel('Strain %');
xlim([300 360]); ylim([0 5]);
title('\epsilon_m = 4%'); legend(labs, 'Location', 'southwest');
exportgraphics(gcf, 'fig7_strain_temp.pdf',   'ContentType', 'vector');






% %première étape du cycle : Déformation a chauffage constant
% for n = 1:36000
%     [sd, ed] = slv(sig(n), eps(n), eps_s, 0, 'stress', p); % Creep 
%     sig(n+1) = sig(n) + dt*sd;
%     eps(n+1) = eps(n) + dt*ed;
% end
% %deuxième étape du cycle : Refroidissement a déformation bloquée
% eps_c = max(eps(1:36000));    
% eps_s = p.C*(eps_c - p.el); 
% retour_elastique = 0
% for n = 36001:N
%     if retour_elastique == 0
%         eps(n) = eps (n) - sig(n)/p.E;
%         retour_elastique = 1
%     end

%     sig(n) = 0;
%     [sd, ed] = slv(sig(n), eps(n), eps_s, 0, 'stress', p);  % Relaxation
%     eps(n+1) = eps(n) + dt*ed;
% end

% % analytical solution for comparison, then plot both
