config = require './fs/config'
winston = require './logging/winston'

module.exports = (cli, tags) ->
  logLevel = cli.verbose
  args = cli.args
  logger = winston.init logLevel, args
  configPath = config.findConfig process.cwd(), logger
