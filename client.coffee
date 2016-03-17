{ component, widget, hub, dom } = require 'odojs'
relay = require 'odo-relay'
exe = require 'odoql-exe'
odoql = require 'odoql/odojs'
component.use odoql

store = require 'odoql-store'
request = require 'superagent'

store = store()
  .use 'content', (params, cb) ->
    request
      .get 'README.md'
      .end (err, res) ->
        return cb err if err?
        return cb new Error res.text if not res.ok
        cb null, res.text

hub = hub()
exe = exe hub: hub
  .use store

ql = require 'odoql'
ql = ql
  .use 'store'

marked = require 'marked'
renderrichtext = widget
  render: (state, params) ->
    dom 'div.definition'
  afterMount: (el, state, params) ->
    el.innerHTML = marked params
  onUpdate: (el, state, params) ->
    el.innerHTML = marked params

router = component
  query: (params) ->
    content: ql.store 'content'
  render: (state, params, hub) ->
    dom '#root.container', [
      dom 'h4.pull-right', dom 'a', { attributes: href: 'https://github.com/odojs/odojs.com' }, 'GitHub'
      dom 'h4', dom 'a', { attributes: href: './' }, 'Odo.js'
      dom '.row', [
        dom '.col-xs-3.toc', [
          dom 'h6', 'Table of contents'
          dom '.list-group', [
            dom 'a.list-group-item', { attributes: href: '#' }, 'Item 1'
            dom 'a.list-group-item', { attributes: href: '#' }, 'Item 2'
          ]
        ]
        dom '.col-xs-9.content', [
          dom 'h6.pull-right', dom 'a', { attributes: href: 'https://github.com/odojs/odojs.com/edit/gh-pages/README.md' }, 'pull requests welcome & encouraged'
          dom 'h6', 'README.md'
          renderrichtext null, state.content
        ]
      ]
    ]

root = document.querySelector '#root'
scene = relay root, router, exe, hub: hub
scene.update()