function out = nkii_irf(p,sol,innovation,H)
% Conditional means after a time-zero innovation; no later innovations.
assert(sol.determinate,'Taylor-rule system does not have a unique bounded solution.');
state = innovation(:);
out = zeros(H,4); % [pi,x,i,r], all in decimals.
res = zeros(H,3);
for t=1:H
    jump = sol.F*state;
    ejump = sol.F*sol.P*state;
    x=jump(1); pi=jump(2);
    i=p.phi_pi*pi+p.phi_x*x+state(3);
    r=i-ejump(2);
    out(t,:)=[pi x i r];
    res(t,:)=[x-ejump(1)+r/p.sigma-state(1), ...
        pi-p.beta*ejump(2)-p.kappa*x-state(2), ...
        i-p.phi_pi*pi-p.phi_x*x-state(3)];
    state=sol.P*state;
end
assert(max(abs(res),[],'all')<1e-10,'IRF equilibrium residual exceeds tolerance.');
end
