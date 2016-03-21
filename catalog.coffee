path = require 'path'
fs = require 'fs'

dir = path.join process.cwd(), 'wiki'
files = fs.readdirSync dir
results = []
for file in files
  continue if file.substr(-3) isnt '.md'
  continue if file[0] is '_'
  results.push file[0...-3]
results.sort (a,b) ->
  return -1 if a.filename < b.filename
  return 1 if a.filename > b.filename
  0
fs.writeFileSync 'catalog.json', JSON.stringify results, null, 2