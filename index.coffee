#!/usr/bin/env coffee
cli = require 'commander'
fs = require 'fs'

test = require './lib/test'

VERSION = JSON.parse(fs.readFileSync(__dirname + '/package.json', 'utf8')).version

cli
  .version VERSION
  .option '-v, --verbose <level>', 'set verbosity level of log [warn]', 'warn'

cli
  .command 'test [tags...]'
  .description 'Executes test with matching tags.'
  .option '-b, --bail', 'bail after first test failure'
  .option '-c, --capability <capability>', 'capability that should be used for test execution'
  .option '-e, --environment <environment>', 'environment in which run tests'
  .option '-g, --grep <pattern>', 'run only tests matching pattern'
  .option '-t, --timeout <timeout>', 'mocha timeout in ms', 60000
  .option '--url <url>', 'url that should be loaded at the start of test'
  .option '--no-color', 'do not use colors in output'
  .option '--no-exit', "don't close browser window after failure"
  .option '--no-screenshots', "don't take screenshots after fail"
  .action test

cli
  .command 'init'
  .description 'Initialize current directory for running tests.'

cli.parse process.argv

unless cli.args.length
  cli.help()
