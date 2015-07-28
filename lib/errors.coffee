class TestStackError extends Error
  constructor: (@message) ->
    Error.captureStackTrace @, TestStackError

class ConfigError extends TestStackError
class FileSystemError extends TestStackError

module.exports = {
  ConfigError
  FileSystemError
}
