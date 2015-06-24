capabilities = require './global'
capabilities.desiredCapabilities['browserName'] = 'chrome'
capabilities.desiredCapabilities['chromeOptions'] =
  args: ['start-maximized', 'window-size=1280,800']
capabilities['host'] = '192.168.59.105'

module.exports = capabilities