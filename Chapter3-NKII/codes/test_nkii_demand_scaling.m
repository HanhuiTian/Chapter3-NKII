function check = test_nkii_demand_scaling()
% Verify d outside the IS interest-rate bracket, including nonunit sigma.
check.maxEquilibriumResidual=0;
check.maxEquivalenceError=0;
for sigma=[0.5 1 2]
    p=nkii_calibration();
    p.sigma=sigma;
    p.kappa=p.lambda_p*(p.sigma+p.varphi);
    p.lambda_x=p.kappa/p.epsilon;
    p.psi_ya=(1+p.varphi)/(p.sigma+p.varphi);
    sol=solve_nkii_taylor(p);
    assert(sol.determinate && sol.D(1,1)==-1);
    R=diag([p.rho_d p.rho_u p.rho_v]);
    % Independent reference uses a natural-rate state rn=sigma*d.
    Dnatural=[-1/sigma 0 1/sigma;0 -1 0];
    Fnatural=zeros(2,3);
    for j=1:3
        Fnatural(:,j)=(R(j,j)*sol.A-sol.B)\Dnatural(:,j);
    end
    err=max(abs(sol.F-Fnatural*diag([sigma 1 1])),[],'all');
    check.maxEquivalenceError=max(check.maxEquivalenceError,err);
    for j=1:3
        state=zeros(3,1); state(j)=0.01;
        out=nkii_irf(p,sol,state,12);
        for t=1:12
            expected=sol.F*R*state;
            pi=out(t,1); x=out(t,2); i=out(t,3); r=out(t,4);
            residual=[x-expected(1)+r/sigma-state(1), ...
                pi-p.beta*expected(2)-p.kappa*x-state(2), ...
                i-p.phi_pi*pi-p.phi_x*x-state(3), ...
                i-expected(2)-sigma*(expected(1)-x+state(1))];
            check.maxEquilibriumResidual=max(check.maxEquilibriumResidual,max(abs(residual)));
            state=R*state;
        end
    end
    % A TFP innovation maps to d=rn/sigma.
    pA=p; pA.rho_d=p.rho_a;
    solA=solve_nkii_taylor(pA);
    dA=-p.psi_ya*(1-p.rho_a)*p.sd_a;
    rnA=sigma*p.psi_ya*(p.rho_a-1)*p.sd_a;
    naturalA=(p.rho_a*solA.A-solA.B)\Dnatural(:,1)*rnA;
    err=max(abs(solA.F(:,1)*dA-naturalA));
    check.maxEquivalenceError=max(check.maxEquivalenceError,err);
    % With no cost shock, i=sigma*d implements pi=x=0.
    d=0.01; i=sigma*d;
    check.maxEquilibriumResidual=max(check.maxEquilibriumResidual,abs(i/sigma-d));
end
assert(check.maxEquilibriumResidual<1e-10,'Demand normalization: equation residual failed.');
assert(check.maxEquivalenceError<1e-10,'Demand normalization: state conversion failed.');
fprintf('Demand normalization (sigma=0.5,1,2): residual %.3g, equivalence %.3g\n', ...
    check.maxEquilibriumResidual,check.maxEquivalenceError);
end
