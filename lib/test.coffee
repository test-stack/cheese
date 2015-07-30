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

  screenDir = path.resolve projectDir, config.settings.screenDir or './screenshots'
  unless fs.existsSync screenDir
    logger.debug "Screenshot dir doesn't exists, creating: #{screenDir}"
    fs.mkdirSync screenDir

  configUtils.checkVersion config.version, args.parent['_version'], logger
  args = _.extend config.defaultOptions, args

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

  testDir = config.settings?.testDir
  testDir = if testDir then path.resolve projectDir, testDir else projectDir

  testFiles = testsUtils.find testDir, logger
  for file in testFiles
    mocha.addFile file

  webdriver.init args, logger, (err, client) ->
    if err
      logger.error err
      process.exit 1
    # TODO add option to init webdriver once for whole test/for each suite

    mocha.suite.on 'pre-require', (context) ->
      context.client = client

    mocha.suite.on 'require', (loadedTest, file) ->
      if _.isFunction loadedTest
        if tags.length and not _.intersection(tags, loadedTest.tags).length
          logger.silly "Skipping #{file} because doesn't match with any tag."
          return
        logger.debug "Invoking tests in #{file}"
        loadedTest()

    runner = mocha.run (failures) ->
      endTest = (err) ->
        if err
          logger.error 'Unable to terminate webdriver session!'
          logger.error err
        logger.info "All test executed. No. of failures: #{failures}."
        process.exit failures

      if _.isObject client
        if not failures or (failures and args.exit)
          logger.debug 'Ending webdriver client session.'
          return client.end endTest
        logger.debug "Webdriver client session termination skipped."
      endTest()

    runner.on 'fail', (test) ->
      return unless _.isObject client
      if args.screenshots
        webdriver.saveScreenshot client, screenDir, test, logger
      else
        return logger.debug 'Taking screenshot after fail skipped.'
