% parameters at T_h (Table 3), units MPa and s
% Pour le moment les valeurs correspondent a T low
p.E   = 907;
p.mu  = 116000;      % 2.03 GPa·s -> MPa·s
p.lam = 2840;
p.C = 0.716
p.el = 0.000184

dt   = 0.1;              % s
tend = 1000;             % s
N    = round(tend/dt);

% preallocate history arrays
t   = (0:N)'*dt;
sig = zeros(N+1,1);
eps = zeros(N+1,1);

% initial state: 
sig(1)=10
eps(1)=10/p.E
eps_c =0
eps_s =0

for n = 1:7200
    [sd, ed] = slv(sig(n), eps(n), eps_s, 0, 'stress', p); % Creep 
    sig(n+1) = sig(n) + dt*sd;
    eps(n+1) = eps(n) + dt*ed;
end
eps_c = max(eps(1:7200));    
eps_s = p.C*(eps_c - p.el); 
for n = 7201:N
    [sd, ed] = slv(sig(n), eps(n), eps_s, 0, 'strain', p);  % Relaxation
    sig(n+1) = sig(n) + dt*sd;
    eps(n+1) = eps(n) + dt*ed;
end

% analytical solution for comparison, then plot both