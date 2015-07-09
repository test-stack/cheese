{exec} = require 'child_process'
fs = require 'fs'
async = require 'async'

async.waterfall [
  (cb) ->
    testPath = "#{process.env.PWD}#{process.env.TEST}.coffee"
    fs.exists testPath, (exists) ->
      return cb "Test '#{process.env.TEST_CASE}' not found." if exists is no
      cb null

  (cb) ->
    mochaOpts = " --opts #{__dirname}/mocha.opts"
    mochaString = """
    #{__dirname}/node_modules/.bin/mocha #{__dirname}/tests/blank.coffee \
    #{mochaOpts}
    """
    exec mochaString, (error, stdout, stderr) ->
      console.error error if error
      cb null, stdout if stdout

  ], (e, results) ->
    console.error e if e
    console.log results if results