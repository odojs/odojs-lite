{ component, hub, dom } = require 'odojs'
exe = require 'odoql-exe'
relay = require 'odo-relay'
odoql = require 'odoql/odojs'
component.use odoql

hub = hub()
exe = exe hub: hub

router = component
  render: (state, params, hub) ->
    params.autocomplete ?= {}
    dom '#root', [
      dom 'p', 'Odo.js'
    ]

root = document.querySelector '#root'
scene = relay root, router, exe, hub: hub

hub.every 'update', (p, cb) ->
  scene.update p
  cb()

scene.update {}
