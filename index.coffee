{ component, widget, hub, dom } = require 'odojs'
relay = require 'odo-relay'
exe = require 'odoql-exe'
odoql = require 'odoql/odojs'
component.use odoql

store = require 'odoql-store'
request = require 'superagent'
catalog = require './catalog.json'

caseiffound = (s) ->
  s = s.toUpperCase()
  for item in catalog
    return item if s is item.toUpperCase()
  s

getfilename = ->
  file = window.location.search
  file = file.substr 1 if file.length > 1
  file = 'home' if file is ''
  caseiffound file

getfilepath = -> "wiki/#{getfilename()}.md"

store = store()
  .use 'content', (params, cb) ->
    request
      .get getfilepath()
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
hljs = require 'highlight.js'
renderrichtext = widget
  render: (state, params) ->
    dom '.definition'
  afterMount: (el, state) ->
    @spec.onUpdate.call @, el, state
  onUpdate: (el, state) ->
    el.innerHTML = marked state
    hljs.highlightBlock code for code in el.querySelectorAll 'pre > code'
    for link in el.querySelectorAll 'a[href]'
      href = link.getAttribute 'href'
      continue if href.indexOf('/') isnt -1
      continue if href.indexOf(':') isnt -1
      continue if href.indexOf('#') isnt -1
      link.setAttribute 'href', "?#{caseiffound href}"

router = component
  query: (params) ->
    content: ql.store 'content'
  render: (state, params, hub) ->
    dom '#root.container', [
      dom 'a', { attributes: href: 'https://github.com/odojs/odojs' },
        dom 'img', attributes:
          style: 'position: absolute; top: 0; right: 0; border: 0;'
          src: 'https://camo.githubusercontent.com/a6677b08c955af8400f44c6298f40e7d19cc5b2d/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677261795f3664366436642e706e67'
          alt: 'Fork me on GitHub'
          'data-canonical-src': 'https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png'
      #dom 'h4.pull-right', dom 'a', { attributes: href: 'https://github.com/odojs/odojs.com' }, 'GitHub'
      dom 'h4', dom 'a', { attributes: href: './' }, 'Odo.js'
      dom '.row', [
        dom '.col-xs-3.toc', [
          dom 'h6', 'Table of contents'
          dom '.list-group', catalog.map (item) ->
            if getfilename() is item
              dom '.list-group-item.active', [
                dom 'span.pull-right', '▶'
                item
              ]
            else
              dom 'a.list-group-item', { attributes: href: "?#{item.toLowerCase()}" }, item
        ]
        dom '.col-xs-9.content', [
          dom 'h6', dom 'a', { attributes: href: "https://github.com/odojs/odojs/wiki/#{getfilename()}" }, getfilename()
          renderrichtext state.content
        ]
      ]
    ]

root = document.querySelector '#root'
scene = relay root, router, exe, hub: hub
scene.update()