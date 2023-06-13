local input = require 'input'
describe('Test example', function()
  it('splits provided input string on unescaped spaces', function()
    local cases = {
      { 'hello world',            { 'hello', 'world' } },
      { [[hello world\]],         { 'hello', [[world\]] } },
      { '  hello     world     ', { 'hello', 'world' } },
      { 'hello world again',      { 'hello', 'world', 'again' } },
      { [[hello\ world again]],   { [[hello\ world]], 'again' } },
    }

    for _, case in pairs(cases) do
      assert.are.same(input.parse(case[1]), case[2])
    end
  end)

  it('matches input strings to prompt strings', function()
    local cases = {
      { 'hello',             'hello world',       { { 0, 5 } } },
      { 'bye',               'hello world',       false },
      { 'hello world',       'hello cruel world', { { 0, 5 }, { 12, 17 } } },
      { 'hello happy',       'hello cruel world', false },
      { 'world hello cruel', 'hello cruel world', { { 12, 17 }, { 0, 5 }, { 6, 11 } } },
      { [[cruel\ world]],    'hello cruel world', { { 6, 17 } } }
    }
    for _, case in pairs(cases) do
      local regexes = input.build_regexes(case[1])
      assert.are.same(input.match(regexes, case[2]), case[3])
    end
  end)
end)
