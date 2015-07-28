winston = require 'winston'

exports.init = (logLevel, args) ->
  logger = new winston.Logger {
    transports: [
      new winston.transports.Console {
        level: logLevel
        colorize: args.color
        handleExceptions: true
      }
    ]
  }
  logger.cli()
  return logger
