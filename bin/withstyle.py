#!/usr/bin/python

import argparse
from PIL import Image, ImageDraw, ImageFont
from glob import glob

styleinfo = dict()

"""parsing and configuration"""
def parse_args():
    desc = "Put the style image at the bottom of content"
    parser = argparse.ArgumentParser(description=desc)

    parser.add_argument('--framefirst', type=int, default=None, help='From which frame?', required=True)

    parser.add_argument('--framelast', type=int, default=None, help='To which frame?', required=True)

    parser.add_argument('--contentfolder', type=str, default=None, help='Content folder', required=True)

    parser.add_argument('--stylefrom', type=str, default=None, help='From which style?', required=True)

    parser.add_argument('--styleto', type=str, default=None, help='To which style?', required=False)

    parser.add_argument('--outputfolder', type=str, default=None, help='Where to save the result?', required=True)

    return check_args(parser.parse_args())

"""checking arguments"""
def check_args(args):
    return args

"""style db"""
def style_db(style):
    style = style.replace("/home/jus/notebook/jus/styletransfer/style/", "")
    styleinfo["vid/isheworthy.jpg"] = ["Andrew Peterson", "Is He Worthy?"]
    styleinfo["common/starry.jpg"] = ["Vincent van Gogh", "Starry Night"]
    styleinfo["maya/wiggles_final.jpg"] = ["Maya Jusman", "Wiggles the Clown"]
    styleinfo["maya/wiggles-udnie.jpg"] = ["Maya Jusman + Francis Picabia", "Wiggles the Clown + Udnie"]
    styleinfo["maya/udnie-wiggles.jpg"] = ["Francis Picabia + Maya Jusman", "Udnie + Wiggles the Clown"]
    styleinfo["other/studentlife-reading.jpg"] = ["Unknown", "Untitled"]
    styleinfo["mira/MiraWolf1.jpg"] = ["Mira Jusman", "Lone"]
    styleinfo["mira/phoenix1.jpg"] = ["Mira Jusman", "Phoenix"]
    styleinfo["common/the_scream.jpg"] = ["Edvard Munch", "The Scream"]
    styleinfo["maya/forgodsoloved.jpg"] = ["Maya Jusman", "Present"]
    styleinfo["common/rain_princess.jpg"] = ["Leonid Afremov", "Rain Princess"]
    styleinfo["maya/mayadoodle.jpg"] = ["Maya Jusman", "Doodles #223"]
    styleinfo["jus/sheepface.jpg"] = ["Juswaldy Jusman", "Sheep #19"]
    styleinfo["common/la_muse.jpg"] = ["Pablo Picasso", "La Muse"]
    return styleinfo[style]

"""resize image"""
def resize(image, maxheight=188):
    result = image
    w, h = image.size
    hratio = maxheight / h
    w = int(hratio * w)
    w -= 0 if w % 2 == 0 else 1
    h = int(hratio * h)
    h -= 0 if h % 2 == 0 else 1
    result.thumbnail((w, h))
    return result

"""main"""
def main():

    # Parse arguments.
    args = parse_args()
    if args is None:
        print("Problem!")
        exit()

    fontnormal = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf", 20)
    fontitalic = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Oblique.ttf", 20)

    # Get the style images.
    style1 = Image.open(args.stylefrom)
    style2 = Image.open(args.styleto) if args.styleto else None

    # Resize first style.
    maxheight = 188
    style1 = resize(style1, maxheight)

    if style2:
        # Resize second style.
        style2 = resize(style2, maxheight)

        # Make style images uniform in size.
        width1 = style1.size[0]
        width2 = style2.size[0]
        maxwidth = max(width1, width2)
        s1 = Image.new('RGB', (maxwidth, maxheight))
        s2 = Image.new('RGB', (maxwidth, maxheight))
        s1.paste(im=style1, box=(int((maxwidth-width1)/2), 0))
        s2.paste(im=style2, box=(int((maxwidth-width2)/2), 0))

    # Make linear step increment.
    step = 1.0 / (1 + args.framelast - args.framefirst)

    # Generate content + combined style image + info for each frame.
    for i in range(args.framefirst, args.framelast+1):
        print("Processing {}".format(i)) if i % 10 == 0 else 0

        # Read content image.
        content = Image.open("{}/{:05}.jpg".format(args.contentfolder, i))

        # Figure out gradient.
        alpha = step * ((i - args.framefirst) + 1)

        # Make a black rectangle.
        x = Image.new('RGB', (1280, 720))

        # Center the styles and blend.
        x.paste(im=content, box=(0, 0))
        if style2:
            combined = Image.blend(s1, s2, alpha)
        else:
            combined = style1

        # Paste in the style(s).
        x.paste(im=combined, box=(640-int(combined.size[0]/2), 533))

        # Write artist + title info on image.
        artist, title = style_db(args.styleto) if args.styleto else style_db(args.stylefrom)
        d = ImageDraw.Draw(x)
        d.text((940,595), title, (255,255,255), font=fontitalic)
        d.text((940,635), artist, (255,255,255), font=fontnormal)

        # Save the file.
        filename = "{}/{:05}.jpg".format(args.outputfolder, i)
        x.save(filename)

if __name__ == '__main__':
    main()
