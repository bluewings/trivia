'use strict'

angular.module 'seed'
.directive 'playingCard', ($timeout) ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/common/directives/playing-card.directive.html'
  scope:
    client: '=client'
    message: '@message'
    suit: '@suit'
    rank: '@rank'
    frontColor: '@frontColor'
    number: '@number'
    open: '@open'
    highlight: '@highlight'
    size: '@size'
    cover: '@cover'
    valign: '@valign'
    flip: '@flip'
    content: '=content'

    badge: '@badge'
    disabled: '@disabled'
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope, $element) ->
    vm = @

    return

    vm.profile = null

    vm.character = null

    vm.checkSize = ->
      img = $element.find('.img-wrap img')[0]

      measure = ->
        $timeout ->
          rect = img.getBoundingClientRect()
          if vm.imgWidth isnt rect.width or vm.imgHeight isnt rect.height  
            $timeout ->
              vm.imgWidth = rect.width
              vm.imgHeight = rect.height 
              return
          return

      if img.complete
        measure()
      else
        img.onload = measure

      return

    $scope.$watch 'vm.client', (client) ->
      if client and client.profile
        vm.profile = client.profile
      else if client
        vm.profile = client
      return

    $scope.$watch 'vm.size', (size) ->
      $timeout ->
        vm.checkSize()
        return
      , 10
      $timeout ->
        vm.checkSize()
        return
      , 50
      $timeout ->
        vm.checkSize()
        return
      , 100
      return

    $scope.$watch 'vm.badge', (badge) ->
      if typeof badge isnt 'string'
        badge = ''
      tmp = badge.split(':')
      vm._badge = tmp[0]
      vm._badgeAnimation = ''
      if tmp.length > 1
        vm._badgeAnimation = tmp[1]
      return

    $element.find('.img-wrap').on 'transitionend webkitTransitionEnd', (event) ->
      vm.checkSize()
      return

    return

  link: (scope, element, attrs) ->

    return

    scope.vm.checkSize()
    return