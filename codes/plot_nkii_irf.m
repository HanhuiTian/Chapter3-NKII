function plot_nkii_irf(series,labels,fileBase,H,showFigures)
% series is H x 4 x number-of-policies. Input decimals, display 100*series.
if nargin<5, showFigures=true; end
colors=[0 .32 .65;.8 .18 .18;.25 .25 .25];
styles={'-','--',':'};
fig=figure('Color','w','Visible','off','Position',[100 100 1180 720]);
tiledlayout(2,2,'TileSpacing','compact','Padding','compact');
titles={'通胀率','产出缺口','名义利率','事前真实利率'};
for j=1:4
    nexttile; hold on;
    h=gobjects(size(series,3),1);
    for q=1:size(series,3)
        h(q)=plot(0:H-1,100*series(:,j,q),'Color',colors(q,:), ...
            'LineStyle',styles{q},'LineWidth',2.3);
    end
    yline(0,'-','Color',[.75 .75 .75],'HandleVisibility','off');
    xlim([0 H-1]);
    set(gca,'FontName','Microsoft YaHei','FontSize',13);
    title(titles{j},'FontSize',18);
    xlabel('季度','FontSize',14);
    ylabel('偏离稳态（%）','FontSize',14);
    grid on; box off;
    if j==1 && numel(labels)>1
        legend(h,labels,'Location','best','Box','off','FontSize',13);
    end
end
exportgraphics(fig,[fileBase '.pdf'],'ContentType','vector');
exportgraphics(fig,[fileBase '.png'],'Resolution',180);
if showFigures, set(fig,'Visible','on'); else, close(fig); end
end
