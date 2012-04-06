io = require 'socket.io'

class @Chat
    constructor: (app_or_port) ->
        @server = io.listen app_or_port
        @server.sockets.on 'connection', @_connectionDone
    
    _connectionDone: (socket) =>
        socket.emit 'news', {hello:"world"}
        socket.on 'my other event', (data) ->
            console.log "join: ", data


