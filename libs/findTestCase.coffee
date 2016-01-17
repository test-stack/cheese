path = require 'path'
fs = require 'fs'
{TestStackError} = require './errors'

find = (runBy, cb) ->

  testsDirectory = process.env.WORKSPACE + 'tests/'

  files = fs.readdirSync testsDirectory
  testCases = []
  tagsArray = []

  for arrayOffiles, i in fs.readdirSync testsDirectory
    testCaseFile = testsDirectory+arrayOffiles

    if testCaseFile.match /(\w)+\.test\.coffee/

      {tags} = require testCaseFile
      if tags != undefined

        if runBy.match /&/
          for _runBy in runBy.split '&'
            if _runBy in tags
              testCases.push testCaseFile
              tagsArray.push _tag for _tag in tags
              break

        else
          # find by single tag strategy
          testCases.push testCaseFile if runBy in tags
          tagsArray.push _tag for _tag in tags if runBy in tags


    return cb testCases, tagsArray if i is files.length - 1

module.exports = {
  find:find
}
