path = require 'path'
fs = require 'fs'
{TestStackError} = require './errors'

find = (runBy, cb) ->

  testsDirectory = "#{path.normalize __dirname + '/../../../tests/'}"

  files = fs.readdirSync testsDirectory
  testCases = []

  for arrayOffiles, i in fs.readdirSync testsDirectory
    testCaseFile = testsDirectory+arrayOffiles

    if testCaseFile.match /(\w)+\.test\.coffee/

      {tags} = require testCaseFile
      if tags != undefined

        if runBy.match /&/
          for _runBy in runBy.split '&'
            if _runBy in tags
              testCases.push testCaseFile
              break

        else
          # find by single tag strategy
          testCases.push testCaseFile if runBy in tags


    return cb testCases if i is files.length - 1

module.exports = {
  find:find
}