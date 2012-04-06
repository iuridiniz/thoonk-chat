io = require 'socket.io'

class ChatC
    constructor: (@socket, @_parent) ->
        @socket.on 'nick', this.setNick
        @socket.on 'join', this.joinChannel
        @socket.on 'leave', this.leaveChannel
        @socket.on 'msg', this.sendMsg
        @socket.on 'channels', this.sendChannels
        @socket.on 'people', this.sendNicks
        @socket.on 'quit', this.quit
        @socket.on 'disconnect', this.quit

        @id = @socket.id
        this.setNick({nick: this.id})

    setNick: (data) =>
        nick = data['nick']
        console.log("setNick:", nick)
        this._parent.nicks.publish(JSON.stringify({nick:nick, id:this.id}), this.id)

    joinChannel: (data) =>
        channel = data['channel']
        console.log("joinChannel:", channel)

    leaveChannel: (data) =>
        channel = data['channel']
        console.log("leaveChannel:", channel)

    sendMsg: (data) =>
        dest = data['dest']
        msg = data['msg']
        console.log("sendMsg:", dest, msg)

    sendChannels: =>
        console.log("sendChannels")

    sendNicks: =>
        console.log("sendNicks")
        this._parent.nicks.getAll (err, reply) =>
            console.log(reply)
            console.log(err)
            this.socket.emit('people', reply)

    quit: =>
        console.log('quit')
        this._parent.nicks.retract(this.id)
        this._parent = null


class @Chat
    constructor: (app_or_port) ->
        @server = io.listen app_or_port
        @server.sockets.on 'connection', @_connectionDone

        @thoonk = require('thoonk').createClient()

        #clear
        this.clear()

        @nicks = @thoonk.feed('chat:nicks')
        @channels = @thoonk.feed('chat:channels')
        @servermessages = @thoonk.feed('chat:servermessages')

        @servermessages.publish("start-time", Date())
        @connections = 0

    publishConnections: =>
        @servermessages.publish("connections", @connections)
    
    clear: =>
        @thoonk.mredis.send_command "flushdb", [], =>
            console.log("database cleared")
        
    _connectionDone: (socket) =>
        @connections++
        socket.on 'disconnect', =>
            @connections--
            this.publishConnections()
            
        c = new ChatC(socket, this)
        socket.emit 'connected', {id:c.id}
        this.publishConnections()


