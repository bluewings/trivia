'use strict'

angular.module 'seed'
.directive 'activeBorder', ->
  restrict: 'A'
  # replace: true
  # templateUrl: 'app/common/directives/header.directive.html'
  # scope: true
  # bindToController: true
  # controllerAs: 'vm'
  # controller: ($scope) ->
  #   vm = @

  #   return
  link: (scope, element, attrs) ->
    # element.css 'position', 'relative'

    # console.log 'aaa'
    # return



    return if attrs.index isnt '1'

    padding = 10

    rect = element[0].getBoundingClientRect()
    # console.log rect

    canvas = document.createElement 'canvas'
    ctx = canvas.getContext '2d'

    element.append canvas

    $canvas = $(canvas)
    $canvas.css {
      position: 'absolute'
      top: padding * -1
      left: padding * -1
      # border: '1px solid black'
      pointerEvents: 'none'
    }
    canvas.width = rect.width + padding * 2
    canvas.height = rect.height + padding * 2


    dot = $(document.createElement('div'))
    element.append dot

    timer = 10

    dot.css({
      position: 'absolute'
      # top: -30
      left: 4
      # width: 30
      # height: 24
      top: -34
      lineHeight: '24px'
      # paddingLeft: 10
      # paddingRight: 10
      # marginTop: -24
      # marginLeft: -12
      # backgroundColor: '#666'
      # borderRadius: '50%'
      # textAlign: 'center'
      # lineHeight: '22px'
      fontSize: 24
      color: '#333'
      # display: 'none'

    # }).html('<i class="fa fa-clock-o" style="margin-right:5px"></i><span></span>').find('span').text timer
    }).html('<span style="font-family:Georgia;font-weight:bold"></span>').find('span').text timer

    totalLen = 0

    # paths = []
    paths = [
      [rect.width, 0]
      [rect.width, rect.height]
      [0, rect.height]
      [0, 0]
    ].reduce (arr, curr) ->
      last = arr[arr.length - 1]
      unless last
        last = x: 0, y: 0
      len = Math.sqrt(Math.pow(curr[0] - last.x, 2) + Math.pow(curr[1] - last.y, 2))
      totalLen += len
      arr.push {
        _x: last.x
        _y: last.y
        x: curr[0]
        y: curr[1]
        w: curr[0] - last.x
        h: curr[1] - last.y
        length: len
        beforeLen: totalLen - len
        accumLen: totalLen
      }


      arr
    , []

    # console.log totalLen
    # console.log paths



    # anim = null

    animate = ->
      anim = $({
        process: 0
      }).animate({
        process: 1
      }, {
        duration: 1500
        # easing: 'swing'
        easing: 'easeInQuad'
        # easing: 'easeInCirc'
        start: ->
          return

        step: (now, fx) ->
          # console.log now, fx
          # console.log now * totalLen
          requestAnimationFrame ->


            ctx.clearRect 0, 0, ctx.canvas.width, ctx.canvas.height

            ctx.translate padding + .5, padding + .5

            now = now * 1.25 - .25



            if now < 0
              # now = 0
              alpha = Math.abs(now * 4)
              ctx.strokeStyle = "rgba(0,0,0,#{alpha})"

              ctx.strokeRect 0, 0, rect.width, rect.height



              # ctx.fillStyle = "rgba(0,0,0,#{alpha})"
              # ctx.beginPath()
              # ctx.arc 0, 0, 2, 0, Math.PI * 2, true
              # ctx.fill()
              # ctx.closePath()

            else
              ctx.fillStyle = '#000'
              ctx.strokeStyle = '#000'


              currLen = now * totalLen




              ctx.beginPath()
              path = _.find paths, (each) ->
                if currLen < each.accumLen
                  return true
                ctx.moveTo each._x, each._y
                ctx.lineTo each.x, each.y


                return false



              if path
                delta = (currLen - path.beforeLen) / path.length
                x = path._x + path.w * delta
                y = path._y + path.h * delta
                ctx.moveTo path._x, path._y
                ctx.lineTo x, y
              ctx.stroke()

              ctx.closePath()
              if x or y
                ctx.beginPath()
                ctx.arc x, y, 3, 0, Math.PI * 2, true
                ctx.fill()
                ctx.closePath()
              

            ctx.translate -.5 - padding, -.5 - padding


                  # top: path._y + path.h * delta
                  # left: path._x + path.w * delta


              # console.log path
            return
          return

        complete: ->

          # ctx.clearRect 0, 0, ctx.canvas.width, ctx.canvas.height

          timer--
          if timer < 0
            timer = 10
          dot.find('span').text timer
          animate()
          return

      })

    animate()









    return