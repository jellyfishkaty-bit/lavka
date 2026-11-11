"""Extend the existing code-authored project yarn icon into Android launch tiles."""
from PIL import Image, ImageDraw
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
icon=Image.open(ROOT/'assets/images/icons/yarn.png').convert('RGBA')
base=Image.new('RGBA',(48,48),'#71374c');d=ImageDraw.Draw(base)
d.polygon([(6,1),(41,1),(46,6),(46,41),(41,46),(6,46),(1,41),(1,6)],fill='#ce9c60')
d.polygon([(7,4),(40,4),(43,7),(43,40),(40,43),(7,43),(4,40),(4,7)],fill='#4b302f')
d.rectangle((7,7,40,40),fill='#f2d8ac');base.alpha_composite(icon,(12,10))
for density,size in [('mdpi',48),('hdpi',72),('xhdpi',96),('xxhdpi',144),('xxxhdpi',192)]:
 base.resize((size,size),Image.Resampling.NEAREST).save(ROOT/f'android/app/src/main/res/mipmap-{density}/ic_launcher.png')
print('Android launcher icons prepared in five densities')
