"""Reproduce bundled static weights from official variable fonts. Requires fonttools."""
from pathlib import Path
from fontTools.ttLib import TTFont
from fontTools.varLib.instancer import instantiateVariableFont
root=Path(__file__).resolve().parents[1]
for family,weights in [('Montserrat',[400,500,600,700]),('Handjet',[500,600])]:
    font=TTFont(root/f'art_sources/fonts/{family}-variable.ttf')
    axes={a.axisTag:a.defaultValue for a in font['fvar'].axes}
    for weight in weights:
        axes['wght']=weight
        instance=instantiateVariableFont(font,axes,inplace=False)
        instance.save(root/f'assets/fonts/{family}-{weight}.ttf')
