errors = require '../errors'
fs = require 'fs'
path = require 'path'
semver = require 'semver'

CONFIG_NAME = 'config.cson'

exports.findConfig = (cwd, logger) ->
  logger.debug "Searching for #{CONFIG_NAME} in #{cwd}"
  try
    files = fs.readdirSync cwd
  catch e
    throw new errors.FileSystemError e.message
  if CONFIG_NAME in files
    configPath = path.join cwd, CONFIG_NAME
    logger.debug "Config was found: #{configPath}"
    return configPath
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

exports.checkVersion = (reqVersion, actual, logger) ->
  if reqVersion
    validVersion = semver.satisfies actual, reqVersion
    if validVersion
      logger.debug "Version used: #{actual}, required: #{reqVersion}."
      return true
    else
      logger.warn "Your version doesn't satisfy requirements! Your: #{actual}, required: #{reqVersion}."
  else
    logger.warn "Required version should be explicitly stated in config."
  return false
