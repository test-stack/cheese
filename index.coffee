webdriverio = require 'webdriverio'
fs = require 'fs'
path = require 'path'
{helpers} = require 'test-stack-helpers'

dependencies =
  exit: (client, cb) -> client.end -> cb()
  explicitWaitMs: process.env.EXPLICIT_WAIT_MS
  errors: require './libs/errors'
{TestStackError} = dependencies.errors

loadCapabilities = (capabilities) ->

  global = require './capabilities/global'

  originPathToCapabilities = process.env.WORKSPACE + "node_modules/test-stack-harness/capabilities/#{capabilities}.coffee"
  return require originPathToCapabilities if fs.existsSync originPathToCapabilities

  customPathToCapabilities = process.env.WORKSPACE + "capabilities/#{capabilities}.coffee"
  return require(customPathToCapabilities)(global) if fs.existsSync customPathToCapabilities

  return throw new TestStackError """
  Capability #{capabilities} not found in paths
  #{originPathToCapabilities} or #{customPathToCapabilities}
  """

dirPoTree = (pageObjectsPath, parent, cb) ->
  stats = fs.lstatSync pageObjectsPath
  poTree =
    path: pageObjectsPath
    name: path.basename pageObjectsPath
    parent: parent

  if stats.isDirectory()
    poTree.type = 'folder'
    fs.readdirSync(pageObjectsPath).map (child) ->
      dirPoTree pageObjectsPath + '/' + child, poTree.name, (po) ->
        cb po

  else
    poTree.type = "file";

  cb poTree

inicializePo = ->

  pageObjectsPath = process.env.WORKSPACE + 'pageObjects'

  if fs.existsSync pageObjectsPath

    pageObjects = {}
    dirPoTree pageObjectsPath, null, (po) ->

      pageObjects[po.parent] = {} if pageObjects[po.parent] is undefined

      if po.type is 'file' and po.parent?
        fileWithPo = path.basename po.name,'.coffee'
        pageObjects[po.parent][fileWithPo] = require po.path

      if po.type is 'folder' and po.parent?
        pageObjects[po.parent][po.name] = pageObjects[po.name]
        delete pageObjects[po.name]

    pageObjects




setup = (args) ->
  capabilities = loadCapabilities args.capabilities
  capabilities['waitforTimeout'] = dependencies.explicitWaitMs

  client = webdriverio.remote capabilities
  client.on 'error', (e) ->
    client.options.waitforTimeout = 500

  for helper in helpers
    for nameOfHelper, fn of helper
      client[nameOfHelper] = fn

  dependencies.client = client

  dependencies

module.exports = {
  setup: setup
  inicializePo: inicializePo
}
