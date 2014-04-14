from PIL import Image

def convert_bitmap(filepath):
    im = Image.open(filepath)

    width = im.size[0]
    height = im.size[1]

    pixels = []

    # currently reducing to 1/10 number of original pixels
    for x in xrange(0, width):
        for y in xrange(0, height):
            pixels.append('0x{}'.format(rgb_to_hex(im.getpixel((x,y)))))

    return pixels

def rgb_to_hex(rgb):
    return '%02x%02x%02x' % rgb
