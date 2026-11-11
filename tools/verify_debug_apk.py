"""Packaging regression gate for non-obfuscated Flutter debug APKs.

Host FFI tests cannot detect omitted Android plugins. Run after APK build.
Usage: python3 tools/verify_debug_apk.py path/to/app-debug.apk
"""
import sys
import struct
import zipfile


def defined_classes(dex):
    """Read class_def_item entries; a mere string/reference is insufficient."""
    if not dex.startswith(b'dex\n') or len(dex) < 112:
        raise ValueError('Unsupported or truncated DEX')
    string_offset = struct.unpack_from('<I', dex, 0x3C)[0]
    type_offset = struct.unpack_from('<I', dex, 0x44)[0]
    count, classes_offset = struct.unpack_from('<II', dex, 0x60)
    for index in range(count):
        type_index = struct.unpack_from('<I', dex, classes_offset + index * 32)[0]
        string_index = struct.unpack_from('<I', dex, type_offset + type_index * 4)[0]
        offset = struct.unpack_from('<I', dex, string_offset + string_index * 4)[0]
        while dex[offset] & 0x80:
            offset += 1
        offset += 1
        yield dex[offset:dex.index(b'\0', offset)]


def verify(path):
    with zipfile.ZipFile(path) as apk:
        dex_files = [name for name in apk.namelist() if name.endswith('.dex')]
        dex = [apk.read(name) for name in dex_files]
        required = {
            'Flutter Android plugin registration': b'Lio/flutter/plugins/GeneratedPluginRegistrant;',
            'sqflite Android implementation': b'Lcom/tekartik/sqflite/SqflitePlugin;',
        }
        classes = {name for data in dex for name in defined_classes(data)}
        missing = [label for label, descriptor in required.items()
                   if descriptor not in classes]
        for name in ['assets/flutter_assets/assets/data/schema_v1.sql',
                     'assets/flutter_assets/assets/images/icons/stole.png',
                     *[f'assets/flutter_assets/assets/fonts/Montserrat-{w}.ttf' for w in (400,500,600,700)],
                     *[f'assets/flutter_assets/assets/fonts/Handjet-{w}.ttf' for w in (500,600)],
                     'assets/flutter_assets/assets/fonts/Handjet-OFL.txt',
                     *['assets/flutter_assets/assets/fonts/'+name for name in ['Montserrat-OFL.txt']],
                     *['assets/flutter_assets/assets/images/workshop_v2/'+name+'.png' for name in ['architecture','harbor_dusk','window_frame','bookcase','chair','desk','mailbox','chest','rug','basket','cat','lamp','mug','ivy','floor_tile']]]:
            if name not in apk.namelist():
                missing.append(name)
        if missing:
            raise ValueError('APK incomplete: ' + ', '.join(missing))
    print('PASS: Android registration, sqflite plugin, schema, project icon, Cyrillic font and all v0.2 room assets packaged')


if __name__ == '__main__':
    try:
        verify(sys.argv[1])
    except (ValueError, zipfile.BadZipFile, IndexError) as error:
        print(str(error), file=sys.stderr)
        sys.exit(1)
