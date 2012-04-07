io = require 'socket.io'
thoonk = require('thoonk')

class ChatClientProxy
    constructor: (@socket, _parent) ->
        @id = @socket.id
        @socket.on 'nick', this.setNick #no response
        @socket.on 'msg', this.sendMsg #no repsonse
        @socket.on 'leave', this.leave #no response
        @socket.on 'disconnect', this.disconnect #no response
        th = thoonk.createClient()
        @nicks = th.feed(_parent.feed_nicks)
        @messages = th.feed(_parent.feed_messages)

        # set my nick
        this.setNick({nick: @id})

        # subscribe 
        @nicks.subscribe {publish: this.recvJoin, edit: this.recvChangeNick, retract: this.recvLeave}
        @messages.subscribe ({publish: this.recvMsg})
        
        # transmit current nicks and messages
        this._transmitCurrent()

    _transmitCurrent: =>
        # first the nicks
        @nicks.getAll (err, reply) =>
            for item in reply
                this.recvJoin(null, item.id, item.item)
            
            # after msgs
            @messages.getAll (err, reply) =>
                for item in reply
                    this.recvMsg(null, item.id, item.item)

    recvJoin: (feed, id, nick) =>
        console.log("[#{this.id}] recvJoin: #{id} #{nick}")
        @socket.emit('join', {id: id, nick: nick})

    recvChangeNick: (feed, id, nick) =>
        console.log("[#{this.id}] recvNewNick: #{id} #{nick}")
        @socket.emit('new_nick', {id: id, new_nick: nick})

    recvLeave: (feed, id, data) =>
        console.log("[#{this.id}] recvLeave: #{id}")
        @socket.emit('leave', {id: id})

    recvMsg: (feed, id, data) =>
        console.log("[#{this.id}] recvMsg: #{id} #{data}")
        @socket.emit('msg', JSON.parse(data))

    sendMsg: (data, cb) =>
        from = this.id
        msg = data['msg']
        console.log("[#{this.id}] sendMsg: #{data}")
        @messages.publish(JSON.stringify({from:from, msg:msg, nick:@nick}))

    setNick: (data, cb) =>
        @nick = data['nick']
        console.log("[#{this.id}] setNick: #{data}")
        @nicks.publish(@nick, this.id)

    leave: (data, cb)=>
        nick = data['nick']
        console.log("[#{this.id}] leave: #{data}")
        @socket.disconnect()

    disconnect: (data) =>
        console.log("[#{this.id}] disconnect: #{data}")
        @nicks.retract(this.id)


class @Chat
    constructor: (app_or_port) ->
        @server = io.listen app_or_port
        @server.sockets.on 'connection', @_connectionDone
        
        @feed_nicks = 'chat-nicks'
        @feed_messages = 'chat-messages'

        th = thoonk.createClient()
        #clear
        th.mredis.send_command "flushdb", [], =>
            console.log("database cleared")

        # create feeds
        th.feed(@feed_nicks)
        th.feed(@feed_messages, {max_length: 10})

    _connectionDone: (socket) =>
        c = new ChatClientProxy(socket, this)
        socket.emit 'connected', {id:c.id}


