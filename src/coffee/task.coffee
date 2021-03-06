Surface = require './surface'
Measure = require './measure'
Extreme = require './extreme'
Feature = require './feature'
Match = require './match'

colorList = [0..5]

module.exports =

  # convolute
  # --
  # Convolute a Float32Array object with a Float32Array kernel both lengthwise and crosswise.
  # Return a new Float32Array with result. For more detail, see Surface.convolute().

  convolute: (kernel, surface, width, height)->
    count1 = height*2
    count0 = width*2
    radius = kernel.length>>1
    surface0 = surface
    surface1 = new Float32Array(surface.length)
    surface2 = new Float32Array(surface.length)

    Surface.convolute surface1, surface0, kernel,
      count1-radius*2, count0, count0, 1, kernel.length, count0
    Surface.convolute surface2.subarray((count0+1)*radius), surface1, kernel,
      count1-radius*2, count0, count0-radius*2, 1, kernel.length, 1

    surface2


  # detect
  # --
  # Detect keypoints from 3 consective Float32Array objects of a filter pyramid.

  detect: (method, surfaceList, kernelList, sigmaList, width, height)->
    count1 = height*2
    count0 = width*2
    size   = surfaceList[0].length
    levels = surfaceList.length-1
    levelListWithoutCeiling = [1..levels-1]
    levelListWithCeiling = [0..levels]
    borderList = ((kernel.length>>1)+1 for kernel in kernelList)

    #### surface measurement
    # Use the specified measuring function
    measureList = []
    for level in levelListWithCeiling
      measure = new Float32Array(size)
      surface = surfaceList[level]
      sigma   = sigmaList[level]
      Measure[method] measure, surface, sigma, count1, count0, count0, 1
      measureList.push measure

    #### non-extremum suppression
    extremeListList = []
    extremeOffsetListList = []
    extremeOffsetTotalList = (0 for color in colorList)
    for level in levelListWithoutCeiling
      extremeList = (new Int32Array(size>>4) for color in colorList)
      measure0    = measureList[if level == 0 then 1 else level-1]
      measure1    = measureList[level]
      measure2    = measureList[level+1]
      border      = borderList[level]
      offsetList  = Extreme.neighbor_6 extremeList, measure0, measure1, measure2, border, count1, count0, count0, 1
      extremeListList[level] = extremeList
      extremeOffsetListList[level] = offsetList
      for color in colorList
        extremeOffsetTotalList[color] += offsetList[color]

    #### keypoint description
    featureList = (new Float32Array(extremeOffsetTotalList[color]*3) for color in colorList)
    for color in colorList
      feature = featureList[color]
      for level in levelListWithoutCeiling
        surface = surfaceList[level]
        border  = borderList[level]
        extreme = extremeListList[level][color].subarray(0, extremeOffsetListList[level][color])
        offset  = Feature.gaussian feature, surface, extreme, count0, count1
        feature = feature.subarray(offset)
      featureList[color] = featureList[color].subarray(0, featureList[color].length-feature.length)
    featureList


  # match
  # --
  # Match keypoints from 2 Float32Array objects.
  match: (keypoint0, keypoint1)->
    statistic0 = Match.statistic keypoint0, [16,16,16,16,16,16], [-3e3,-1e1,-1e1,-3e-2,-3e-2,-3e-2], [3e3,1e1,1e1,3e-2,3e-2,3e-2]
    for totalList, i in statistic0
      console.log i, Array.prototype.slice.call totalList
    #partition0 = Match.partition keypoint0
    #partition1 = Match.partition keypoint1
    #match = Match.match partition0, partition1
