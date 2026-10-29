# Chapter 3: New Keynesian Model II

本仓库是《高级宏观经济学》第三章“新凯恩斯主义模型II”的配套 MATLAB 教学代码。从三方程 NK 模型出发，使用 BK 法求解模型，复现脉冲响应、均衡确定性区域、泰勒规则与最优货币政策的比较，并绘制课件中的自然利率对比图和 CGG（2000）历史数据图。

## 目录结构

- `codes/`：MATLAB主函数、校准、BK求解、绘图及测试函数。
- `codes/results/`：参数、脉冲响应、政策评价和数值验证结果。
- `figures/`：生成的图片及福利比较表。
- `data/`：自然利率对比图所需数据。
- `reference/`：文献来源、数据说明及CGG图形复现材料，不包含论文全文。

本包不含课件全文，不依赖其他章节或任何父目录文件。解压后可直接作为独立GitHub仓库；上传时将本目录内的文件作为仓库内容。

## 运行环境

- MATLAB R2023a（已验证）。
- 无需Dynare、额外MATLAB工具箱或联网下载数据。
- 中文绘图使用Microsoft YaHei和SimSun；其他操作系统请在绘图函数中改为本机支持中文的字体。

MATLAB需自行安装，不包含在压缩包中。

## 使用方法

1. 解压压缩包。
2. 将MATLAB当前文件夹切换到本仓库的`codes`，运行：

```matlab
results = NKII_main();
```

也可打开`codes/NKII_main.m`并点击“运行”，完整执行主函数。

运行后自动显示并保留9个图窗，同时覆盖更新`figures/`中的图表和`codes/results/`中的教学数据。如只需保存结果、不显示图窗，可运行`NKII_main(false)`。

修改参数请编辑`codes/nkii_calibration.m`，然后重新运行主函数。
