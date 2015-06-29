class TestError extends Error
  constructor: (@message) ->
    @name = "TestError"
    Error.captureStackTrace @, TestError

module.exports = {
  TestError
}