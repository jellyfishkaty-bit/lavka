"""Original integer-grid pixel artwork. No source illustration is resampled.
Run with Pillow. Reproducible seed; room 216×240, icons 24×24 RGBA.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import random
random.seed(19)
ROOT = Path(__file__).resolve().parents[1] / 'assets/images'
W,H=216,240
P={'ink':'#291c26','shadow':'#35252b','wood':'#643b32','lightwood':'#986044','gold':'#d6a35e','cream':'#f2d4a1','wine':'#73374c','rose':'#b96570','teal':'#497d7b','blue':'#35506b','sky':'#253e56'}

def layer():
    im=Image.new('RGBA',(W,H)); return im,ImageDraw.Draw(im)
def rect(d,box,c):
    if box[2]>=box[0] and box[3]>=box[1]: d.rectangle(box,fill=P.get(c,c))
def framed(d,b,c='wood'):
    rect(d,b,'ink'); x,y,r,bottom=b
    rect(d,(x+1,y+1,r-1,bottom-1),'gold'); rect(d,(x+2,y+2,r-2,bottom-2),c)
def yarn(d,x,y,c='wine',r=6):
    d.ellipse((x-r,y-r,x+r,y+r),fill=P['ink']);d.ellipse((x-r+1,y-r+1,x+r-1,y+r-1),fill=P[c])
    for k in [-3,0,3]:d.line((x-r+3,y+k,x+2,y-r+2),fill=P['gold'])
    d.line((x-2,y+r-2,x+r-2,y),fill=P['cream'])

im,d=layer()
rect(d,(0,0,W,H),'wood')
for x in range(0,W,18):
    rect(d,(x,0,x+1,184),'shadow')
    for _ in range(20):
        y=random.randrange(185);rect(d,(x+random.randrange(3,15),y,x+15,y),'#704336')
for y in range(182,H,12):
    rect(d,(0,y,W,y+11),'#82503a');rect(d,(0,y,W,y),'gold')
    for x in range((y%24)*3-50,W,48):rect(d,(x,y,x+1,y+11),'shadow')
for b in [(0,0,215,7),(0,173,215,181)]:framed(d,b)
im.save(ROOT/'room/structure.png')

im,d=layer()
framed(d,(8,15,103,155),'blue');rect(d,(13,20,98,149),'sky')
d.ellipse((65,25,77,37),fill=P['cream']);d.ellipse((62,23,73,34),fill=P['sky'])
rect(d,(13,105,98,149),'#31596d')
for x,y,ww,hh in [(14,64,16,50),(31,77,19,35),(54,71,13,43),(78,84,20,32)]:
    rect(d,(x,y,x+ww,y+hh),'#233140');d.polygon([(x-2,y),(x+ww//2,y-12),(x+ww+2,y)],fill=P['wine'])
    for yy in range(y+6,y+hh-3,10):
        for xx in range(x+3,x+ww-2,7):rect(d,(xx,yy,xx+2,yy+4),'gold')
for _ in range(65):
    x=random.randrange(14,97);y=random.randrange(119,149);rect(d,(x,y,x+random.randrange(1,6),y),'#648486')
d.polygon([(46,125),(73,125),(66,132),(51,132)],fill=P['ink']);d.line((59,101,59,125),fill=P['cream']);d.polygon([(61,104),(70,121),(61,121)],fill=P['gold'])
im.save(ROOT/'room/harbor.png')

im,d=layer()
for x in (10,53,99):framed(d,(x,16,x+3,153))
for y in (57,103,150):framed(d,(9,y,103,y+3))
framed(d,(4,155,108,161),'lightwood')
# bookcase
framed(d,(118,13,207,155),'shadow')
for y in (47,79,113,150):
    framed(d,(119,y,206,y+4),'lightwood')
    x=124
    while x<198:
        w=random.randrange(4,8);h=random.randrange(16,30)
        rect(d,(x,y-h,x+w,y-1),random.choice(['wine','blue','teal','wood']))
        rect(d,(x+1,y-h+2,x+w-1,y-h+2),'gold');rect(d,(x+1,y-5,x+w-1,y-5),'gold');x+=w+2
for x,c in [(132,'cream'),(146,'teal'),(161,'wine'),(176,'rose'),(192,'wine')]:yarn(d,x,68,c)
# vines
for ox in (3,107,207):
    for y in range(7,138,7):
        x=ox+int(3*((y//7)%3-1));rect(d,(x,y,x+1,y+7),'gold')
        d.polygon([(x,y),(x+6,y+1),(x+4,y+5),(x,y+3)],fill='#657044');d.polygon([(x,y+3),(x-5,y+4),(x-4,y+8),(x,y+7)],fill='#394e3c')
im.save(ROOT/'room/interior.png')

im,d=layer()
# woven rug
framed(d,(16,200,196,232),'wine')
for y in range(204,229,4):
    for x in range(21,192,6):
        col='teal' if (x//6+y//4)%3==0 else 'gold';d.polygon([(x,y+1),(x+2,y-1),(x+4,y+1),(x+2,y+3)],fill=P[col])
# chair
framed(d,(7,135,47,194),'wine');framed(d,(3,156,14,202),'wine');framed(d,(43,156,53,202),'wine');framed(d,(12,180,45,195),'rose')
for x in range(16,39,4):
    rect(d,(x,143,x+2,183),'cream');rect(d,(x,158,x+2,162),'teal')
for x in (9,43):rect(d,(x,201,x+3,211),'shadow')
# desk
framed(d,(64,151,192,164),'lightwood');framed(d,(70,164,186,187),'wood')
for x in (73,176):framed(d,(x,187,x+6,214),'wood')
framed(d,(78,168,174,181),'wood');rect(d,(124,173,129,175),'gold')
# knitted stole hangs over desk
rect(d,(100,156,139,205),'wine')
for y in range(158,201):
    for x in range(102,138):
        c=['wine','rose','gold','cream','teal','blue'][((y+(abs((x-102)%18-9)))//4)%6]
        if (x+y)%2:rect(d,(x,y,x,y),c)
for x in range(101,140,3):rect(d,(x,205,x,211),'gold')
# lamp
rect(d,(83,111,85,150),'gold');framed(d,(75,148,94,152),'gold')
d.polygon([(84,110),(97,110),(105,125),(75,125)],fill=P['gold']);rect(d,(80,122,101,125),'cream')
# cup and notebook
framed(d,(145,140,156,151),'cream');d.rectangle((156,142,160,147),outline=P['gold'])
d.polygon([(164,136),(181,139),(177,152),(160,149)],fill=P['cream'])
for y in range(140,148,3):d.line((165,y,175,y+2),fill=P['wood'])
yarn(d,115,145,'wine',8)
# chest — decorative only
framed(d,(169,198,211,225),'wood');d.arc((169,187,211,212),180,360,fill=P['gold'],width=3)
for x in (176,202):rect(d,(x,198,x+2,224),'gold')
framed(d,(186,209,192,214),'gold')
# basket — project hotspot
framed(d,(69,199,97,221),'gold');d.arc((70,187,96,210),180,360,fill=P['gold'],width=2)
yarn(d,77,198,'teal');yarn(d,88,201,'rose')
for y in range(207,220,3):d.line((72,y,94,y),fill=P['wood'])
# sleepy cat
for box,c in [((26,216,60,228),'gold'),((48,210,62,224),'cream')]:d.ellipse(box,fill=P[c])
d.polygon([(48,214),(49,207),(53,212)],fill=P['gold']);d.polygon([(56,212),(62,208),(62,217)],fill=P['gold'])
d.line((51,217,54,218),fill=P['ink']);d.line((57,218,60,217),fill=P['ink'])
d.arc((28,217,46,227),20,320,fill=P['wood'],width=3)
# mailbox (inert decor)
framed(d,(196,123,210,144),'gold');rect(d,(199,128,207,129),'ink')
im.save(ROOT/'room/furniture.png')

# Icon silhouettes: real 24px sprites, outlined and shared palette.
ids=['shawl','scarf','stole','sweater','cardigan','socks','mittens','hat','blanket','toy','yarn','star','lighthouse','flower','basket','teacup']
for name in ids:
    im=Image.new('RGBA',(24,24));d=ImageDraw.Draw(im)
    c=P['rose'];g=P['gold'];t=P['teal'];ink=P['ink'];cream=P['cream']
    def box(b,fill=c):d.rectangle(b,fill=fill,outline=ink)
    if name=='shawl':d.polygon([(2,5),(21,5),(12,21)],fill=c,outline=ink);d.line((4,7,19,7),fill=g);d.line((7,11,17,11),fill=cream)
    elif name in ('scarf','stole','blanket'):
        box((4,3,19 if name!='scarf' else 12,20),t)
        for y in (6,10,14,18):d.line((5,y,18 if name!='scarf' else 11,y),fill=g)
        for x in range(5,19 if name!='scarf' else 12,3):d.line((x,20,x,22),fill=c)
    elif name in ('sweater','cardigan'):
        d.polygon([(7,4),(10,6),(14,6),(17,4),(22,10),(18,13),(17,10),(17,21),(6,21),(6,10),(4,13),(1,10)],fill=c,outline=ink)
        d.line((8,18,16,18),fill=g)
        if name=='cardigan':d.line((12,6,12,20),fill=cream)
    elif name=='socks':
        for x,y in [(3,2),(12,5)]:box((x,y,x+6,y+12),t);box((x,y+10,x+9,y+15),c);d.line((x+1,y+3,x+5,y+3),fill=cream)
    elif name=='mittens':
        for x,y in [(2,4),(13,6)]:box((x,y,x+6,y+12),c);box((x+6,y+5,x+8,y+9),c);d.line((x+1,y+10,x+5,y+10),fill=g)
    elif name=='hat':
        d.ellipse((4,5,19,21),fill=c,outline=ink);box((2,16,21,21),t);d.ellipse((9,1,14,6),fill=g,outline=ink)
    elif name=='toy':
        for b in [(4,3,9,9),(15,3,20,9),(7,11,17,21),(5,6,19,16)]:d.ellipse(b,fill=g,outline=ink)
        for x in (9,15):d.point((x,10),fill=ink)
        d.rectangle((10,13,14,14),fill=c)
    elif name=='yarn':yarn(d,12,13,'wine',9);d.line((17,5,21,1),fill=g,width=2)
    elif name=='star':d.polygon([(12,2),(15,8),(22,9),(17,14),(19,22),(12,18),(5,22),(7,14),(2,9),(9,8)],fill=g,outline=ink)
    elif name=='lighthouse':
        d.polygon([(8,8),(15,8),(18,22),(5,22)],fill=cream,outline=ink);box((7,4,16,9),g);box((8,13,16,16),c);d.polygon([(5,4),(12,0),(18,4)],fill=c);d.line((2,6,4,6),fill=g);d.line((19,6,22,6),fill=g)
    elif name=='flower':
        d.line((12,10,12,23),fill=t,width=2);d.ellipse((3,14,11,18),fill=t)
        for x,y in [(8,2),(3,7),(13,7),(8,12)]:d.ellipse((x,y,x+7,y+7),fill=c,outline=ink)
        d.rectangle((10,9,13,12),fill=g)
    elif name=='basket':
        d.arc((4,2,20,19),180,360,fill=g,width=2);box((3,11,21,21),g)
        for y in (14,17):d.line((4,y,20,y),fill=P['wood'])
        yarn(d,9,10,'teal',4);yarn(d,16,11,'wine',4)
    else:
        box((4,8,17,20),cream);d.rectangle((18,10,21,16),outline=g,width=2);d.line((7,3,7,5),fill=g);d.line((12,1,12,5),fill=g);d.line((2,22,20,22),fill=g)
    im.save(ROOT/f'icons/{name}.png')
print('4 room layers + 16 transparent icons generated')
