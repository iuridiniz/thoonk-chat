io = require 'socket.io'

class ChatClientProxy
    constructor: (@socket) ->
        @socket.on 'nick', this.setNick
        @socket.on 'msg', this.sendMsg
        @socket.on 'people', this.sendNicks
        @socket.on 'msgs', this.sendMsgs
        @socket.on 'leave', this.leave
        @socket.on 'disconnect', this.leave

        @id = @socket.id

        @thoonk = require('thoonk').createClient()

        @nicks = @thoonk.feed('chat:nicks')
        @messages = @thoonk.feed('chat:messages', {max_length:50})

        this.setNick({nick: @id})

        @nicks.subscribe {publish: this.recvJoin, edit: this.recvChangeNick, retract: this.recvLeave}

        @messages.subscribe ({publish: console.log})

    recvJoin: (feed, id, data) =>
        nick = data['nick']
        @socket.emit('join', {id: id, nick: nick})

    recvChangeNick: (feed, id, data) =>
        console.log("new nick")
        nick = data['nick']
        @socket.emit('new_nick', {id: id, new_nick: nick})

    recvLeave: (feed, id, data) =>
        @socket.emit('leave', {id: id})

    recvMsg: (feed, id, data) =>
        console.log("recvMsg")
        @socket.emit('msg', JSON.parse(data))

    setNick: (data) =>
        nick = data['nick']
        console.log("setNick:", nick)
        @nicks.publish(JSON.stringify({nick:nick, id:this.id}), this.id)

    sendMsg: (data) =>
        from = this.id
        msg = data['msg']
        console.log "MSG '#{from}':'#{msg}'"
        @messages.publish(JSON.stringify({from:from, msg:msg}))

    sendNicks: =>
        console.log("sendNicks")
        @nicks.getAll (err, reply) =>
            console.log(reply)
            console.log(err)
            @socket.emit('people', reply)

    sendMsgs: =>
        console.log("sendMsgs")
        @messages.getAll (err, reply) =>
            console.log(reply)
            console.log(err)
            @socket.emit('msgs', reply)

    leave: =>
        console.log('quit')
        @nicks.retract(this.id)


class @Chat
    constructor: (app_or_port) ->
        @server = io.listen app_or_port
        @server.sockets.on 'connection', @_connectionDone

        @thoonk = require('thoonk').createClient()

        #clear
        #this.clear()

        @nicks = @thoonk.feed('chat:nicks')
        @messages = @thoonk.feed('chat:messages', {max_length:50})

    clear: =>
        @thoonk.mredis.send_command "flushdb", [], =>
            console.log("database cleared")
        
    _connectionDone: (socket) =>
        c = new ChatClientProxy(socket, this)
        socket.emit 'connected', {id:c.id}


