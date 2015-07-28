fs = require 'fs'
path = require 'path'
errors = require '../errors'

CONFIG_NAME = 'config.cson'

exports.findConfig = (cwd, logger) ->
  logger.debug "Searching for #{CONFIG_NAME} in #{cwd}"
  try
    files = fs.readdirSync cwd
  catch e
    throw new errors.FileSystemError e.message
  if CONFIG_NAME in files
    return path.join cwd, CONFIG_NAME
  if cwd is path.sep
    errorMsg = "File #{CONFIG_NAME} was not found."
    logger.error errorMsg
    throw new errors.ConfigError errorMsg
  dirs = cwd.split path.sep
  dirs.pop()
  dir = dirs.join path.sep
  if dirs.length is 1
    dir = path.sep
  return exports.findConfig dir, logger
