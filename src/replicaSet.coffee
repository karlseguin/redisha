async = require('async')
Server = require('./server')

class ReplicaSet
  constructor: (@name, @config) ->
    @servers = []
    @downCount = 0

  @create: (name, config, callback) ->
    set = new ReplicaSet(name, config)
    set.master = new Server(config.master.host, config.master.port, set)
    set.slave = new Server(config.slave.host, config.slave.port, set)
    set.servers.push(set.master)
    set.servers.push(set.slave)
    callback(null)

  failed: (server) =>
    if server == @master
      console.log('master is down')
      @downCount += 1
      this.electMaster() if @downCount == 1

  electMaster: =>
    @master = null
    async.detect @servers, this.ping, (found) =>
      if found?
        console.log('found a new master on %d', found.port)
        found.slaveOf null, (err) =>
          return setTimeout(this.electMaster, 500) if err?
          #todo change IP
          @master = found
          @downCount = 0
      else
        console.log('trying to find a master')
        setTimeout(this.electMaster, 500)

  connect: (server) =>
    return if server == @master
    server.slaveOf @config.master, (err) =>
      console.log(err) if err?

  ping: (server, callback) =>
    server.ping(callback)

module.exports = ReplicaSet