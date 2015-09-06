webdriverio = require 'webdriverio'
fs = require 'fs'
path = require 'path'
{helpers} = require 'test-stack-helpers'

dependencies =
  exit: (client, cb) -> client.end().then cb
  explicitWaitMs: process.env.EXPLICIT_WAIT_MS
  errors: require './libs/errors'
{TestStackError} = dependencies.errors

loadCapabilities = (capabilities) ->

  originPathToCapabilities = "#{__dirname}/capabilities/#{capabilities}.coffee"
  return require originPathToCapabilities if fs.existsSync originPathToCapabilities

  customPathToCapabilities = "#{path.normalize __dirname + '/../../capabilities/'}#{capabilities}.coffee"
  return require customPathToCapabilities if fs.existsSync customPathToCapabilities

  return throw new TestStackError """
  Capability #{capabilities} not found in paths
  #{originPathToCapabilities} or #{customPathToCapabilities}
  """

setup = (args) ->
  capabilities = loadCapabilities args.capabilities
  capabilities['waitforTimeout'] = dependencies.explicitWaitMs

  client = webdriverio.remote capabilities
  client.on 'error', (e) ->
    client.options.waitforTimeout = 500

  for helper in helpers
    for nameOfHelper, fn of helper
      client[nameOfHelper] = fn

  pageObjectsPath = "#{path.normalize __dirname + '/../../pageObjects/'}"
  if fs.existsSync pageObjectsPath
    for po in fs.readdirSync pageObjectsPath
      client[path.basename po, '.coffee'] = require(pageObjectsPath+'/'+path.basename(po, '.coffee')) client, dependencies


  dependencies.client = client

  return dependencies

module.exports = {
  setup
}
