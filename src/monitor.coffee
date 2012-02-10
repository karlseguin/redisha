replicaSet = require('./replicaSet')
async = require('async')

class Monitor
  @sets: []
  @start: (config) =>
    initializers = []
    for set, value of config.sets
      ((s, v) ->
        f = (cb) -> replicaSet.create s, v, cb
        initializers.push(f))(set, value)

    async.parallel initializers, (err, sets) ->
      if err?
        console.log(err)
        process.exit()


module.exports = Monitor.start