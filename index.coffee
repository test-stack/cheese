webdriverio = require 'webdriverio'
fs = require 'fs'
path = require 'path'
{helpers} = require 'test-stack-helpers'

ABSOLUTE_PATH = __dirname

CAPABILITY_PATH = "#{ABSOLUTE_PATH}/capabilities"

EXPLICIT_WAIT_MS = 50000

dependencies =
  exit: (client, done) -> client.end done

pos = [
  'site'
]

findCapabalityFile = (typeOfCapability, cb) ->
  fs.readdir CAPABILITY_PATH, (err, files) ->
    return cb err if err
    capabilities = []
    for file in files
      if typeOfCapability is path.basename file, '.coffee'
        return cb(null, file)
    cb 'Capability not found'


setup = ->
  capabilities = require "#{CAPABILITY_PATH}/chrome"
  capabilities['waitforTimeout'] = EXPLICIT_WAIT_MS

  client = webdriverio.remote capabilities
  client.on 'error', (e) ->
    client.options.waitforTimeout = 500

  for helper in helpers
    for nameOfHelper, fn of helper
      client[nameOfHelper] = fn

  for po in pos
    client[po] = require(ABSOLUTE_PATH+"/../../po/#{po}") client


  dependencies.client = client

  return dependencies

module.exports = {
  setup
}