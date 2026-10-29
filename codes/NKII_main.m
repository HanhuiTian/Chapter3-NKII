function results = NKII_main(showFigures)
% Chapter 3: the three-equation NK model, BK solution, and optimal policy.
% No Dynare/toolbox required. MATLAB R2020a or newer.
% NKII_main() displays figures. NKII_main(false) only saves outputs.
if nargin<1, showFigures=true; end
validateattributes(showFigures,{'logical'},{'scalar'});

%% 1. Calibration and genuine Blanchard-Kahn/Schur solution
codeDir=fileparts(mfilename('fullpath'));
if isempty(codeDir), codeDir=fileparts(which('NKII_main')); end
projectDir=fileparts(codeDir);
figureDir=fullfile(projectDir,'figures');
resultDir=fullfile(codeDir,'results');
originalPath=path;
pathCleanup=onCleanup(@()path(originalPath)); %#ok<NASGU>
addpath(codeDir);
if ~exist(figureDir,'dir'), mkdir(figureDir); end
if ~exist(resultDir,'dir'), mkdir(resultDir); end
p=nkii_calibration();
sol=solve_nkii_taylor(p);
assert(sol.determinate,'Baseline Taylor policy fails BK condition.');
fprintf('Taylor: stable roots=%d, states=%d, rank=%d, residual=%.3g\n', ...
    sol.nStable,sol.nStates,sol.rankStateBlock,sol.maxResidual);
disp(sol.roots.');
% Independent undetermined-coefficients check (not the production solver).
rho=[p.rho_d p.rho_u p.rho_v];
Fcheck=zeros(2,3);
for j=1:3
    Fcheck(:,j)=(rho(j)*sol.A-sol.B)\sol.D(:,j);
end
analyticalError=max(abs(sol.F-Fcheck),[],'all');
assert(analyticalError<1e-10,'Schur BK solution fails independent coefficient check.');
demandCheck=test_nkii_demand_scaling();
names=fieldnames(p); values=cellfun(@(s)p.(s),names);
writetable(table(string(names),values,'VariableNames',{'Parameter','Value'}), ...
    fullfile(resultDir,'calibration.csv'));

%% 2. Demand, cost-push, monetary, and technology shock IRFs
H=p.horizon;
demand=nkii_irf(p,sol,[p.sd_d;0;0],H);
cost=nkii_irf(p,sol,[0;p.sd_u;0],H);
monetary=nkii_irf(p,sol,[0;0;-p.sd_v],H); % Easing innovation.
pA=p; pA.rho_d=p.rho_a;
solA=solve_nkii_taylor(pA);
% d=natural-rate deviation/sigma=-psi_ya*(1-rho_a)*a for a pure TFP shock.
tfp=nkii_irf(pA,solA,[-p.psi_ya*(1-p.rho_a)*p.sd_a;0;0],H);
series={demand,cost,monetary,tfp};
tags={'demand','cost','monetary','tfp'};
for q=1:numel(tags)
    plot_nkii_irf(series{q},{'Taylor rule'},fullfile(figureDir,['nkii_irf_' tags{q}]),H,showFigures);
    writetable(array2table([(0:H-1)' 100*series{q}], ...
        'VariableNames',{'Quarter','pi_pp','x_percent','i_pp','r_exante_pp'}), ...
        fullfile(resultDir,['irf_' tags{q} '.csv']));
end

%% 3. Taylor principle: numerical root-count and rank check across a grid
[mismatch,nChecked]=nkii_determinacy(p,figureDir,resultDir,showFigures);
fprintf('Taylor principle: %d checked grid points, %d disagreements.\n',nChecked,mismatch);

%% 4. Full commitment versus discretion and a standard Taylor rule
[commitment,discretion,solC,checkC]=solve_nkii_optimal(p,H);
plot_nkii_irf(cat(3,cost,commitment,discretion), ...
    {'Taylor rule','最优承诺政策','最优相机抉择政策'}, ...
    fullfile(figureDir,'nkii_irf_optimal'),H,showFigures);
plot_nkii_irf(cat(3,discretion,commitment),{'相机抉择','最优承诺政策'}, ...
    fullfile(figureDir,'nkii_irf_discretion'),H,showFigures);
writetable(array2table([(0:H-1)' 100*cost 100*commitment 100*discretion], ...
    'VariableNames',{'Quarter','taylor_pi_pp','taylor_x_percent','taylor_i_pp','taylor_r_pp', ...
    'commit_pi_pp','commit_x_percent','commit_i_pp', ...
    'commit_r_pp','discretion_pi_pp','discretion_x_percent','discretion_i_pp','discretion_r_pp'}), ...
    fullfile(resultDir,'irf_optimal.csv'));
% Long horizon only evaluates discounted loss; solution itself is infinite-horizon BK.
longH=1000;
[cLong,dLong]=solve_nkii_optimal(p,longH);
tLong=nkii_irf(p,sol,[0;p.sd_u;0],longH);
loss=@(z).5*sum(p.beta.^(0:longH-1)'.*(z(:,1).^2+p.lambda_x*z(:,2).^2));
losses=[loss(tLong);loss(dLong);loss(cLong)];
assert(losses(3)<losses(1) && losses(3)<losses(2),'Commitment welfare comparison failed.');
writetable(table(["Taylor";"Discretion";"Commitment"],losses, ...
    'VariableNames',{'Policy','DiscountedLoss'}),fullfile(resultDir,'policy_welfare.csv'));
fprintf('Commitment: stable=%d, states=%d, rank=%d, FOC residual=%.3g\n', ...
    solC.nStable,solC.nStates,solC.rankStateBlock,checkC.maxFOCResidual);
disp(table(["Taylor";"Discretion";"Commitment"],losses));
% Stationary volatility and expected period loss under repeated cost shocks.
% Distinct from the discounted loss of a single innovation above.
policyMoments=nkii_policy_moments(p,resultDir,figureDir);
disp(policyMoments);
validation=table(["Taylor_BK_residual";"Taylor_analytical_crosscheck";"Commitment_BK_residual"; ...
    "Commitment_FOC_residual";"Determinacy_grid_points";"Determinacy_grid_mismatches"; ...
    "Demand_scaling_equilibrium_residual";"Demand_scaling_equivalence_error"], ...
    [sol.maxResidual;analyticalError;solC.maxResidual;checkC.maxFOCResidual;nChecked;mismatch; ...
    demandCheck.maxEquilibriumResidual;demandCheck.maxEquivalenceError], ...
    'VariableNames',{'Check','Value'});
writetable(validation,fullfile(resultDir,'validation.csv'));
allRoots=[sol.roots;solC.roots];
writetable(table([repmat("Taylor",numel(sol.roots),1); ...
    repmat("Commitment",numel(solC.roots),1)],real(allRoots),imag(allRoots),abs(allRoots), ...
    'VariableNames',{'Model','RealPart','ImaginaryPart','Modulus'}), ...
    fullfile(resultDir,'bk_roots.csv'));

%% 5. CGG (2000), Figure IV: approximate digitization of the original curves
% The fixed CSV is supplied locally; no paper image or Internet is needed.
results.cgg=plot_cgg_figure_iv(projectDir,showFigures);

%% 6. US long-run and short-run natural interest rates
results.naturalRates=plot_us_natural_rates(projectDir,showFigures);
results.parameters=p;
results.taylorSolution=sol;
results.commitmentSolution=solC;
results.policyMoments=policyMoments;
results.validation=validation;
results.irf=struct('demand',demand,'cost',cost,'monetary',monetary, ...
    'tfp',tfp,'commitment',commitment,'discretion',discretion);
results.resultDir=resultDir;
results.figureDir=figureDir;
fprintf('All NKII figures and numerical teaching outputs regenerated.\n');
end
