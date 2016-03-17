self.addEventListener 'message', (e) ->
  post = -> self.postMessage e.data
  setTimeout post, 2000