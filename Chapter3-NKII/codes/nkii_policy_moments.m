function stats = nkii_policy_moments(p,codeDir,figureDir)
% Stationary moments with only iid cost innovations (standard deviation sd_u).
% Policies: Taylor, discretion, commitment. Variables in decimals throughout.
% Commitment inherits the stationary distribution of its past multiplier.
H=1000;
taylor=solve_nkii_taylor(p);
[c,d,commitment]=solve_nkii_optimal(p,H);
t=nkii_irf(p,taylor,[0;p.sd_u;0],H);
Fpi=p.lambda_x/(p.lambda_x*(1-p.beta*p.rho_u)+p.kappa^2);
P={taylor.P,p.rho_u,commitment.P};
G={taylor.F([2 1],:),[Fpi;-p.kappa/p.lambda_x*Fpi], ...
    [commitment.F;p.kappa/p.lambda_x*([0 1]-commitment.F)]};
impact={[0;p.sd_u;0],p.sd_u,[p.sd_u;0]};
paths={t,d,c};
V=zeros(3,2);
for j=1:3
    n=size(P{j},1);
    assert(max(abs(eig(P{j})))<1,'Stationary moments require stable dynamics.');
    Q=impact{j}*impact{j}';
    S=reshape((eye(n*n)-kron(P{j},P{j}))\Q(:),n,n);
    S=(S+S')/2;
    assert(max(abs(S-P{j}*S*P{j}'-Q),[],'all')<1e-12);
    V(j,:)=diag(G{j}*S*G{j}')'; % inflation, output gap
    % Independent moving-average check using one-standard-deviation IRFs.
    assert(max(abs(V(j,:)-sum(paths{j}(:,1:2).^2,1)))<1e-12);
end
stats=table(["Taylor";"Discretion";"Commitment"], ...
    100*sqrt(V(:,2)),100*sqrt(V(:,1)), ...
    .5*(V(:,1)+p.lambda_x*V(:,2)), ...
    'VariableNames',{'Policy','StdOutputGapPercent','StdInflationPercent', ...
    'ExpectedPeriodLoss'});
stats.StationaryDiscountedLoss=stats.ExpectedPeriodLoss/(1-p.beta);
if nargin>=3
    writetable(stats,fullfile(codeDir,'policy_moments.csv'));
    fid=fopen(fullfile(figureDir,'nkii_policy_moments.tex'),'w','n','UTF-8');
    assert(fid>=0,'Cannot write policy moments table.');
    cleanup=onCleanup(@()fclose(fid)); %#ok<NASGU>
    fprintf(fid,'%s\n','\begin{tabular}{lccc}','\toprule', ...
        '货币政策 & 产出缺口标准差 & 通胀率标准差 & 福利损失 \\', ...
        ' & （\%） & （\%） & （$\times10^{-4}$） \\', '\midrule');
    labels={'泰勒规则','最优相机抉择','最优承诺'};
    for j=1:3
        fprintf(fid,'%s & %.3f & %.3f & %.3f \\\\\n',labels{j}, ...
            stats.StdOutputGapPercent(j),stats.StdInflationPercent(j), ...
            1e4*stats.ExpectedPeriodLoss(j));
    end
    fprintf(fid,'%s\n','\bottomrule','\end{tabular}');
end
end
