# Image library provides functions that retrieve and manipulate ImageData object.

Surface = require './surface'

alpha = 1/16
colorList = [
  'rgba(255,0,0,'+alpha+')',
  'rgba(0,255,0,'+alpha+')',
  'rgba(0,0,255,'+alpha+')',
  'rgba(0,255,255,'+alpha+')',
  'rgba(255,0,255,'+alpha+')',
  'rgba(255,255,0,'+alpha+')',
]

fround = Math.fround
atan2 = Math.atan2
sqrt = Math.sqrt
abs = Math.abs
pi = Math.PI
tau = pi*2

module.exports =

  # load
  # --
  # Load image data from a url address. Turn it into an ImageData object.
  # Then, send it to a callback function.

  load: (url, callback)->
    image = new Image
    image.crossOrigin = "Anonymous"
    image.onload = (event)->
      canvas = document.createElement("canvas")
      canvas.width = image.width
      canvas.height = image.height
      context = canvas.getContext "2d"
      context.drawImage image, 0, 0
      imageData = context.getImageData 0, 0, image.width, image.height
      callback imageData
      null
    image.src = url
    null

  # extract
  # --
  # Convert a ImageData object into a 4-times-as-big Float32Array object.
  # For more detail, see Surface.extract() and Surface.downsize().

  extract: (image, width, height)->
    array = new Float32Array(width*height*4)
    size = width*height
    Surface.extract \
      array.subarray(width),
      array.subarray(size*2),
      array.subarray(width+size*2),
      image.data,
      height, width*2, width, 1
    stride = width*2
    while width >= 1 and height >= 1
      Surface.downsize array, array,
        height, stride, width, 1
      width >>= 1; height >>= 1
    array

  # compact
  # --
  # Map the 3 major color planes of a Float32Array object into 3 color channels of a 1/4-sized ImageData object.
  # For more detail, see Surface.compact().

  compact: (array, context, width, height)->
    image = context.createImageData width, height
    size = width*height
    Surface.compact \
      image.data,
      array.subarray(width),
      array.subarray(size*2),
      array.subarray(width+size*2),
      height, width*2, width, 1
    image

  # flatten
  # --
  # Map a Float32Array object into a same-sized grayscale ImageData object.
  # For more detail, see Surface.flatten().

  flatten: (array, context, width, height)->
    image = context.createImageData width*2, height*2
    size = width * height
    Surface.flatten image.data, array,
      height*2, width*2, width*2, 1
    image

  # blot
  # --

  blot: (keypointListList, context)->
    context.globalCompositeOperation = 'multiply'
    for keypointList, i in keypointListList
      context.fillStyle = colorList[i]
      for offset in [0..keypointList.length-1] by 6

        g   = keypointList[offset+0]
        g0  = keypointList[offset+1]
        g1  = keypointList[offset+2]
        g00 = keypointList[offset+3]
        g01 = keypointList[offset+4]
        g11 = keypointList[offset+5]

        trc = (g00+g11)/2
        det = g00*g11-g01*g01
        dif = sqrt(trc*trc-det)
        l0 = trc-dif
        l1 = trc+dif

        norm = fround(1/(g01*g01-g00*g11))
        u0 = fround(norm*(g0*g11-g1*g01))
        u1 = fround(norm*(g1*g00-g0*g01))
        th = atan2(-g01-g01, g00-g11)/2
        lg = sqrt(abs(l0*l1))
        r0 = sqrt(abs(lg/l0))
        r1 = sqrt(abs(lg/l1))

        context.save()
        context.translate u0, u1
        context.rotate th
        context.scale r0, r1
        context.beginPath()
        context.arc 0, 0, 2, 0, tau
        context.fill()
        context.restore()
