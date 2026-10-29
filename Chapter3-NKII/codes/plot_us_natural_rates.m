function data = plot_us_natural_rates(projectDir,showFigures)
% Reproduce the US natural rate comparison from the two supplied workbooks.
% Run this function in MATLAB R2020a or newer. No toolboxes are required.
% Outputs: a 400 dpi PNG, an editable FIG, and the common-sample CSV.
%
% Long run: HLW2023, updated US one-sided estimates, sheet HLW Estimates,
% column K (Natural Rate r*). Column C is trend growth, NOT the natural rate.
% Short run: Curdia (2026), Figure 7, graph-extracted full-sample smoothed
% estimates. The supplied workbook retains 1987Q2 through 2025Q4 and notes
% a discrepancy between the paper's figure and text endpoints. Dates and
% values are used exactly as supplied, without interpolation or smoothing.
% Both sources are quarterly observations in annualized percentage units.
% Their estimation information sets differ. This is a descriptive comparison.

if nargin<1, projectDir=fileparts(fileparts(mfilename('fullpath'))); end
if nargin<2, showFigures=true; end
figureDir = fullfile(projectDir,'figures');
dataDir = fullfile(projectDir,'data');
resultDir = fullfile(projectDir,'codes','results');
if ~isfolder(figureDir), mkdir(figureDir); end
if ~isfolder(resultDir), mkdir(resultDir); end
longFile = fullfile(dataDir, '长期自然利率.xlsx');
shortFile = fullfile(dataDir, '短期自然利率.xlsx');

rawLong = readcell(longFile, 'Sheet', 'HLW Estimates');
assert(strcmp(string(rawLong{5,11}), 'Natural Rate (r*)'));
assert(strcmp(string(rawLong{6,11}), 'US'));
longDates = rawLong(7:end,1);
if isdatetime(longDates{1})
    longDates = vertcat(longDates{:});
elseif isnumeric(longDates{1})
    longDates = datetime(cell2mat(longDates), 'ConvertFrom', 'excel');
else
    longDates = datetime(string(longDates));
end
longQuarter = year(longDates)*4 + ceil(month(longDates)/3);
longRate = cell2mat(rawLong(7:end,11));

rawShort = readcell(shortFile, 'Sheet', 1);
shortLabels = string(rawShort(2:end,1));
assert(all(~cellfun('isempty', regexp(cellstr(shortLabels), '^\d{4}Q[1-4]$', 'once'))));
shortQuarter = str2double(extractBefore(shortLabels,'Q'))*4 ...
    + str2double(extractAfter(shortLabels,'Q'));
shortRate = cell2mat(rawShort(2:end,2));
assert(numel(unique(longQuarter)) == numel(longQuarter));
assert(numel(unique(shortQuarter)) == numel(shortQuarter));

[commonQuarter, il, is] = intersect(longQuarter, shortQuarter);
longRate = longRate(il);
shortRate = shortRate(is);
assert(all(isfinite(longRate)) && all(isfinite(shortRate)));
assert(all(diff(commonQuarter)==1), 'The common sample has missing quarters.');
commonYear = floor((commonQuarter-1)/4);
commonQ = mod(commonQuarter-1,4)+1;
x = commonYear + (commonQ-1)/4;
sample = sprintf('%dQ%d--%dQ%d', commonYear(1),commonQ(1),commonYear(end),commonQ(end));
data=table(string(commonYear)+"Q"+string(commonQ),longRate,shortRate, ...
    'VariableNames',{'Quarter','HLW_LongRun_AnnualPercent','Curdia_ShortRun_AnnualPercent'});
writetable(data,fullfile(resultDir,'us_natural_rates.csv'));
fprintf('Common sample: %s, N=%d\n', sample, numel(x));
fprintf('Annualized percent: HLW first/last %.9f %.9f, Curdia first/last %.9f %.9f\n', ...
    longRate(1),longRate(end),shortRate(1),shortRate(end));
fprintf('Sample standard deviation: HLW %.9f, Curdia %.9f\n',std(longRate),std(shortRate));

fig = figure('Color','w','Position',[100 100 1100 510], ...
    'Visible','off','Name','US natural rates','NumberTitle','off');
ax = axes(fig,'Position',[0.085 0.18 0.89 0.72]);
hold(ax,'on');
hShort = plot(ax,x,shortRate,'-','Color',[0.80 0.27 0.12],'LineWidth',1.8);
hLong = plot(ax,x,longRate,'-','Color',[0.08 0.27 0.58],'LineWidth',2.5);
yline(ax,0,':','Color',[0.42 0.42 0.42],'LineWidth',1,'HandleVisibility','off');
ax.FontName = 'Times New Roman';
ax.FontSize = 15;
ax.LineWidth = 0.8;
ax.TickDir = 'out';
ax.Box = 'off';
ax.XGrid = 'off';
ax.YGrid = 'on';
ax.GridAlpha = 0.14;
ax.XLim = [x(1), x(end)];
ax.XTick = 1990:5:2025;
ax.YLim = [5*floor(min([longRate;shortRate])/5), 5*ceil(max([longRate;shortRate])/5)];
ylabel(ax,'年化百分比（%）','FontName','SimSun','FontSize',16);
lg = legend(ax,[hLong hShort],{'长期自然利率（HLW，2023）', ...
    '短期自然利率（Cúrdia, 2026）'},'Location','northoutside', ...
    'Orientation','horizontal','Box','off','Interpreter','none');
lg.FontName = 'SimSun';
lg.FontSize = 16;
annotation(fig,'textbox',[0.085 0.025 0.89 0.065], ...
    'String','数据来源：Holston, Laubach and Williams（2023）；Cúrdia (2026)。', ...
    'FontName','SimSun','FontSize',13,'Interpreter','none', ...
    'EdgeColor','none','Margin',0,'VerticalAlignment','middle');
fig.UserData = struct('sample',sample,'quarter',commonQuarter, ...
    'longRate',longRate,'shortRate',shortRate,'unit','Annualized percent', ...
    'longSource','data/长期自然利率.xlsx','shortSource','data/短期自然利率.xlsx');
drawnow;
savefig(fig,fullfile(figureDir,'us_natural_rates.fig'));
exportgraphics(fig,fullfile(figureDir,'us_natural_rates.png'),'Resolution',400);
if showFigures, set(fig,'Visible','on'); else, close(fig); end
end
