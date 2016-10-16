'use strict'

angular.module 'seed'
.service 'qrcode', ->

  canvas = document.createElement 'canvas'
  ctx = canvas.getContext '2d'

  checkBin = (n) ->
    /^[01]{1,64}$/.test n

  checkHex = (n) ->
    /^[0-9A-Fa-f]{1,64}$/.test n

  bin2Hex = (n) ->
    if !checkBin(n)
      return 0
    parseInt(n, 2).toString 16

  hex2Bin = (n) ->
    if !checkHex(n)
      return 0
    parseInt(n, 16).toString 2

  repeat = (pattern, count) ->
    if count < 1
      return ''
    result = ''
    while count > 1
      if count & 1
        result += pattern
      count >>= 1
      pattern += pattern
    result + pattern

  QRErrorCorrectLevel =
    L: 1
    M: 0
    Q: 3
    H: 2

  QRCodeLimitLength = [[17,14,11,7],[32,26,20,14],[53,42,32,24],[78,62,46,34],[106,84,60,44],[134,106,74,58],[154,122,86,64],[192,152,108,84],[230,180,130,98],[271,213,151,119],[321,251,177,137],[367,287,203,155],[425,331,241,177],[458,362,258,194],[520,412,292,220],[586,450,322,250],[644,504,364,280],[718,560,394,310],[792,624,442,338],[858,666,482,382],[929,711,509,403],[1003,779,565,439],[1091,857,611,461],[1171,911,661,511],[1273,997,715,535],[1367,1059,751,593],[1465,1125,805,625],[1528,1190,868,658],[1628,1264,908,698],[1732,1370,982,742],[1840,1452,1030,790],[1952,1538,1112,842],[2068,1628,1168,898],[2188,1722,1228,958],[2303,1809,1283,983],[2431,1911,1351,1051],[2563,1989,1423,1093],[2699,2099,1499,1139],[2809,2213,1579,1219],[2953,2331,1663,1273]]
  
  _getUTF8Length = (sText) ->
    replacedText = encodeURI(sText).toString().replace(/\%[0-9a-fA-F]{2}/g, 'a')
    replacedText.length + (if replacedText.length != sText then 3 else 0)

  _getTypeNumber = (sText, nCorrectLevel) ->
    nType = 1
    length = _getUTF8Length(sText)
    i = 0
    len = QRCodeLimitLength.length
    while i <= len
      nLimit = 0
      switch nCorrectLevel
        when QRErrorCorrectLevel.L
          nLimit = QRCodeLimitLength[i][0]
        when QRErrorCorrectLevel.M
          nLimit = QRCodeLimitLength[i][1]
        when QRErrorCorrectLevel.Q
          nLimit = QRCodeLimitLength[i][2]
        when QRErrorCorrectLevel.H
          nLimit = QRCodeLimitLength[i][3]
      if length <= nLimit
        break
      else
        nType++
      i++
    if nType > QRCodeLimitLength.length
      throw new Error('Too long data')
    nType

  make: (text, { cellSize: cellSize, margin: margin, blockSize: blockSize }) ->
    cellSize = 10 unless cellSize
    margin = 0 unless margin
    blockSize = 16 unless blockSize

    ERR_CORRECT_LEVEL = 'H'
    qr = qrcode(_getTypeNumber(text, QRErrorCorrectLevel[ERR_CORRECT_LEVEL]), 'H')
    qr.addData text
    qr.make()
    moduleCount = qr.getModuleCount()
    limitTo = Math.ceil(moduleCount / blockSize) * blockSize
    rows = []
    zeroPad = repeat '0', limitTo
    for row in [0...moduleCount]
      cols = []
      for col in [0...moduleCount]
        cols.push if qr.isDark(row, col) then 1 else 0
      rows.push (cols.join('') + zeroPad).substr(0, limitTo)

    html = []
    bin = ''
    firstChunk = true
    hexMerged = []
    for row, i in rows
      cols = row.split('')
      k = i % blockSize
      unless hexMerged[k]
        hexMerged[k] = []
      if k is 0
        if html.length > 0
          html.push '</div>' 
          firstChunk = false
        html.push '<div class="chunk">'
      rowHtml = []
      for col, j in cols
        if j % blockSize is 0
          if rowHtml.length > 0
            hexMerged[k].push bin2Hex(bin)
            rowHtml.push '<span class="hex">' + bin2Hex(bin) + '</span>'
            rowHtml.push '</span>' 
          bin = ''
          rowHtml.push '<span class="block">'
        bin += col
        rowHtml.push "<span class='bin bin-#{col}'>#{col}</span>"
      hexMerged[k].push bin2Hex(bin)
      rowHtml.push '<span class="hex">' + bin2Hex(bin) + '</span>'
      rowHtml.push '</span>'
      html.push '<p>'
      if firstChunk
        html.push "<img class='img-barcode img-barcode-#{i}'><span class='hex-merged'>[[#{i}]]</span>"
      html.push rowHtml.join('')
      html.push '</p>'
    html.push '</div>'
      # console.log cols

    text = rows.join '\n'
    html = html.join ''
    barcodes = []
    for hexCode, i in hexMerged
      # html = html.replace "[[#{i}]]", ''
      hexCode_ = hexCode.join '-'
      ctx.clearRect 0, 0, ctx.canvas.width, ctx.canvas.height
      JsBarcode canvas, hexCode_, {
        displayValue: false
        margin: 0
      }
      barcodes[i] = canvas.toDataURL()
      html = html.replace "[[#{i}]]", hexCode_

    # html = '<p>' + text.replace(/1/g, '<span class="bin bin-1">1</span>')
    #   .replace(/0/g, '<span class="bin bin-0">0</span>')
    #   .replace(/\n/g, '</p><p>') + '</p>'

    svg: qr.createSvgTag cellSize, margin
    text: text
    html: html
    barcodes: barcodes