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

  options = require capabilityModule

  # set defaults to smaller value than for mocha to handle timeout before mocha kills it
  options.waitforTimeout = Math.max args.timeout - 5000, 500
  options.coloredLogs = args.color
  client = webdriverio.remote(options).init (err) ->
    if err
      logger.error 'Unable to instantiate webdriver client'
      return cb err
    cb null, client

exports.saveScreenshot = (client, screenDir, test, logger, cb) ->
  logger.debug 'Taking screenshot after fail.'
  client.screenshot (err, res) ->
    if err
      logger.error 'Error while trying to take screenshot.'
      return cb err
    encodedScreen = new Buffer res.value, 'base64'
    testTitle = test.title.substr(0,30).replace /\s/g, '_'
    screenFilename = "#{screenDir}/#{Date.now()}_#{testTitle}.png"
    fs.writeFile screenFilename, encodedScreen, (err) ->
      if err
        logger.error "Error while saving screenshot to #{screenFilename}"
      logger.info "Screenshot saved: #{screenFilename}"
      cb err

exports.endSession = (client, failures, args, logger, cb) ->
  if not failures or (failures and args.exit)
    logger.debug 'Ending webdriver client session.'
    return client.end (err) ->
      if err
        logger.error 'Unable to terminate webdriver session!'
      cb err
  logger.debug "Webdriver client session termination skipped as was requested."
  cb()
