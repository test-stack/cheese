_ = require 'underscore'
readdir = require 'recursive-readdir-sync'

TESTFILE_PATTERN = /\.test\.(?:coffee|js)$/

exports.find = (dir, logger) ->
  logger.debug "Searching for tests in #{dir}"
  files = readdir dir
  testFiles = _.filter files, (filename) -> filename.match TESTFILE_PATTERN
  if testFiles.length > 1
    debugMsg = "#{testFiles.length} test files were found."
  else
    debugMsg = "1 test file was found: #{testFiles}"
  logger.debug debugMsg
  return testFiles
