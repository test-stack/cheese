_ = require 'underscore'
configUtils = require './fs/config'
csonConfig = require 'cson-config'
fs = require 'fs'
Mocha = require 'mocha'
path = require 'path'
testsUtils = require './fs/tests'
webdriver = require './webdriver/webdriver'
winston = require './logging/winston'

module.exports = (tags, args) ->
  logLevel = args.parent.verbose
  logger = winston.init logLevel, args
  configPath = configUtils.findConfig process.cwd(), logger
  projectDir = path.dirname configPath
  config = csonConfig.load(configPath, toProcess=false)?.testStack or {}
  if args.environment and config[args.environment]
    config.settings = _.extend config.settings, config[args.environment].settings

  # prepare screenshot dir
  screenDir = path.resolve projectDir, config.settings.screenDir or './screenshots'
  unless fs.existsSync screenDir
    logger.debug "Screenshot dir doesn't exists, creating: #{screenDir}"
    fs.mkdirSync screenDir

  configUtils.checkVersion config.version, args.parent['_version'], logger

  # merge defaults from config with cli options
  envOptions = {}
  if args.environment and config[args.environment]
    envOptions = config[args.environment].defaultOptions
  args = _.extend config.defaultOptions, envOptions, args

  # init mocha
  mochaOpts = {
    bail: args.bail
    timeout: args.timeout
    color: args.color
    compilers: 'coffee:coffee-script/register'
    require: 'coffee-script/register'
  }
  if args.grep
    mochaOpts.grep = args.grep
  mocha = new Mocha mochaOpts

  # search for test files
  testDir = config.settings?.testDir
  testDir = if testDir then path.resolve projectDir, testDir else projectDir
  testFiles = testsUtils.find testDir, logger
  unless testFiles.length
    logger.error 'No test files were found.'
    process.exit 1
  for file in testFiles
    mocha.addFile file

  # init webdriver client
  webdriver.init args, logger, (err, client) ->
    if err
      logger.error err
      process.exit 1

    mocha.suite.on 'pre-require', (context) ->
      context.client = client

    mocha.suite.on 'require', (loadedTest, file) ->
      if _.isFunction loadedTest
        if tags.length and not _.intersection(tags, loadedTest.tags).length
          logger.silly "Skipping #{file} because doesn't match with any tag."
          return
        logger.debug "Invoking tests in #{file}"
        suite = loadedTest()
        suite.beforeAll (done) ->
          return done() unless client and args.url
          client.url args.url, done

    # release the cracken!
    state = {
      isTakingScreenshot: false
    }
    runner = mocha.run (failures) ->
      end = (err) ->
        logger.error err if err
        logger.info "All test executed. No. of failures: #{failures}."
        process.exit failures

      if _.isObject client
        endSession = () ->
          if state.isTakingScreenshot
            logger.debug 'Webdriver client termination postponed - taking screenshot.'
            return setTimeout endSession, 500
          webdriver.endSession client, failures, args, logger, end

        return endSession()
      end()

    # handle test failure
    runner.on 'fail', (test) ->
      return unless _.isObject client
      if args.screenshots
        state.isTakingScreenshot = true
        webdriver.saveScreenshot client, screenDir, test, logger, (err) ->
          logger.error err if err
          state.isTakingScreenshot = false
      else
        return logger.debug 'Taking screenshot after fail skipped.'
