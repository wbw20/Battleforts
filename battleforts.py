from src.bitmap_converter import convert_bitmap
from glob import glob
import os
import subprocess

def prepare_battleforts():
    print "Preparing battleforts..."

    bmp_pixels = {}
    bitmap_files = glob("img/bitmap/*.png")
    bitmap_files = [ os.path.abspath(rel_path) for rel_path in bitmap_files ]
    print "Converting bitmaps to pixel array..."
    num_bitmap_files = len(bitmap_files)
    for i in range(num_bitmap_files):
        print "Converting images: {}/{}".format(i+1, num_bitmap_files)
        file_name = os.path.splitext(os.path.basename(bitmap_files[i]))[0]
        bmp_pixels[file_name] = convert_bitmap(bitmap_files[i])

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
        for bmp_name, pixels in bmp_pixels.items():
            f.write("{}: .word {}\n".format(bmp_name, ",".join(pixels)))
        f.write(main_partial_source)

    if not os.path.exists('built'):
        os.makedirs('built')

    with open("built/pixels.txt", 'w') as f:
        for bmp_name, pixels in bmp_pixels.items():
            f.write("{}: .word {}\n".format(bmp_name, ",".join(pixels)))

    print "All ready, launching MARS simulator!"
    subprocess.Popen(["java", "-jar", "Mars4_4.jar"])


if __name__ == '__main__':
    prepare_battleforts()
