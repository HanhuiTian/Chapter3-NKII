function checks = test_nkii()
% Fast numerical tests without plotting or writing files.
p=nkii_calibration();
s=solve_nkii_taylor(p);
assert(s.determinate && s.nStable==3 && s.rankStateBlock==3);
assert(s.maxResidual<1e-10);
for j=1:3
    innovation=zeros(3,1); innovation(j)=.01;
    nkii_irf(p,s,innovation,100);
end
passive=p; passive.phi_pi=.5; passive.phi_x=0;
sPassive=solve_nkii_taylor(passive);
assert(~sPassive.determinate && sPassive.nStable==4);
boundary=p; boundary.phi_pi=1; boundary.phi_x=0;
sBoundary=solve_nkii_taylor(boundary);
assert(sBoundary.unitRoot && ~sBoundary.determinate);
scaling=test_nkii_demand_scaling();
[c,d,sc,optimal]=solve_nkii_optimal(p,1000);
assert(sc.nStable==2 && sc.rankStateBlock==2);
assert(max(abs(p.kappa*c(:,1)+p.lambda_x*(c(:,2)-[0;c(1:end-1,2)])))<1e-10);
assert(max(abs(p.kappa*d(:,1)+p.lambda_x*d(:,2)))<1e-10);
stats=nkii_policy_moments(p);
assert(stats.ExpectedPeriodLoss(3)<stats.ExpectedPeriodLoss(2));
assert(stats.ExpectedPeriodLoss(3)<stats.ExpectedPeriodLoss(1));
expected=[6.21338540742057 2.88478608201668; ...
    8.07754442649435 1.34625740441572; ...
    7.96074609937796 .579932949456174];
assert(max(abs([stats.StdOutputGapPercent stats.StdInflationPercent]-expected),[],'all')<1e-9, ...
    'Baseline moments changed. Update the regression benchmark when intentionally recalibrating.');
checks=table(["Taylor_BK";"Commitment_BK";"Commitment_FOC"; ...
    "Demand_equations";"Demand_normalization"], ...
    [s.maxResidual;sc.maxResidual;optimal.maxFOCResidual; ...
    scaling.maxEquilibriumResidual;scaling.maxEquivalenceError], ...
    'VariableNames',{'Check','Residual'});
disp(checks);
fprintf('All NKII numerical tests passed.\n');
end
