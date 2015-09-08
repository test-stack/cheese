fs = require 'fs'
async = require 'async'
Mocha = require 'mocha'
reporter = require './node_modules/test-stack-reporter'
path = require 'path'

module.exports = (args) ->

  dependencies = require('test-stack-harness').setup args

  safelyExitWebdriver = (cb) ->
    dependencies.exit dependencies.client, cb

  process.on 'uncaughtException', (err) ->
    safelyExitWebdriver ->
      console.error (new Date).toUTCString() + ' uncaughtException:', err.message
      console.error err.stack
      process.exit 1

  dependencies.client.init (clientErr) ->
    dependencies.client.session (sessionclientErr, sessionRes) ->

      mocha = new Mocha
        ui: "bdd"
        reporter: if args.reporter is 'elastic' then reporter.reporter else args.reporter
        compilers: "coffee:coffee-script/register"
        require: "coffee-script/register"
        timeout: args.timeout

      require('./libs/findTestCase').find args.runBy, (testCases) ->
        mocha.addFile tc for tc in testCases if testCases.length != 0

      mocha.suite.on 'pre-require', (context) ->
        context.client = dependencies.client
        if args.reporter is 'elastic'
          reporter.send
            harness: 'testStart'
            sessionId: if !clientErr? then sessionRes.sessionId else null
            err: if clientErr? then clientErr.toString() else null

      mocha.suite.on 'require', (loadedTest, file) ->
        suite = loadedTest()
        suite.beforeAll (done) ->
          return done()

      mocha.run (failures) ->
        safelyExitWebdriver ->
          process.on 'exit', ->
            process.exit failures
