'use strict'

angular.module 'seed'
.controller 'CommonHomeController', ($scope, $q, $element, $interval, $timeout, qrcode) ->  
  vm = @

  vm.players = [1..5]

  colors = [

    '#3277b5'
    '#ea2a29'
    '#f16729'
    '#f89322'
    '#ffcf14'
    '#ffea0d'
    '#87b11d'
    '#008253'
    '#3277b5'
    '#4c549f'
    '#764394'
    '#ca0d86'
  ]

  # vm.cards = [1..10]
  vm.cards = []

  vm.index = 3

  vm.next = ->
    vm.index++
    if vm.index >= vm.players.length
      vm.index = 0
    return

  # $interval ->
  #   vm.next()
  # , 1000

  vm.add = ->
    vm.cards.push vm.cards.length
    return


  vm.remove = ->
    vm.cards.pop()
    return


  suits = 'SCHD'
  ranks = '23456789JQKA'

  dealPIndex = 0

  rand = (target) ->
    Math.floor(Math.random() * target.length)



  deal = ->
    
    promises = []
    for i in [1..52]
      do (i) ->

        promises.push $q (resolve, reject) ->

          $timeout ->
            pIdx = rand vm.players
            pIdx = i % vm.players.length

            # console.log pIdx
            player = vm.players[pIdx]
            if player.cards.length < 10
              player.cards.push {
                suit: suits[rand(suits)]
                rank: ranks[rand(ranks)]
              }
            resolve()
          , i * 50

    $q.all promises
    .then ->

      $timeout ->
        undeal()
      , 1000

  undeal = ->
    
    promises = []
    for i in [1..52]
      do (i) ->

        promises.push $q (resolve, reject) ->

          $timeout ->
            pIdx = rand vm.players
            pIdx = i % vm.players.length

            # console.log pIdx
            player = vm.players[pIdx]
            player.cards.pop()
            resolve()
          , i * 50

    $q.all promises
    .then ->

      $timeout ->
        deal()
      , 1000

  # $timeout ->
  #   deal()
      
  # , 2000
  # $interval ->
  #   deal()
  # , 6000
  vm.players = []
  for i in [1..5]
    vm.players.push {
      color: colors[Math.floor(Math.random() * colors.length)]
      cards: []
    }

  $interval ->

    random = Math.floor(Math.random() * vm.players.length)

    player = vm.players[random]
    player.host = if player.host then false else true


    return
  , 2000

  return