#!/usr/bin/env coffee 
port = 8880
http = require './server'
chat = require './chat'

server = new http.Server(port)

c = new chat.Chat(server.http)

server.listen()
