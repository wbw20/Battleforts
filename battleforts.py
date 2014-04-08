from src.bitmap_converter import convert_bitmap
from glob import glob
import os
import subprocess

def prepare_battleforts():
    print "Preparing battleforts..."
    print "test"

    pixels = []
    bitmap_files = glob("img/bitmap/*.bmp")
    bitmap_files = [ os.path.abspath(rel_path) for rel_path in bitmap_files ]
    print "Converting bitmaps to pixel array..."
    num_bitmap_files = len(bitmap_files)
    for i in range(num_bitmap_files):
        print "Converting bmp {}/{}".format(i+1, num_bitmap_files)
        pixels.extend(convert_bitmap(bitmap_files[i]))

    main_partial_lines = []
    with open("src/main.asm") as f:
        for line in f.readlines():
            if '.data' in line:
                continue
            main_partial_lines.append(line)

    main_partial_source = "".join(main_partial_lines)

    print "Injecting bitmap data into battleforts assembly..."
    with open("src/main_complete.asm", 'w') as f:
        f.write(".data\n")
        f.write("list: .word {}\n".format(",".join(pixels)))
        f.write(main_partial_source)

    print "All ready, launching MARS simulator!"
    subprocess.Popen(["java", "-jar", "Mars4_4.jar"])


if __name__ == '__main__':
    prepare_battleforts()
