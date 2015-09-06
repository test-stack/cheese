fs = require 'fs'
async = require 'async'
Mocha = require 'mocha'
reporter = require './node_modules/test-stack-reporter'
path = require 'path'

module.exports = (args) ->

  testPath = "#{path.normalize __dirname + '/../../tests/'}#{args.testCase}.test.coffee"
  dependencies = require('test-stack-harness').setup args

  dependencies.client.init (err) ->
    dependencies.client.session (sessionErr, sessionRes) ->

      mocha = new Mocha
        ui: "bdd"
        reporter: if args.reporter is 'elastic' then reporter.reporter else args.reporter
        compilers: "coffee:coffee-script/register"
        require: "coffee-script/register"
        timeout: args.timeout

      mocha.addFile testPath

      mocha.suite.on 'pre-require', (context) ->
        context.client = dependencies.client
        if args.reporter is 'elastic'
          reporter.send
            harness: 'testStart'
            sessionId: sessionRes.sessionId

      mocha.suite.on 'require', (loadedTest, file) ->
        suite = loadedTest()
        suite.beforeAll (done) ->
          return done()

      mocha.run (failures) ->
        dependencies.exit dependencies.client, ->
          process.on 'exit', ->
            process.exit failures
