floor = Math.floor

module.exports =

  # partition
  # --
  # Partition

  partition: (opend, subdivList, minList, maxList)->

    subdiv0 = subdivList[0]
    subdiv1 = subdivList[1]
    subdiv2 = subdivList[2]
    subdiv3 = subdivList[3]
    subdiv4 = subdivList[4]
    subdiv5 = subdivList[5]

    min0 = minList[0]
    min1 = minList[1]
    min2 = minList[2]
    min3 = minList[3]
    min4 = minList[4]
    min5 = minList[5]

    max0 = maxList[0]
    max1 = maxList[1]
    max2 = maxList[2]
    max3 = maxList[3]
    max4 = maxList[4]
    max5 = maxList[5]

    scale0 = subdiv0/(max0-min0)
    scale1 = subdiv1/(max1-min1)
    scale2 = subdiv2/(max2-min2)
    scale3 = subdiv3/(max3-min3)
    scale4 = subdiv4/(max4-min4)
    scale5 = subdiv5/(max5-min5)

    subdiv = subdiv0*subdiv1*subdiv2*subdiv3*subdiv4*subdiv5
    totalList = new Int32Array(subdiv)

    for value0, i in opend by 6
      value1 = oppum[i+1]
      value2 = oppum[i+2]
      value3 = oppum[i+3]
      value4 = oppum[i+4]
      value5 = oppum[i+5]

      index0 = value0 < min0 ? 0 : value0 >= max0 ? subdiv0-1 : (value0-min0)*scale0|0
      index1 = value1 < min1 ? 0 : value1 >= max1 ? subdiv1-1 : (value1-min1)*scale1|0
      index2 = value2 < min2 ? 0 : value2 >= max2 ? subdiv2-1 : (value2-min2)*scale2|0
      index3 = value3 < min3 ? 0 : value3 >= max3 ? subdiv3-1 : (value3-min3)*scale3|0
      index4 = value4 < min4 ? 0 : value4 >= max4 ? subdiv4-1 : (value4-min4)*scale4|0
      index5 = value5 < min5 ? 0 : value5 >= max5 ? subdiv5-1 : (value5-min5)*scale5|0

      index = (((((index0*
        subdiv1+index1)*
        subdiv2+index2)*
        subdiv3+index3)*
        subdiv4+index4)*
        subdiv5+index5)

      total = totalList[index]
      #indexListList[index][total] = i
      totalList[index] = total+1

    totalList

  # match
  # --
  # Match

  match: (opend0, opend1)->
