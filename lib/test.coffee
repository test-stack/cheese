_ = require 'underscore'
configUtils = require './fs/config'
csonConfig = require 'cson-config'
Mocha = require 'mocha'
path = require 'path'
testsUtils = require './fs/tests'
winston = require './logging/winston'

module.exports = (cli, tags) ->
  logLevel = cli.verbose
  args = cli.args
  logger = winston.init logLevel, args
  configPath = configUtils.findConfig process.cwd(), logger
  projectDir = path.dirname configPath
  config = csonConfig.load(configPath, toProcess=false)?.testStack or {}

  configUtils.checkVersion config.version, cli['_version'], logger
  args = _.extend config.defaultOptions, args

  mochaOpts = {
    bail: args.bail
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

  mocha.suite.on 'require', (loadedTest, file) ->
    if _.isFunction loadedTest
      if tags.length and not _.intersection(tags, loadedTest.tags).length
        logger.silly "Skipping #{file} because doesn't match with any tag."
        return
      logger.debug "Invoking tests in #{file}"
      loadedTest()

  runner = mocha.run (failures) ->
    logger.info "All test executed. No. of failures: #{failures}."
    process.exit failures
