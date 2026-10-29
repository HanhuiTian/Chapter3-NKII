function data = plot_cgg_figure_iv(projectDir,showFigures)
%PLOT_CGG_FIGURE_IV Approximately reproduce the published historical figure.
% Input is digitized from CGG (2000), Figure IV, NOT simulated model data.
% Published curves already use centered three-quarter moving averages.
% DO NOT smooth again. See reference/cgg_digitized_notes.md.
if nargin < 1
    projectDir = fileparts(fileparts(mfilename('fullpath')));
end
if nargin<2, showFigures=true; end
figureDir = fullfile(projectDir,'figures');
if ~isfolder(figureDir), mkdir(figureDir); end
data = readtable(fullfile(projectDir,'reference','cgg_digitized.csv'));
q = string(data.Quarter);
years = str2double(extractBefore(q,'Q'));
quarters = str2double(extractAfter(q,'Q'));
dates = datetime(years,3*quarters-2,1);
assert(all(isfinite(data.Inflation)) && all(isfinite(data.RealRate)));
assert(issorted(dates) && numel(unique(dates))==height(data));
font = 'Microsoft YaHei';
% Windows may report the localized font name in LISTFONTS; do not fall back
% to a Latin-only font merely because the English alias is absent.
fig = figure('Visible','off','Color','w','Position',[100 100 1180 640]);
ax = axes(fig); hold(ax,'on');
plot(ax,dates,data.Inflation,'Color',[0 .32 .65],'LineWidth',2);
plot(ax,dates,data.RealRate,'--','Color',[.80 .18 .18],'LineWidth',2);
yline(ax,0,'-','Color',[.65 .65 .65],'LineWidth',.8,'HandleVisibility','off');
xline(ax,datetime(1979,7,1),':','1979Q3','Color',[.35 .35 .35], ...
    'LabelOrientation','horizontal','LineWidth',1.2,'HandleVisibility','off');
xlim(ax,[datetime(1961,1,1),datetime(1997,1,1)]);
xticks(ax,datetime(1961:3:1997,1,1)); xtickformat(ax,'yyyy');
ylim(ax,[-2 12]); yticks(ax,-2:2:12);
ylabel(ax,'年化百分比（%）','FontName',font,'FontSize',15);
xlabel(ax,'年份','FontName',font,'FontSize',15);
legend(ax,{'通胀率','事后真实利率'},'Location','northeast','Box','off','FontName',font,'FontSize',14);
set(ax,'FontName',font,'FontSize',13,'Box','off'); grid(ax,'on');
exportgraphics(fig,fullfile(figureDir,'cgg2000_figure_iv.png'),'Resolution',220);
if showFigures, set(fig,'Visible','on'); else, close(fig); end
fprintf('CGG Figure IV digitized reproduction: %d quarters, %s to %s.\n', ...
    height(data),char(q(1)),char(q(end)));
end
