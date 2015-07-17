dependencies = require('test-stack-webdriver').setup process.env.CAPABILITIES

testFile = "#{process.env.PWD}#{process.env.TEST}"

describe "Prepare Test Case", ->

  before (done) -> dependencies.client.init done

  after (done) -> dependencies.exit dependencies.client, done

  require(testFile) dependencies.client
