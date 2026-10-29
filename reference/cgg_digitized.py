"""Approximate Figure IV digitization from the locally preserved paper image.

Run: python cgg_digitized.py   (Python 3, numpy, Pillow)
No economic data are generated or fitted. Guides below are manually inspected
pixel coordinates, used only to distinguish the solid and dashed curves.
Within the guide corridor the actual dark pixels determine each curve.
Dashed-line gaps are interpolated. See the notes file for limitations.
"""
from pathlib import Path
import csv
import numpy as np
from PIL import Image, ImageDraw

ROOT=Path(__file__).resolve().parent
im=Image.open(ROOT/'CGG_Figure_IV_original.png').convert('RGB')
a=np.asarray(im.convert('L'))

# Annual tick positions read directly from the image, 1961 through 1997.
ticks=np.array([134,163,192,220,249,277,306,334,363,391,420,448,
               477,504,533,562,590,618,647,675,703,732,760,789,
               817,846,875,903,932,960.5,989,1017,1046,1074.5,
               1102.5,1131,1159.])
# y=12 at 12 pixels, y=-2 at 891 pixels; thus 62.786 pixels per point.
ytop,ybottom=12.,891.

# Solid inflation curve turning points, read from the paper raster.
solid=np.array([
 [135,622],[142,658],[149,658],[157,730],[164,730],[178,660],[184,660],
 [192,695],[220,696],[227,663],[256,664],[263,663],[270,632],[278,632],
 [285,600],[292,600],[299,537],[306,538],[320,606],[327,571],[334,517],
 [341,488],[348,519],[356,521],[364,496],[371,497],[378,470],[385,475],
 [392,419],[406,428],[413,460],[421,464],[435,419],[442,423],[449,479],
 [456,485],[463,537],[470,539],[478,520],[492,426],[506,295],[513,279],
 [520,286],[527,221],[534,91],[541,64],[548,216],[555,298],[570,354],
 [584,480],[592,425],[605,365],[613,389],[620,360],[627,349],[634,288],
 [641,278],[648,257],[655,267],[663,246],[670,241],[678,251],[685,232],
 [691,230],[698,203],[712,143],[719,178],[726,269],[734,319],[741,344],
 [748,365],[755,433],[768,518],[784,522],[797,495],[805,519],[812,520],
 [819,578],[826,547],[833,560],[840,561],[848,579],[855,606],[863,608],
 [869,620],[883,571],[897,571],[904,565],[912,565],[926,517],[934,493],
 [941,487],[948,510],[955,511],[962,540],[969,523],[977,496],[984,475],
 [991,487],[998,483],[1005,512],[1012,541],[1019,596],[1026,587],
 [1033,587],[1040,606],[1048,615],[1061,584],[1076,635],[1090,619],
 [1097,620],[1105,630],[1112,600],[1125,602],[1133,632],[1141,633],
 [1148,642],[1153,647]])
# Dashed ex-post real federal funds rate, independently inspected.
dashed=np.array([
 [135,708],[142,723],[149,755],[156,728],[164,702],[171,719],[178,722],
 [185,713],[192,661],[206,651],[220,639],[228,657],[235,648],[249,654],
 [256,651],[264,635],[272,638],[285,663],[292,656],[299,689],[306,673],
 [313,631],[320,626],[327,690],[334,775],[341,791],[348,708],[356,676],
 [363,666],[370,655],[377,647],[385,599],[392,581],[400,552],[412,564],
 [420,614],[427,704],[435,807],[442,824],[450,745],[456,755],[464,727],
 [470,734],[478,727],[485,736],[492,728],[499,668],[506,653],[513,626],
 [520,615],[527,629],[534,753],[541,831],[549,852],[557,841],[564,839],
 [571,817],[578,765],[584,735],[591,787],[598,814],[605,864],[613,835],
 [620,819],[627,795],[634,821],[641,803],[648,781],[655,707],[662,684],
 [670,654],[677,552],[684,514],[691,359],[698,478],[705,536],[712,532],
 [719,345],[726,145],[734,176],[741,197],[748,267],[755,254],[762,298],
 [770,406],[778,442],[785,445],[799,437],[806,402],[813,348],[819,297],
 [826,370],[834,428],[841,456],[848,452],[855,422],[862,445],[870,466],
 [877,551],[884,570],[892,558],[905,541],[912,531],[919,558],[926,568],
 [934,550],[941,505],[948,449],[955,424],[962,406],[969,465],[976,497],
 [983,539],[990,529],[998,569],[1005,590],[1013,599],[1020,590],
 [1027,626],[1034,678],[1041,696],[1048,708],[1062,755],[1076,712],
 [1084,711],[1091,706],[1098,672],[1105,633],[1112,629],[1119,585],
 [1126,567],[1133,529],[1141,538],[1153,544]])

def trace(guide):
    xs=np.arange(135,1154)
    ref=np.interp(xs,guide[:,0],guide[:,1])
    vals=np.full(xs.shape,np.nan,dtype=float)
    for k,(x,y) in enumerate(zip(xs,ref)):
        lo,hi=max(14,int(y)-7),min(889,int(y)+8)
        ys=np.arange(lo,hi+1)
        dark=ys[a[ys,x]<130]
        # Remove the horizontal zero axis and isolated scan artefacts.
        dark=dark[(dark<763)|(dark>766)]
        if len(dark):
            nearest=dark[np.argmin(abs(dark-y))]
            group=dark[abs(dark-nearest)<=2]
            vals[k]=np.mean(group)
    observed=np.isfinite(vals)
    vals=np.interp(xs,xs[observed],vals[observed])
    return xs,vals,observed

xs,sy,so=trace(solid)
_,dy,do=trace(dashed)
quarter_x=np.interp(np.arange(144)/4,np.arange(37),ticks)
rows=[]
for k,x in enumerate(quarter_x):
    inf=12-(np.interp(x,xs,sy)-ytop)*14/(ybottom-ytop)
    real=12-(np.interp(x,xs,dy)-ytop)*14/(ybottom-ytop)
    rows.append([f'{1961+k//4}Q{1+k%4}',round(x,4),round(inf,5),round(real,5)])
with (ROOT/'cgg_digitized.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['Quarter','PixelX','Inflation','RealRate']);w.writerows(rows)
# Dense traced pixels retain the original raster geometry as a diagnostic.
with (ROOT/'cgg_digitized_pixels.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['PixelX','InflationPixelY','RealRatePixelY','InflationObserved','RealRateObserved'])
    w.writerows(zip(xs,sy,dy,so.astype(int),do.astype(int)))
overlay=im.copy();draw=ImageDraw.Draw(overlay)
draw.line(list(zip(xs.tolist(),sy.tolist())),fill=(0,90,230),width=2)
draw.line(list(zip(xs.tolist(),dy.tolist())),fill=(220,40,40),width=2)
overlay.save(ROOT/'cgg_digitized_overlay.png')
print('Inflation observed fraction:',so.mean(),'Real-rate observed fraction:',do.mean())
print('CSV has',len(rows),'quarters from',rows[0][0],'to',rows[-1][0])
