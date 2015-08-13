# Test stack - Harness
> This is part of test stack for writing SIT based on [WebdriverIO](http://webdriver.io/). View full [test stack](https://github.com/test-stack)

## What is Harness
Harness makes it easy to write smart, powerful and maintainable tests based on Selenium 
using Mocha framework and page object design pattern.

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

### Getting started

1) Install this project via `npm install` as dependency of your project
2) Create file `config.cson` in root of your project
3) Optionally set your custom settings in `config.cson`:

```
harness:
  settings:
    screenDir: './screens' # screenshots will be saved to screens subdirectory
```

4) Create directory named `test` and there place file with `*.test.coffee` or `*.test.js` extension
5) Write your test and place it into exported function as it's described above:

```
module.exports = () ->
  describe 'first test', ->
    it 'should something test'
```

6) Run your test by executing `harness`, for example `./node_modules/.bin/harness test`
7) If you want filter your tests by tags, associate appropriate list of tags with each test as follow:

```
module.exports = () ->
  describe 'first test', ->
    it 'should something test'
  ...
  
module.exports.tags = [
  'foo'
  'bar'
]
```

8) To run test that match provided tags, run: `./node_modules/.bin/harness test foo baz`
  - only tests that contain tag foo or bar will be executed
9) Use webdriver.io client, by specifying capability option: `./node_modules/.bin/harness test -c chrome`
  - then you can use global variable `client` to call methods of webdriver.io:
  
```
  it 'wait for load', (done) ->
    client.waitForExist 'selector', done
```
  - **HINT** with `--url` option you don't need to specify which url to load before first step, provided url
  will be automatically loaded before test

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


### Capabilities

They allow you to set the browser type and its properties.

/capabilities/docker.coffee

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

More information in the coming days

### TODO

- Support for addons
- Add injecting of page objects
- Prepare report from test results
