webdriverio = require 'webdriverio'
fs = require 'fs'
path = require 'path'

ABSOLUTE_PATH = __dirname

CAPABILITY_PATH = "#{ABSOLUTE_PATH}/capabilities"

findCapabalityFile = (typeOfCapability, cb) ->
  fs.readdir CAPABILITY_PATH, (err, files) ->
    return cb err if err
    capabilities = []
    for file in files
      return cb null, require(file) if typeOfCapability is path.basename file, '.coffee'
    cb 'Capability not found'


setup = ->
  findCapabalityFile 'chrome', (capabilityFile) ->
    console.log capabilityFile
    capabilities = require CAPABILITY_PATH+capabilityFile
    capabilities['waitforTimeout'] = dependency.EXPLICIT_WAIT_MS

    client = webdriverio.remote capabilities

module.exports = {
  setup
}