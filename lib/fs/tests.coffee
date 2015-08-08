_ = require 'underscore'
readdir = require 'recursive-readdir-sync'

TESTFILE_PATTERN = /\.test\.(?:coffee|js)$/

exports.find = (dir, logger) ->
  logger.debug "Searching for tests in #{dir}"
  files = readdir dir
  testFiles = _.filter files, (filename) -> filename.match TESTFILE_PATTERN
  if testFiles.length
    logger.debug "Number of found test files: #{testFiles.length}"
  return testFiles
