
fs = require 'fs'
http = require 'http'

class @Server
    constructor: (@_port) ->
        @http = http.createServer @_requestHandler

    listen: =>
        @http.listen @_port
        
    _serveFile: (url, res) =>
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

    _requestHandler: (req, res) =>
        url = req.url
        @_serveFile url, res

