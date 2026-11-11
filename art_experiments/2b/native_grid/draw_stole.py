"""Native 82x124 RGBA pixel drawing; no input image, resampling or AA."""
from PIL import Image
from pathlib import Path
W,H=82,124
im=Image.new('RGBA',(W,H),(0,0,0,0)); p=im.load()
# Four-tone material ramps, chosen in the concept's warm light.
ramps=[['#461f32','#702b46','#a13c59','#cb6177'],['#9b6049','#c58c60','#edc58a','#ffe2a9'],['#243c40','#35575a','#578180','#8caaa0']]
def rgba(h):return tuple(bytes.fromhex(h[1:]))+(255,)
ramps=[[rgba(v) for v in r] for r in ramps]
outline=rgba('#361d2c')
# Each control row describes intentionally stepped cloth edges.
controls=[(0,13,68),(3,9,71),(8,6,75),(13,5,76),(18,7,75),(25,9,74),(36,10,73),(52,9,74),(68,11,72),(81,13,70),(90,17,66),(98,25,58),(107,35,48)]
def edges(y):
 for (y0,l0,r0),(y1,l1,r1) in zip(controls,controls[1:]):
  if y0<=y<=y1:
   t=(y-y0)/(y1-y0);return round(l0+(l1-l0)*t),round(r0+(r1-r0)*t)
 return 36,47
mask=set()
for y in range(108):
 l,r=edges(y)
 for x in range(l,r+1):mask.add((x,y))
# Large V bands, three crests; drift bends pattern around two folds.
def pattern(x,y):
 fold=(2 if 24<x<31 else -1 if 53<x<61 else 0)
 phase=(x-9)%27
 wave=round(abs(phase-13)/1.65)
 return y-wave+fold
for x,y in mask:
 l,r=edges(y)
 if x-l<2 or r-x<2 or y<2: p[x,y]=outline;continue
 q=pattern(x,y)
 # broad stripes separated by plum fabric, not eight tiny stripe rows
 if 22<=q<33 or 62<=q<73: mat=1
 elif 40<=q<53:mat=2
 else:mat=0
 # Discrete fold shadows and three-pixel hand-charted V stitch clusters.
 shade=2
 if (24<=x<=28) or (56<=x<=59):shade=1
 if (29<=x<=32) or (49<=x<=52):shade=3
 if x<15 or x>68:shade=max(1,shade-1)
 u=(x-10)%4;v=(y-(x//4%2))%4
 if (u,v) in [(0,0),(3,0),(1,1),(2,1)]:shade=min(3,shade+1)
 elif (u,v) in [(1,2),(2,2)]:shade=max(0,shade-1)
 if y<16: # foreshortened portion on tabletop; fewer rows
  shade=1 if y in (9,10) else 2 if (x+y)%6 else 3
 p[x,y]=ramps[mat][shade]
# Lower hem follows triangular fall; tassels are distinct, uneven pairs.
for x,y0,length in [(13,82,13),(19,91,14),(26,99,13),(33,106,12),(40,109,14),(47,106,13),(54,99,14),(61,91,14),(68,82,14)]:
 for y in range(y0,min(124,y0+length)):
  for dx in range(3):
   if 0<=x+dx<W:p[x+dx,y]=outline if dx==0 else ramps[0][2 if dx==1 else 1]
# Intentional short highlight marks at front crease.
for x in range(11,72):
 y=16+((x//11)%2)
 if (x,y) in mask and x%7<4:p[x,y]=ramps[0][3]
out=Path(__file__).parent
im.save(out/'stole_native_82x124.png')
im.resize((W*6,H*6),Image.Resampling.NEAREST).save(out/'stole_6x.png')
assert set(im.getchannel('A').getdata())=={0,255}
print('82x124, alpha {0,255}, direct pixel drawing; colours:',len(im.getcolors()))
