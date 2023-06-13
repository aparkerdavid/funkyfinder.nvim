local input = require 'input'
describe('Test example', function()
  it('splits provided input string on unescaped spaces', function()
    local cases = {
      ['hello world']            = { 'hello', 'world' },
      ['  hello     world     '] = { 'hello', 'world' },
      ['hello world again']      = { 'hello', 'world', 'again' },
      ['hello\\ world again']    = { 'hello\\ world', 'again' },
    }

    for str, expected in pairs(cases) do
      assert.are.same(input.parse(str), expected)
    end
  end)
end)
