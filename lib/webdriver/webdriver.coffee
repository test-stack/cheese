errors = require './../errors'
fs = require 'fs'
webdriverio = require 'webdriverio'

exports.init = (args, logger, cb) ->
  unless args.capability
    logger.debug "Capability option wasn't specified, instance of webdriver won't be created."
    return cb()

  capabilityModule = "#{__dirname}/../../capabilities/#{args.capability}"
  unless fs.existsSync "#{capabilityModule}.coffee"
    logger.error "File #{capabilityModule}.coffee doesn't exist."
    return cb new errors.WebdriverError "Unknown capability: #{args.capability}"

  logger.debug "Initializing webdriver client with #{args.capability} capability."
  client = webdriverio.remote(require(capabilityModule)).init (err) ->
    if err
      logger.error 'Unable to instantiate webdriver client'
      return cb err
    unless args.url
      return cb null, client
    client.url args.url, (err) ->
      cb err, client

exports.saveScreenshot = (client, screenDir, test, logger) ->
  logger.debug 'Taking screenshot after fail.'
  client.screenshot (err, res) ->
    if err
      return logger.error 'Error while trying to take screenshot.'
    encodedScreen = new Buffer res.value, 'base64'
    testTitle = test.title.substr(0,30).replace /\s/g, '_'
    screenFilename = "#{screenDir}/#{Date.now()}_#{testTitle}.png"
    fs.writeFile screenFilename, encodedScreen, (err) ->
      if err
        return logger.error "Error while saving screenshot to #{screenFilename}"
      logger.info "Screenshot saved: #{screenFilename}"