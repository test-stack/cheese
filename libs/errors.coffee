class TestError extends Error
  constructor: (@message) ->
    @name = "TestError"
    Error.captureStackTrace @, TestError

 class TestStackError extends Error
  constructor: (@message) ->
    @name = "TestStackError"
    Error.captureStackTrace @, TestStackError

module.exports = {
  TestError
  TestStackError
}
