cli = require 'commander'
fs = require 'fs'

test = require './lib/test'

VERSION = JSON.parse(fs.readFileSync(__dirname + '/package.json', 'utf8')).version

cli
  .version VERSION
  .option '-v, --verbose <level>', 'set verbosity level of log [warning]', 'warn'

cli
  .command 'test [tags...]'
  .description 'Executes test with matching tags.'
  .option '-b, --bail', 'bail after first test failure'
  .option '-c, --capability <capability>', 'capability that should be used for test execution'
  .option '-e, --environment', 'environment in which run tests'
  .option '-g, --grep <pattern>', 'run only tests matching pattern'
  .option '--url', 'url that should be loaded at the start of test'
  .option '--no-color', 'do not use colors in output'
  .option '--no-exit', "don't close browser window after failure"
  .action (tags) -> test cli, tags

cli
  .command 'init'
  .description 'Initialize current directory for running tests.'

cli.parse process.argv

unless cli.args.length
  cli.help()
