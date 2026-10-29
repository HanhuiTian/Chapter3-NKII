function sol = solve_nkii_taylor(p)
% x=E x(+1)-(i-E pi(+1))/sigma+d;
% pi=beta E pi(+1)+kappa*x+u; i=phi_pi*pi+phi_x*x+v.
% z=[d,u,v,x,pi]'. d,u,v are observed exogenous AR(1) states.
% d is the IS intercept; the natural real rate deviation is sigma*d.
A = [1 1/p.sigma;0 p.beta];
B = [1+p.phi_x/p.sigma p.phi_pi/p.sigma;-p.kappa 1];
D = [-1 0 1/p.sigma;0 -1 0];
R = diag([p.rho_d p.rho_u p.rho_v]);
T = [R zeros(3,2);A\D A\B];
sol = bk_solve(T,3);
sol.T = T;
sol.A = A;
sol.B = B;
sol.D = D;
sol.theoryDeterminate = p.kappa*(p.phi_pi-1)+(1-p.beta)*p.phi_x>0;
end
