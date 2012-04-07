class @ChatClient
    constructor: (addr, @container, @nick) ->
        @socket = io.connect addr
        @socket.on 'connected', (data) => this.id = data['id']
        @socket.on 'msg', this.recvMsg
        @socket.on 'join', this.recvJoin
        @socket.on 'leave', this.recvLeave
        @socket.on 'new_nick', this.recvNewNick

        @msg_buffer = []
        @nicks_by_id = {}
        setNick nick if nick

    getNick: =>
        this.nicks_by_id[@id]

    sendMsg: (msg) =>
        @socket.emit("msg", {msg:msg})

    setNick: (nick) =>
        @socket.emit("nick", {nick:nick})

    recvMsg: (data) =>
        console.log("recvMsg", data)

        nick = $("<span/>")
            .addClass("nick")
            .text(data.nick)

        msg = $("<span/>")
            .addClass("msg")
            .text(data.msg)

        nick_join = $("<span/>")
            .addClass("nick_msg")
            .append(nick)
            .append(": ")
            .append(msg)
            .appendTo(@container)

    recvJoin: (data) =>
        console.log("recvJoin", data)
        @nicks_by_id[data.id] = data.nick

        nick = $("<span/>")
            .addClass("nick")
            .text("#{data.nick}")

        nick_join = $("<span/>")
            .addClass("nick_join")
            .append(nick)
            .append(" has joined")
            .appendTo(@container)

    recvLeave: (data) =>
        console.log("recvLeave", data)

        nick = $("<span/>")
            .addClass("nick")
            .text("#{@nicks_by_id[data.id]}")

        nick_leave = $("<span/>")
            .addClass("nick_leave")
            .append(nick)
            .append(" has leave")
            .appendTo(@container)

    recvNewNick: (data) =>
        console.log("recvNewNick", data)

        nick_old = $("<span/>")
            .addClass("nick_old")
            .text("#{@nicks_by_id[data.id]}")
        
        nick_new = $("<span/>")
            .addClass("nick_new")
            .text("#{data.new_nick}")

        nick_status = $("<span/>")
            .addClass("nick_status")
            .append(nick_old)
            .append(" changed to ")
            .append(nick_new)
            .appendTo(@container)

        @nicks_by_id[data.id] = data.new_nick
