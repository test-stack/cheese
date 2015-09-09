# Test stack Harness
> Harness is solutions for powerfull writing and running E2E tests based on [WebdriverIO](http://webdriver.io/) and [Mochajs](http://mochajs.org/). View full [test stack](https://github.com/test-stack)

## Why use Harness
Harness allowed it easy to write smart, powerful and maintainable tests based on Selenium. Maintainability of the test is increased by using [CoffeeScript](http://coffeescript.org/).

[![Join the chat at https://gitter.im/test-stack/harness](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/test-stack/harness)

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

#### PageObjects
includes passage definition part of the website or activities on website. Defined procedure or activity is small and unique. Never describe multiple processes or activities.

For example, we want write of test for buy book on Amazon. Our test will be start at home page of Amazon `http://www.amazon.com/`. We see several things, search input, try today array, related items, recommendations for you, etc. We focus on search input, because our test, this element will use to search. Ability search is action on the website and this is pageObject.
![Amazon search input](https://raw.githubusercontent.com/test-stack/harness/1fd963d3acbd4faf2e81229ac27f0aaa023f8014/docs/AmazonSearchInput.png)

**Create first page object called Open amazon website**
Our first page object will be can write name of book to input search and clicks on button with magnifier icon. This page object you can use, if the last test step is at home page. Page object don't include an expectation only verification unchanging state, for example title of search page.

Let's a write `./pageObjects/amazon.coffee`
```javascript
module.exports = (client, depend) ->
  {TestError} = depend.errors
  {expect} = require 'chai'

  {

    open: ->

      url = "http://www.amazon.com"
      homePageTitle = "Amazon.com: Online Shopping for Electronics, Apparel, Computers, Books, DVDs & more"

      describe "Open Amazon website", ->

        it "Given open home page #{url}", (done) ->
          client.url url, done

        it "When wait for document ready state", (done) ->
          client.waitForDocumentReadyState client, done

        it "Then title of home page is #{homePageTitle}", (done) ->
          client.getTitle().then (title) ->
            try
              expect(title).to.equal homePageTitle
            catch e
              return done new TestError e

            done()
  }
```
First load the dependency, TestError for describe of error and chaijs for expected value. [ChaiJS](http://chaijs.com/api/bdd/) is cool BDD / TDD assertion library. Then we defined `amazon.url` and `homePageTitle`. This page object contains describe of way, how open home page of Amazon. This describe is in `open` method. The `describe` and `it` methods is hooks of [Mochajs](http://mochajs.org/). To Harness means `describe` describe, what method `open` will be doing. Method `it` is test step and for Harness it's how will be doing. Test step `And wait for document ready state` is loaded from [test-stack-helpers](https://github.com/test-stack/helpers).

**Create second page object called Search title by type**
Our second page object will be write name of book to input search, select *Books* from select and clicks on button with magnifier icon. This page object you can use, if the last test step is at home page. Page object don't include an expectation only verification unchanging state, for example title of search page.

Let's add next page object `./pageObjects/amazon.coffee`
```javascript
    search: (typeSearch, title) ->

      AVAILABLE_TYPES_OF_SEARCH = [
        'Books'
      ]

      expectedTitle = "Amazon.com: #{title}: #{typeSearch}"

      describe "Search #{typeSearch} #{title}", ->

        it "Given type of search #{typeSearch} is available", (done) ->
          return done new TestError "Type of search #{typeSearch} isn't available." if typeSearch not in AVAILABLE_TYPES_OF_SEARCH
          done()

        it "And select #{typeSearch} from type of search", (done) ->
          client.click "//select[@id='searchDropdownBox']"
          .click "//option[contains(text(), 'Books')]", done

        it "And type #{title}", (done) ->
          client.click "//input[@id='twotabsearchtextbox']"
          .keys title, done

        it "When click on button with magnifier icon", (done) ->
          client.click "div.nav-search-submit input.nav-input", done

        it "And wait for document ready state", (done) ->
          client.waitForDocumentReadyState client, done

        it "Then title of home page is #{expectedTitle}", (done) ->
          client.getTitle().then (title) ->
            try
              expect(title).to.equal expectedTitle
            catch e
              return done new TestError e

            done()
```

**Use page objects in test case**
These page objects are defined in test case

Let's create test case `./tests/amazon.coffee`
```javascript
module.exports = ->

  describe "Find Selenium WebDriver Practical Guide book", ->

    client.amazon.open()

    client.amazon.search "Books", "Selenium WebDriver Practical Guide"
```

> Declarative writing tests are clear with high maintainability.

### How to install

#### via npm Linux
```bash
# create directory
mkdir amazonTests

# entry to the directory
cd amazonTests

# Interactively create a package.json file, more information https://docs.npmjs.com/cli/init
npm init

# Download Harness
npm i test-stack-harness --save
```

#### Configuration

This file is right place for custom configuration.

./config.cson
```javascript
EXPLICIT_WAIT_MS: 10000
```

Then create directories `./tests` and `./pageObjects`

#### Capabilities

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
./node_modules/test-stack-harness/node_modules/.bin/coffee ./node_modules/test-stack-harness/bin/harness booksTag -c chrome -t 10000
```

#### Available commands
```bash
Find and run test case via single tag
  $ ./node_modules/test-stack-harness/bin/harness someTag

Find and run test cases via tags
  $ ./node_modules/test-stack-harness/bin/harness 'basket&release3'

Find and run test case with custom capabilities
  $ ./node_modules/test-stack-harness/bin/harness someTag -c chrome


Usage: harness <someTag> [options]

Options:

  -h, --help                       output usage information
  -V, --version                    output the version number
  -c, --capabilities <capability>  for example 'chrome' - chrome is default value
  -b, --bail                       bail after first test failure (Mochajs)
  -t, --timeout <ms>               set test-case timeout in milliseconds [5000] (Mochajs)
  -R, --reporter <name>            set type of reporter (Mochajs) default is 'spec', or you can use reporter 'elastic'
```
