#!/usr/bin/python

from PIL import Image

for n in range(881,8664):
    f = "{:07d}.jpg".format(n)
    print(f)
    o = Image.open("original/{}".format(f)).convert('RGBA')
    g = Image.open("el-greco/{}".format(f)).convert('RGBA')
    x = Image.blend(o, g, alpha=0.5)
    x = x.convert('RGB')
    x.save("staging/{}".format(f))
