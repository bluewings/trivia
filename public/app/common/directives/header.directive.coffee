'use strict'

angular.module 'seed'
.directive 'commonHeader', ->
  restrict: 'E'
  replace: true
  templateUrl: 'app/common/directives/header.directive.html'
  scope: true
  bindToController: true
  controllerAs: 'vm'
  controller: ($scope) ->
    vm = @

    return