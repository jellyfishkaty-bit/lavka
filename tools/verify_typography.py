"""Verify actual font registration, genuine weights and Russian glyphs in an APK."""
import io,json,sys,zipfile,hashlib
from fontTools.ttLib import TTFont
required='АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯабвгдеёжзийклмнопрстуфхцчшщъыьэюя0123456789«»УзорыПисьмаНаградыПроекты'
with zipfile.ZipFile(sys.argv[1]) as apk:
 manifest=json.loads(apk.read('assets/flutter_assets/FontManifest.json'))
 for family,weights in [('Montserrat',[400,500,600,700]),('Handjet',[500,600])]:
  entry=next(e for e in manifest if e['family']==family)
  assert sorted(f['weight'] for f in entry['fonts'])==weights
  for f in entry['fonts']:
   data=apk.read('assets/flutter_assets/'+f['asset']);font=TTFont(io.BytesIO(data))
   assert font['OS/2'].usWeightClass==f['weight']
   chars=set().union(*(set(t.cmap) for t in font['cmap'].tables))
   assert all(ord(c) in chars for c in required)
   print(family,f['weight'],'Russian glyphs PASS',hashlib.sha256(data).hexdigest())
 for family in ['Handjet','Montserrat']:assert apk.read(f'assets/flutter_assets/assets/fonts/{family}-OFL.txt')
print('PASS: offline font families, weights, Cyrillic and licenses in APK')
