#!/usr/bin/env coffee
# npm -g install socket.io
# npm -g install coofee

io = require 'socket.io'
fs = require 'fs'
http = require 'http'

port = 8880

serveFile = (url, res) ->
    if url == '/'
        url = '/index.html'

    filename = __dirname + "/../public" + url
    fs.readFile filename, (err, data) ->
        if err and err.code == 'ENOENT'
            res.writeHead 404
            return res.end "url #{url} does not exist here"
        if err
            console.log "ERR: unable to process url: ", {url:url, err:err}
            res.writeHead 500
            return res.end "Cannot process your request"

        res.writeHead 200
        res.end data

requestHandler = (req, res) ->
    url = req.url
    serveFile url, res

connectionDone = (socket) ->
    socket.emit 'news', {hello: 'world'}
    socket.on 'my other event', (data) ->
        console.log "event2: ", data


app = http.createServer requestHandler
server = io.listen app
server.sockets.on 'connection', connectionDone

app.listen port

