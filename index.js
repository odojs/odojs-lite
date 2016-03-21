// Generated by CoffeeScript 1.9.2
var caseiffound, catalog, component, dom, exe, getfilename, getfilepath, hljs, hub, marked, odoql, ql, ref, relay, renderrichtext, request, root, router, scene, store, widget;

ref = require('odojs'), component = ref.component, widget = ref.widget, hub = ref.hub, dom = ref.dom;

relay = require('odo-relay');

exe = require('odoql-exe');

odoql = require('odoql/odojs');

component.use(odoql);

store = require('odoql-store');

request = require('superagent');

catalog = require('./catalog.json');

caseiffound = function(s) {
  var i, item, len;
  s = s.toUpperCase();
  for (i = 0, len = catalog.length; i < len; i++) {
    item = catalog[i];
    if (s === item.toUpperCase()) {
      return item;
    }
  }
  return s;
};

getfilename = function() {
  var file;
  file = window.location.search;
  if (file.length > 1) {
    file = file.substr(1);
  }
  if (file === '') {
    file = 'home';
  }
  return caseiffound(file);
};

getfilepath = function() {
  return "wiki/" + (getfilename()) + ".md";
};

store = store().use('content', function(params, cb) {
  return request.get(getfilepath()).end(function(err, res) {
    if (err != null) {
      return cb(err);
    }
    if (!res.ok) {
      return cb(new Error(res.text));
    }
    return cb(null, res.text);
  });
});

hub = hub();

exe = exe({
  hub: hub
}).use(store);

ql = require('odoql');

ql = ql.use('store');

marked = require('marked');

hljs = require('highlight.js');

renderrichtext = widget({
  render: function(state, params) {
    return dom('.definition');
  },
  afterMount: function(el, state) {
    return this.spec.onUpdate.call(this, el, state);
  },
  onUpdate: function(el, state) {
    var code, href, i, j, len, len1, link, ref1, ref2, results;
    el.innerHTML = marked(state);
    ref1 = el.querySelectorAll('pre > code');
    for (i = 0, len = ref1.length; i < len; i++) {
      code = ref1[i];
      hljs.highlightBlock(code);
    }
    ref2 = el.querySelectorAll('a[href]');
    results = [];
    for (j = 0, len1 = ref2.length; j < len1; j++) {
      link = ref2[j];
      href = link.getAttribute('href');
      if (href.indexOf('/') !== -1) {
        continue;
      }
      if (href.indexOf(':') !== -1) {
        continue;
      }
      if (href.indexOf('#') !== -1) {
        continue;
      }
      results.push(link.setAttribute('href', "?" + (caseiffound(href))));
    }
    return results;
  }
});

router = component({
  query: function(params) {
    return {
      content: ql.store('content')
    };
  },
  render: function(state, params, hub) {
    return dom('#root.container', [
      dom('a', {
        attributes: {
          href: 'https://github.com/odojs/odojs'
        }
      }, dom('img', {
        attributes: {
          style: 'position: absolute; top: 0; right: 0; border: 0;',
          src: 'https://camo.githubusercontent.com/a6677b08c955af8400f44c6298f40e7d19cc5b2d/68747470733a2f2f73332e616d617a6f6e6177732e636f6d2f6769746875622f726962626f6e732f666f726b6d655f72696768745f677261795f3664366436642e706e67',
          alt: 'Fork me on GitHub',
          'data-canonical-src': 'https://s3.amazonaws.com/github/ribbons/forkme_right_gray_6d6d6d.png'
        }
      })), dom('h4', dom('a', {
        attributes: {
          href: './'
        }
      }, 'Odo.js')), dom('.row', [
        dom('.col-xs-3.toc', [
          dom('h6', 'Table of contents'), dom('.list-group', catalog.map(function(item) {
            if (getfilename() === item) {
              return dom('.list-group-item.active', [dom('span.pull-right', '▶'), item]);
            } else {
              return dom('a.list-group-item', {
                attributes: {
                  href: "?" + item
                }
              }, item);
            }
          }))
        ]), dom('.col-xs-9.content', [
          dom('h6', dom('a', {
            attributes: {
              href: "https://github.com/odojs/odojs/wiki/" + (getfilename())
            }
          }, getfilename())), renderrichtext(state.content)
        ])
      ])
    ]);
  }
});

root = document.querySelector('#root');

scene = relay(root, router, exe, {
  hub: hub
});

scene.update();
