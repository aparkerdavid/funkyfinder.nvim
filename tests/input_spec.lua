local input = require 'input'
describe('Test example', function()
  it('splits provided input string on unescaped spaces', function()
    local input_str = 'hello world'
    assert.are.same(
      input.parse(input_str),
      { 'hello', 'world' }
    )
  end)
end)
