# 数据与文献来源

## 美国长期与短期自然利率

`data/长期自然利率.xlsx` 和 `data/短期自然利率.xlsx` 保留课件使用的固定数据版本。`codes/plot_us_natural_rates.m` 读取两份工作簿，按季度取交集，不进行插值或再次平滑。纵轴单位为年化百分比。

- 长期自然利率：Holston, K., T. Laubach and J. C. Williams (2023), [Measuring the Natural Rate of Interest after COVID-19](https://www.newyorkfed.org/research/staff_reports/sr1063), Federal Reserve Bank of New York Staff Reports, No. 1063。工作簿使用其更新估计，读取 `HLW Estimates` 表第 K 列的美国单边自然利率估计。[纽约联储模型与数据页面](https://www.newyorkfed.org/research/policy/rstar)。
- 短期自然利率：Cúrdia, V. (2026), [Monetary Policy and the Medium-Run Natural Rate of Interest](https://doi.org/10.24148/wp2025-24), Federal Reserve Bank of San Francisco Working Paper 2025-24, revised May 2026。工作簿为论文 Figure 7 的季度曲线数值，使用全样本平滑估计，保留原工作簿标定的 1987Q2 至 2025Q4 日期及数值。工作簿内附来源与日期说明。

两者采用不同模型和估计信息集。本图用于比较课件所述长期趋势与短期波动。`codes/results/us_natural_rates.csv` 保存共同样本，便于复核图形。

## CGG Figure IV

Clarida, R., J. Galí and M. Gertler (2000), [Monetary Policy Rules and Macroeconomic Stability: Evidence and Some Theory](https://doi.org/10.1162/003355300554692), *Quarterly Journal of Economics*, 115(1), 147–180，Figure IV 位于第168页。

`cgg_digitized.csv` 为该图的近似数字化数据，包含1961Q1至1996Q4的144季。`Inflation` 为通胀率，`RealRate` 为事后真实利率，均为年化百分比。原曲线已经使用三季度中心移动平均，绘图函数直接使用这些数值。数字化方法见 [CGG 图形说明](cgg_digitized_notes.md)。

## 模型方法参考

- Blanchard and Kahn (1980), [The Solution of Linear Difference Models under Rational Expectations](https://doi.org/10.2307/1912186)：BK求解。
- Calvo (1983), [Staggered Prices in a Utility-Maximizing Framework](https://doi.org/10.1016/0304-3932(83)90060-0)：价格粘性。
- Clarida, Galí and Gertler (1999), [The Science of Monetary Policy: A New Keynesian Perspective](https://doi.org/10.1257/jel.37.4.1661)：三方程模型与最优政策。
- Bullard and Mitra (2002), [Learning about Monetary Policy Rules](https://doi.org/10.1016/S0304-3932(02)00144-7)：政策规则与均衡确定性。
- Blanchard and Galí (2007), [Real Wage Rigidities and the New Keynesian Model](https://doi.org/10.1111/j.1538-4616.2007.00015.x)：神圣巧合。
- Kydland and Prescott (1977), [Rules Rather than Discretion: The Inconsistency of Optimal Plans](https://doi.org/10.1086/260580)：承诺与时间不一致。
- Galí (2015), [Monetary Policy, Inflation, and the Business Cycle](https://press.princeton.edu/titles/10495.html), 2nd ed., Princeton University Press：模型推导与福利分析。
