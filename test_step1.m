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
temp = tempg-15;
alpha = 11.6e-5;     % K

dt   = 0.01;              % s
tend = 7200;             % s
N    = round(tend/dt);

% preallocate history arrays
t   = (0:N)'*dt;
sig = zeros(N+1,1);
eps = zeros(N+1,1);

% initial state: 
sig(1)=8
eps(1)=sig(1)/p.E
eps_c =0
eps_s =0

%première étape du cycle : Déformation a chauffage constant
for n = 1:36000
    [sd, ed] = slv(sig(n), eps(n), eps_s, 0, 'stress', p); % Creep 
    sig(n+1) = sig(n) + dt*sd;
    eps(n+1) = eps(n) + dt*ed;
end
%deuxième étape du cycle : Refroidissement a déformation bloquée
eps_c = max(eps(1:36000));    
eps_s = p.C*(eps_c - p.el); 
retour_elastique = 0
for n = 36001:N
    if retour_elastique == 0
        eps(n) = eps (n) - sig(n)/p.E;
        retour_elastique = 1
    end

    sig(n) = 0;
    [sd, ed] = slv(sig(n), eps(n), eps_s, 0, 'stress', p);  % Relaxation
    eps(n+1) = eps(n) + dt*ed;
end

% analytical solution for comparison, then plot both