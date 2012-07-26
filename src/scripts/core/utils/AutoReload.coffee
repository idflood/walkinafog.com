define [
  'socket.io'
], () ->
  #### AutoReload
  
  namespace "Next",
    AutoReload: class AutoReload
      constructor: () ->
        if @getURLParameter("dev") == "true"
          console.log "AutoReload init"
          socket = io.connect('http://localhost')
          socket.on 'reload', () ->
            console.log "reload!"
            window.location.reload(true)
      
      getURLParameter: (name) ->
        decodeURI((RegExp(name + '=' + '(.+?)(&|$)').exec(location.search)||[0,null])[1])
