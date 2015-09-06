# Test stack Harness
> Harness is solutions for powerfull writing and running E2E tests based on [WebdriverIO](http://webdriver.io/) and [Mochajs](http://mochajs.org/). View full [test stack](https://github.com/test-stack)

## Why use Harness
Harness allowed it easy to write smart, powerful and maintainable tests based on Selenium. Maintainability of the test is increased by using [CoffeeScript](http://coffeescript.org/).

[![Join the chat at https://gitter.im/test-stack/harness](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/rdpanek/test-stack)

## Infrastructure of test stack
![Infrastructure of test stack](https://raw.githubusercontent.com/test-stack/harness/3e8f12705ebd5ccf5260b6ded8a51cad1e6dab7a/docs/TestStackInfrastructure.png)

### Dependencies
- [Mochajs](http://mochajs.org/) is Javascript test framework.
- [WebdriverIO](http://webdriver.io/) is Webdriver and communicating with Selenium and enables to call enhanced methods of The Wire Protocol and more custom useful methods. You can start use via `client` object in your tests.

### Test stack
- [Test stack Reporter](https://github.com/test-stack/reporter) allowed send snippets of report to [Elasticsearch](https://www.elastic.co/products/elasticsearch)
- [Rest stack Helpers](https://github.com/test-stack/helpers) extends WebdriverIO of useful methods.

### Selenium grid
[Selenium grid](https://github.com/test-stack/docker#selenium-grid) is solutions for simple and fast create Selenium grid built on [Docker](docker.com). [More informations about Selenium grid](http://www.seleniumhq.org/docs/07_selenium_grid.jsp)

### Log management
We use for log management [Elasticsearch & Kibana](https://github.com/test-stack/docker#elasticsearch--kibana) built on [Docker](docker.com)

## What types of test supports
Actually we support functional E2E and integration tests and non-functional performance tests based on Selenium. We planning adding headless support.


### How to write a test
You can write tests way, you're used to. Or, you can use pageObjects and mappingObjects.
Every Test Case contains procedures, which called webdriver and control web browser. These procedures called page Object describes behavior of Test Case, allowed write what browser will be doing, not how. This is the main access for writing maintainable tests. These Test Cases can then be easily read and edited by anyone.

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
