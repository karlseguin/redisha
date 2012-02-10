redis = require('redis')

class Server
  constructor: (@host, @port, @set) ->
    @redis = redis.createClient(@port, @host, {socket_nodelay: true})
    @redis.on 'error', (err) =>
      @set.failed(this)

    @redis.on 'close', (err) =>
      @set.failed(this)

    @redis.on 'connect', (a, b) =>
      @set.connect(this)

  ping: (callback) =>
    @redis.ping (err, data) ->
      callback(data == 'PONG')

  slaveOf: (server, callback) =>
    console.log(server?.port)
    if server?
      @redis.slaveof server.host, server.port, (err) =>
        callback(err)
    else
      @redis.slaveof 'NO', 'ONE', (err) =>
        callback(err)

module.exports = Server