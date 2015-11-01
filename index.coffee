webdriverio = require 'webdriverio'
fs = require 'fs'
path = require 'path'
{helpers} = require 'test-stack-helpers'

dependencies =
  exit: (client, cb) -> client.end -> cb()
  explicitWaitMs: process.env.EXPLICIT_WAIT_MS
  errors: require './libs/errors'
{TestStackError} = dependencies.errors

loadCapabilities = (capabilities) ->

  global = require './capabilities/global'

  originPathToCapabilities = process.env.WORKSPACE + "node_modules/test-stack-harness/capabilities/#{capabilities}.coffee"
  return require originPathToCapabilities if fs.existsSync originPathToCapabilities

  customPathToCapabilities = process.env.WORKSPACE + "capabilities/#{capabilities}.coffee"
  return require(customPathToCapabilities)(global) if fs.existsSync customPathToCapabilities

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

  pageObjectsPath = process.env.WORKSPACE + 'pageObjects/'
  if fs.existsSync pageObjectsPath
    for po in fs.readdirSync pageObjectsPath
      client[path.basename po, '.coffee'] = require(pageObjectsPath+'/'+path.basename(po, '.coffee'))()


  dependencies.client = client

  return dependencies

module.exports = {
  setup
}
