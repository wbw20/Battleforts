from src.bitmap_converter import convert_bitmap
from glob import glob
import collections
import itertools
import os
import subprocess

def prepare_battleforts():
    print "Preparing battleforts..."

    bmp_pixels = collections.OrderedDict()
    bitmap_files = glob("img/bitmap/*.png")
    bitmap_files = [ os.path.abspath(rel_path) for rel_path in bitmap_files ]
    print "Converting bitmaps to pixel array..."
    num_bitmap_files = len(bitmap_files)
    for i in range(num_bitmap_files):
        print "Converting images: {}/{}".format(i+1, num_bitmap_files)
        file_name = os.path.splitext(os.path.basename(bitmap_files[i]))[0]
        print "Converting: {}".format(file_name)
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
            f.write("{}: .word 0x{}\n".format(bmp_name, ",0x".join(pixels)))
        f.write(main_partial_source)

    if not os.path.exists('built'):
        os.makedirs('built')

    with open("built/pixels.txt", 'w') as f:
        for bmp_name, pixels in bmp_pixels.items():
            f.write("{}\n".format(",".join(pixels)))

    all_pixels = bmp_pixels.values()
    total_number_of_pixels = len(list(itertools.chain(*all_pixels)))
    #print "Pixel Count: {}".format(total_number_of_pixels)
    data_file_length = len(open('built/pixels.txt', 'r').read())
    #print "Pixel Data File Size: {} characters".format(data_file_length)
    #print "Number of bytes necessary for buffer: {}".format(data_file_length*4)
    print "done."

if __name__ == '__main__':
    prepare_battleforts()
