#!/usr/bin/env coffee 

# npm -g install socket.io
# npm -g install coofee
# npm -g install thoonk

port = 8880
http = require './server'
chat = require './chat'


server = new http.Server(port)

c = new chat.Chat(server.http)

server.listen()
