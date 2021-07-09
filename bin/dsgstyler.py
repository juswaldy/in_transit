#!/home/jus/tensorflow/bin/python
from __future__ import print_function

import sys
import os
import logging

if len(sys.argv) < 4:
	print('Usage: ' + sys.argv[0] + ' <style> <contentfilename> <numiterations>')
	sys.exit()

# Parameters.
style = sys.argv[1]
contentfilename = sys.argv[2]
iterations = int(sys.argv[3])

# Config.
content_weight = 0.05
style_weight = 5.0
total_variation_weight = 1.0
maxsize = 1024

# Files and logging stuff.
stylefolder = '/home/jus/notebook/jus/styletransfer/style/'
stylefilename = stylefolder + style

resultsfolder = '/home/jus/notebook/jus/styletransfer/dsgiitr/results/' + style
if not os.path.exists(resultsfolder):
	os.makedirs(resultsfolder)
resultsbasename = resultsfolder + '/' + os.path.basename(contentfilename)
resultsbasename = os.path.splitext(resultsbasename)[0] + '-s%2.2f-c%2.2f-t%2.2f' % (style_weight, content_weight, total_variation_weight)
logfile = resultsbasename + '.log'

formatter = logging.Formatter(fmt='%(asctime)s %(levelname)s - %(message)s', datefmt='%Y-%m-%d %H:%M:%S')
handler = logging.FileHandler(logfile, mode='a')
handler.setFormatter(formatter)
logger = logging.getLogger('dsgstyle')
logger.setLevel(logging.DEBUG)
logger.addHandler(handler)

logger.info('Starting up')

import numpy as np
from PIL import Image

from keras.applications.vgg16 import VGG16
from keras.applications.vgg16 import preprocess_input,decode_predictions

from keras import backend
from keras.models import Model
from scipy.optimize import fmin_l_bfgs_b
from scipy.misc import imsave

height = maxsize
width = maxsize
workingsize = (width, height)

content_image=Image.open(contentfilename)
originalsize = content_image.size
ratio = max(width/originalsize[0], height/originalsize[1])
resultsize = (int(originalsize[0]*ratio), int(originalsize[1]*ratio))
content_image=content_image.resize(workingsize)

style_image= Image.open(stylefilename)
style_image=style_image.resize(workingsize)

# Try fitting into working rectangle and fill with black.
#tempimage = Image.new(content_image.mode, size=style_image.size)
#tempimage.paste(content_image)
#content_image = tempimage

content_array=np.asarray(content_image,dtype='float32')
content_array=np.expand_dims(content_array,axis=0)

style_array=np.asarray(style_image,dtype='float32')
style_array=np.expand_dims(style_array,axis=0)

logger.info('Style: ' + stylefilename + ' - ' + str(style_array.shape))
logger.info('Content: ' + contentfilename + ' - ' + str(content_array.shape))

content_array[:, :, :, 0] -= 103.939
content_array[:, :, :, 1] -= 116.779
content_array[:, :, :, 2] -= 123.68
content_array=content_array[:, :, :, ::-1]

style_array[:, :, :, 0] -= 103.939
style_array[:, :, :, 1] -= 116.779
style_array[:, :, :, 2] -= 123.68
style_array=style_array[:, :, :, ::-1]
style_array.shape

width, height = content_image.size
content_image=backend.variable(content_array)
style_image=backend.variable(style_array)
combination_image=backend.placeholder((1,height,width,3))

input_tensor=backend.concatenate([content_image,style_image,combination_image],axis=0)

model=VGG16(input_tensor=input_tensor,weights='imagenet', include_top=False)

layers=dict([(layer.name, layer.output) for layer in model.layers])

loss=backend.variable(0.)

def content_loss(content, combination):
    return backend.sum(backend.square(content-combination))

layer_features=layers['block2_conv2']
content_image_features=layer_features[0,:,:,:]
combination_features=layer_features[2,:,:,:]
loss+=content_weight*content_loss(content_image_features,combination_features)

def gram_matrix(x):
    features=backend.batch_flatten(backend.permute_dimensions(x,(2,0,1)))
    gram=backend.dot(features, backend.transpose(features))
    return gram

def style_loss(style,combination):
    S=gram_matrix(style)
    C=gram_matrix(combination)
    channels=3
    size=height * width
    st=backend.sum(backend.square(S - C)) / (4. * (channels ** 2) * (size ** 2))
    return st

feature_layers = ['block1_conv2', 'block2_conv2',
                  'block3_conv3', 'block4_conv3',
                  'block5_conv3']

for layer_name in feature_layers:
    layer_features=layers[layer_name]
    style_features=layer_features[1,:,:,:]
    combination_features=layer_features[2,:,:,:]
    sl=style_loss(style_features,combination_features)
    loss+=(style_weight/len(feature_layers))*sl

def total_variation_loss(x):
    a=backend.square(x[:,:height-1,:width-1,:]-x[:,1:,:width-1,:])
    b = backend.square(x[:, :height-1, :width-1, :] - x[:, :height-1, 1:, :])
    return backend.sum(backend.pow(a + b, 1.25))
loss += total_variation_weight * total_variation_loss(combination_image)

grads = backend.gradients(loss, combination_image)

outputs=[loss]
if isinstance(grads, (list, tuple)):
    outputs += grads
else:
    outputs.append(grads)
f_outputs = backend.function([combination_image], outputs)

def eval_loss_and_grads(x):
    x = x.reshape((1, height, width, 3))
    outs = f_outputs([x])
    loss_value = outs[0]
    grad_values = outs[1].flatten().astype('float64')
    return loss_value, grad_values

class Evaluator(object):
    def __init__(self):
        self.loss_value=None
        self.grads_values=None
    
    def loss(self, x):
        assert self.loss_value is None
        loss_value, grad_values = eval_loss_and_grads(x)
        self.loss_value = loss_value
        self.grad_values = grad_values
        return self.loss_value

    def grads(self, x):
        assert self.loss_value is not None
        grad_values = np.copy(self.grad_values)
        self.loss_value = None
        self.grad_values = None
        return grad_values

evaluator=Evaluator()

x=np.random.uniform(0,255,(1,height,width,3))-128.0

import time
for i in range(1,iterations+1):
	logger.info('Start of iteration %03d' % i)
	start_time = time.time()
	x, min_val, info = fmin_l_bfgs_b(evaluator.loss, x.flatten(),
						   fprime=evaluator.grads, maxfun=20)
	logger.info('Loss value: ' + str(min_val))
	logger.info('More info: ' + str(info))
	end_time = time.time()
	logger.info('Iteration %03d completed in %ds' % (i, end_time - start_time))
	#
	y = x.astype('float64')
	y = y.reshape((height, width, 3))
	y = y[:, :, ::-1]
	y[:, :, 0] += 103.939
	y[:, :, 1] += 116.779
	y[:, :, 2] += 123.68
	y = np.clip(y, 0, 255).astype('uint8')
	#
	result = Image.fromarray(y)
	result = result.resize(resultsize)
	resultfilename = resultsbasename + ('-i%03d' % i) + '.jpg'
	result.save(resultfilename)
	result.close()

