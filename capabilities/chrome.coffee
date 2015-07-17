capabilities = require './global'
capabilities.desiredCapabilities['browserName'] = 'chrome'
capabilities.desiredCapabilities['chromeOptions'] =
  args: [
  	'start-maximized'
  	'window-size=1280,800'
  ]

module.exports = capabilities
