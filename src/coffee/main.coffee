Image = require './image'
Task = require('./library') require './task'

fround = Math.fround
sqrt = Math.sqrt
exp = Math.exp
pow = Math.pow
abs = Math.abs
atan2 = Math.atan2
ceil = Math.ceil
pi = Math.PI
tau = pi*2

erf = (x)->
  t = 1/(1+0.3275911*abs(x))
  y = 1-((((1.061405429*t-1.453152027)*t+1.421413741)*t-0.284496736)*t+0.254829592)*t*exp(-x*x)
  if x > 0 then y else -y

gaussian = (sigma)->
  length = ceil(sigma*6)|1
  radius = length/2
  kernel = new Float32Array(length)
  constant = 1/sqrt(tau)/sigma
  for i in [0..length-1]
    x0 = (i-radius)/sigma/sqrt(2)
    x1 = (i+1-radius)/sigma/sqrt(2)
    y = (erf(x1)-erf(x0))/2
    kernel[i] = y
  kernel

newContainer = ()->
  container = document.createElement('div')
  container.style.display = 'inline-block';
  results = document.getElementById('results')
  results.appendChild container
  container

newCanvas = (width, height, container)->
  canvas = document.createElement('canvas')
  context = canvas.getContext('2d')
  canvas.width = width
  canvas.height = height
  container.appendChild canvas
  container.appendChild document.createElement('br')
  context

url = 'https://farm4.staticflickr.com/3755/19651424679_aa20a63dba_b.jpg'
console.log url
Image.load url, (imageData)->

  # prepare image data

  width = imageData.width/2
  height = imageData.height

  datasetList = []
  for offset in [0, -width]

    container = newContainer()
    context = newCanvas width, height, container
    context.putImageData imageData, offset, 0
    image = context.getImageData 0, 0, width, height
    surface = Image.extract image, width, height

    dataset =
      width: image.width
      height: image.height
      surface: surface
      container: container
    datasetList.push dataset

  # convolute

  levels = 2
  sigmaList = (pow(2, 1+(level-1)/levels) for level in [0..levels+1])
  kernelList = (gaussian(sigmaList[level]) for level in [0..levels+1])

  for dataset in datasetList
    dataset.surfaceList = (null for level in [0..levels+1])
    for level in [0..levels+1]
      context = newCanvas dataset.width, dataset.height, dataset.container

      Task.convolute [kernelList[level], dataset.surface, dataset.width, dataset.height],
        [level, context, dataset], (surface, [level, context, dataset])->

          dataset.surfaceList[level] = surface
          imageData = Image.compact surface, context, dataset.width, dataset.height
          context.putImageData imageData, 0, 0

  Task.__barrier__ null

  for dataset in datasetList
    dataset.keypointListListList = {}
    for method in ['trace', 'determinant', 'gaussian']
      context = newCanvas dataset.width, dataset.height, dataset.container

      Task.detect [method, dataset.surfaceList, kernelList, sigmaList, dataset.width, dataset.height],
        [method, context, dataset], (keypointListList, [method, context, dataset])->

          dataset.keypointListListList[method] = keypointListList
          Image.blot keypointListList, context

  Task.__barrier__ ()->

    for method in ['trace', 'determinant', 'gaussian']
      keypointListList0 = datasetList[0].keypointListListList[method]
      keypointListList1 = datasetList[1].keypointListListList[method]

      for color in [0..6-1]
        keypointList0 = keypointListList0[color]
        keypointList1 = keypointListList1[color]

        console.log keypointList0.length/6*keypointList1.length/6
