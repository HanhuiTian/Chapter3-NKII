function [mismatch,nChecked] = nkii_determinacy(p,figureDir,codeDir,showFigures)
if nargin<4, showFigures=true; end
% For nonnegative feedback coefficients, unique equilibrium iff
% kappa*(phi_pi-1)+(1-beta)*phi_x>0. Exclude unit-root boundary.
piGrid=linspace(0,3,241); xGrid=linspace(0,2,161);
status=nan(numel(xGrid),numel(piGrid));
mismatch=0; nChecked=0;
for a=1:numel(piGrid)
    for b=1:numel(xGrid)
        pp=p; pp.phi_pi=piGrid(a); pp.phi_x=xGrid(b);
        sol=solve_nkii_taylor(pp);
        margin=p.kappa*(pp.phi_pi-1)+(1-p.beta)*pp.phi_x;
        if abs(margin)<1e-7 || sol.unitRoot
            continue
        end
        status(b,a)=double(sol.determinate);
        mismatch=mismatch+(sol.determinate~=(margin>0));
        nChecked=nChecked+1;
    end
end
assert(mismatch==0,'Numerical BK and Taylor principle disagree.');
fig=figure('Color','w','Visible','off','Position',[100 100 1100 680]);
imagesc(piGrid,xGrid,status); axis xy; hold on;
colormap([.96 .86 .80;.79 .88 .96]); caxis([0 1]);
plot(1-(1-p.beta)/p.kappa*xGrid,xGrid,'k-','LineWidth',2);
plot(p.phi_pi,p.phi_x,'ko','MarkerFaceColor',[0 .32 .65],'MarkerSize',9);
set(gca,'FontName','Microsoft YaHei','FontSize',15);
xlabel('通胀反应系数 \phi_\pi','FontSize',18);
ylabel('产出缺口反应系数 \phi_x','FontSize',18);
text(.18,1.45,'均衡不确定','FontName','Microsoft YaHei','FontSize',20);
text(1.65,1.45,'唯一稳定均衡','FontName','Microsoft YaHei','FontSize',20);
text(1.58,.2,'基准校准','FontName','Microsoft YaHei','FontSize',14);
grid on; box off;
exportgraphics(fig,fullfile(figureDir,'nkii_determinacy.pdf'),'ContentType','vector');
exportgraphics(fig,fullfile(figureDir,'nkii_determinacy.png'),'Resolution',180);
if showFigures, set(fig,'Visible','on'); else, close(fig); end
[pg,xg]=meshgrid(piGrid,xGrid);
writetable(table(pg(:),xg(:),status(:),'VariableNames', ...
    {'phi_pi','phi_x','unique_equilibrium'}),fullfile(codeDir,'determinacy_grid.csv'));
end
