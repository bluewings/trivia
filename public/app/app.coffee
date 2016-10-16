'use strict'

angular.module('seed', [
  'ngSanitize'
  'ngResource'
  'ngAnimate'
  'ui.router'
  'ui.bootstrap'
  'config'
]).config(($stateProvider, $locationProvider, $urlRouterProvider) ->

  $locationProvider.html5Mode false

  $urlRouterProvider.otherwise '/'

  $stateProvider.state 'wrap',
    abstract: true
    templateUrl: 'app/common/controllers/wrap.controller.html'
    controller: 'CommonWrapController'
    controllerAs: 'vm'

  $stateProvider.state 'home',
    url: '/'
    parent: 'wrap'
    templateUrl: 'app/common/controllers/home.controller.html'
    controller: 'CommonHomeController'
    controllerAs: 'vm'

  return

).run ($rootScope, $timeout) ->

  unless $.fn.$on
    $.fn.$on = (events, handler, execute, trigger) ->
      my = @
      uniq = parseInt(Math.random() * 100000, 10)
      events = events.replace(/([^\s])(\s|$)/g, '$1.' + uniq + '$2')
      my.each ->
        if trigger
          $(this).on events, ->
            $timeout handler
            return
        else
          $(this).on events, handler
        return
      if execute
        handler {}

      unbind = ->
        my.each ->
          $(this).off events
          return
        return

  return
