path = require 'path'

absolutePath = __dirname

customConfigFile = path.join absolutePath, '/../../config.coffee'

capabilitiesPath = "#{absolutePath}/capabilities"

explicitWaitMS = 50000

module.exports = {
	absolutePath
	customConfigFile
	capabilitiesPath
	explicitWaitMS
}