# Test stack webdriver
> This is part of test stack for writing SIT based on [WebdriverIO](http://webdriver.io/). View full [test stack](https://github.com/test-stack)

## What is Webdriver
Webdriver makes it easy to write smart, powerful and maintainable tests based on Selenium. Maintainability of the test is increased by using [CoffeeScript](http://coffeescript.org/).

[![Join the chat at https://gitter.im/rdpanek/test-stack](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/rdpanek/test-stack)

### How can such a test look

/tests/addToBasket.test.coffee
```javascript
module.exports = (client) ->

  eshop =
    url: 'http://my.eshop.com'
    product: 'Nikond D3200'

  describe "Context of test", ->

    client.loginPage.login eshop.url

    client.eshop.findProduct eshop.product

    client.basket.add eshop.product
```

### PageObjects

These methods are [PageObjects](http://martinfowler.com/bliki/PageObject.html)
```javascript
.loginPage.login(), eshop.findProduct() and eshop.addToBasket()
```

/po/loginPage/loginPage.coffee
```javascript
module.exports = (client, depend) ->
  {TestError} = depend.errors

  {
    login: (url) ->

      describe "Login page", ->

        it "open #{url}", (done) ->
          client.url url, done

        it "wait for document ready state", (done) ->
          client.waitForDocumentReadyState client, done

  }

```

/po/eshop/elementsMap.coffee
```javascript
searchInput = 'input.search'

module.exports = {
  searchInput
}
```

/po/eshop/eshop.coffee
```javascript
eshop = require './elementsMap'
module.exports = (client, depend) ->
  {TestError} = depend.errors

  {
    findProduct: (product) ->

      describe "Find #{product}", ->

        it "Type #{product} to search input", (done) ->
          client.addValue eshop.searchInput, product, done

        ...

  }

```

/po/basket/elementsMap.coffee
```javascript
addButton = 'input.addToBasket'

module.exports = {
  addButton
}
```

/po/basket/basket.coffee
```javascript
basket = require './elementsMap'
module.exports = (client, depend) ->

  {
    add: (product) ->

      describe "Add #{product} to basket", ->

        it "Click on add to basket Button", (done) ->
          client.click basket.addButton, done

        ...

  }

```

> Declarative writing tests are clear with high maintainability.

### Configuration

This file is right place for custom configuration.

config.cson
```javascript
CAPABILITIES_PATH: '/capabilities'
PAGE_OBJECTS_PATH: '/page-objects'
TESTS_PATH: '/tests'
EXPLICIT_WAIT_MS: 10000
```

### Capabilities

They allow you to set the browser type and its properties.

/capabilities/dockerChrome.coffee

```javascript
path = require 'path'

capabilities = require path.resolve __dirname + '../../node_modules/test-stack-webdriver/capabilities/global'
capabilities.desiredCapabilities['browserName'] = 'chrome'
capabilities.desiredCapabilities['chromeOptions'] =
  args: [
    'start-maximized'
    'window-size=1280,800'
  ]
capabilities['host'] = '192.168.59.105'


module.exports = capabilities
```

### Run
```
./node_modules/test-stack-harness/node_modules/.bin/coffee ./node_modules/test-stack-harness/bin/harness addToBasket -c dockerChrome
```
