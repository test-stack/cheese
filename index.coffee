webdriverio = require 'webdriverio'
fs = require 'fs'
path = require 'path'
{helpers} = require 'test-stack-helpers'

dependencies =
  exit: (client, done) -> client.end done
  explicitWaitMs: process.env.EXPLICIT_WAIT_MS
  errors: require './libs/errors'
{TestStackError} = dependencies.errors

loadCapabilities = (capability) ->
  originPathToCapabilities = "#{__dirname}/capabilities/#{capability}.coffee"
  return require originPathToCapabilities if fs.existsSync originPathToCapabilities
  customPathToCapabilities = "#{process.env.PWD}/#{process.env.CAPABILITIES_PATH}/#{capability}.coffee"
  return require customPathToCapabilities if fs.existsSync customPathToCapabilities

  throw new TestStackError """
  Capability #{capability} not found in paths 
  #{originPathToCapabilities} or #{customPathToCapabilities}
  """

setup = (capability) ->
  capabilities = loadCapabilities process.env.CAPABILITIES
  capabilities['waitforTimeout'] = dependencies.explicitWaitMs

  client = webdriverio.remote capabilities
  client.on 'error', (e) ->
    client.options.waitforTimeout = 500

  for helper in helpers
    for nameOfHelper, fn of helper
      client[nameOfHelper] = fn

  pageObjects = process.env.PWD + process.env.PAGE_OBJECTS_PATH
  if fs.existsSync pageObjects
    for po in fs.readdirSync pageObjects
      client[path.basename po, '.coffee'] = require(pageObjects+'/'+path.basename(po, '.coffee')) client, dependencies


  dependencies.client = client

  return dependencies

module.exports = {
  setup
}