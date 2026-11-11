"""Lossless sprite-atlas extraction and deterministic architectural pixel layer.
Generated artwork is not repainted/pixelized. Crops preserve the original alpha.
"""
from PIL import Image, ImageDraw
from pathlib import Path
import json, random, shutil
ROOT=Path(__file__).resolve().parents[1]
OUT=ROOT/'assets/images/workshop_v2'
OUT.mkdir(parents=True,exist_ok=True)
ATLAS=ROOT/'art_sources/objects_atlas.png'
HARBOR=ROOT/'art_sources/harbor_dusk.png'
im=Image.open(ATLAS).convert('RGBA');w,h=im.size
names=[['chair','desk','bookcase','mailbox'],['chest','basket','cat','rug'],['lamp','mug','ivy','window_frame']]
manifest={}
for row in range(3):
    boundaries=[0,w//4,w//2,3*w//4,w]
    if row==1:boundaries[3]=round(w*.735) # Rug silhouette extends left of nominal cell.
    for col,name in enumerate(names[row]):
        row_edges=[0,390,700,h]
        box=(boundaries[col],row_edges[row],boundaries[col+1],row_edges[row+1])
        cell=im.crop(box)
        alpha=cell.getchannel('A');bounds=alpha.point(lambda value:255 if value>=16 else 0).getbbox()
        assert bounds, name
        bounds=(max(0,bounds[0]-2),max(0,bounds[1]-2),min(cell.width,bounds[2]+2),min(cell.height,bounds[3]+2))
        sprite=cell.crop(bounds)
        sprite.save(OUT/f'{name}.png')
        manifest[name]={'source_cell':box,'trim':bounds,'size':sprite.size,
            'kind':'static_sprite','alpha':True,'status':'v0.2 generated art pass; art-director polish pending'}
shutil.copyfile(HARBOR,OUT/'harbor_dusk.png')
# Native pixel architecture. No part of the reference image is flattened here.
r=random.Random(721);W,H=384,432
wall=Image.new('RGBA',(W,H),'#3a2628');d=ImageDraw.Draw(wall)
for x in range(0,W,24):
    color=r.choice(['#53342d','#593830','#604036','#4d302b'])
    d.rectangle((x,0,x+22,327),fill=color)
    d.line((x+1,0,x+1,327),fill='#88543c');d.line((x+23,0,x+23,328),fill='#2d2225')
    for k in range(100):
        xx=x+r.randrange(3,21);yy=r.randrange(328);length=r.randrange(2,18)
        d.line((xx,yy,xx,min(327,yy+length)),fill=r.choice(['#634333','#6c4937','#49312b']))
    for yy in [48+x%37,201+x%43]:
        d.ellipse((x+6,yy,x+12,yy+5),outline='#35262a');d.line((x+8,yy+2,x+10,yy+2),fill='#9c6745')
# floor boards with consistent front-facing shallow perspective
for y in range(307,H,17):
    d.rectangle((0,y,W,y+16),fill=r.choice(['#7d5037','#82573c','#906044','#76503a']))
    d.line((0,y,W,y),fill='#c08856');d.line((0,y+16,W,y+16),fill='#39282a')
    for x in range(-50+(y%34)*2,W,69):
        d.line((x,y,x+3,y+16),fill='#3b2928')
    for _ in range(50):
        x=r.randrange(W);yy=y+r.randrange(3,14)
        d.line((x,yy,min(W,x+r.randrange(3,23)),yy),fill=r.choice(['#a17048','#694633','#b37b50']))
# skirting, framing beams, copper nail heads
for box in [(0,0,383,9),(0,297,383,307),(0,0,7,306),(376,0,383,306)]:
    d.rectangle(box,fill='#362329');x,y,a,b=box
    d.rectangle((x+1,y+1,a-1,b-1),fill='#81503a')
    d.line((x+2,y+2,a-2,y+2),fill='#c18b58')
for x in range(16,384,44):
    d.rectangle((x,3,x+1,4),fill='#d0a16a');d.rectangle((x,302,x+1,303),fill='#d0a16a')
wall.save(OUT/'architecture.png')
wall.crop((0,330,384,432)).save(OUT/'floor_tile.png')
manifest['floor_tile']={'size':[384,102],'kind':'native_pixel_floor_extension','status':'v0.2 code-authored repeatable floor'}
manifest['architecture']={'size':[W,H],'kind':'native_pixel_architecture','status':'v0.2 code-authored pixel layer'}
manifest['harbor_dusk']={'size':Image.open(HARBOR).size,'kind':'replaceable_outdoor_layer','status':'v0.2 generated static dusk art'}
(OUT/'provenance.json').write_text(json.dumps(manifest,ensure_ascii=False,indent=2))
print('Prepared',len(manifest),'independent assets; all sprite alpha preserved')
