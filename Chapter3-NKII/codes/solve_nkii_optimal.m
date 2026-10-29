function [commitment,discretion,sol,check] = solve_nkii_optimal(p,H)
% L=.5 E sum beta^t[pi_t^2+lambda_x*x_t^2], subject to NKPC.
% Lagrangian uses psi_t*(pi_t-kappa*x_t-beta*E pi(t+1)-u_t).
% FOCs: lambda_x*x_t=kappa*psi_t; pi_t+psi_t-psi(t-1)=0.
% Full commitment starts at t=0 with psi(-1)=0 (not timeless perspective).
% z=[u_t,psi(t-1),pi_t]': 2 states, 1 jump variable.
% Cost shock experiment: d_t=0. Generally i=E pi(+1)+sigma*(E x(+1)-x+d).
b=p.beta; k=p.kappa; l=p.lambda_x;
T=[p.rho_u 0 0;0 1 -1;-1/b -k*k/(l*b) (1+k*k/l)/b];
sol=bk_solve(T,2);
assert(sol.determinate,'Commitment BK/rank condition failed.');
state=[p.sd_u;0];
commitment=zeros(H,4); discretion=zeros(H,4);
res=zeros(H,4);
for t=1:H
    pi=sol.F*state;
    psi=state(2)-pi;
    x=k/l*psi;
    next=sol.P*state;
    epi=sol.F*next;
    ex=k/l*(next(2)-epi);
    i=epi+p.sigma*(ex-x); % Natural real rate held at steady state.
    commitment(t,:)=[pi x i i-epi];
    res(t,:)=[pi-b*epi-k*x-state(1),l*x-k*psi, ...
        pi+psi-state(2),next(2)-psi];
    % Discretion: each policymaker takes private-sector expectations as given.
    piD=l/(l*(1-b*p.rho_u)+k*k)*state(1);
    xD=-k/l*piD;
    iD=p.rho_u*piD+p.sigma*(p.rho_u-1)*xD;
    discretion(t,:)=[piD xD iD iD-p.rho_u*piD];
    state=next;
end
check.maxFOCResidual=max(abs(res),[],'all');
assert(check.maxFOCResidual<1e-10,'Optimal policy FOC residual exceeds tolerance.');
check.initialMultiplier=0;
end
