local prompt = require 'funkyfinder.prompt'
describe('Test example', function()
  it('splits provided prompt string on unescaped spaces', function()
    local cases = {
      { 'hello world',            { 'hello', 'world' } },
      { [[hello world\]],         { 'hello', [[world\]] } },
      { '  hello     world     ', { 'hello', 'world' } },
      { 'hello world again',      { 'hello', 'world', 'again' } },
      { [[hello\ world again]],   { [[hello\ world]], 'again' } },
    }

    for _, case in pairs(cases) do
      assert.are.same(prompt.parse(case[1]), case[2])
    end
  end)

  it('matches prompt strings to prompt strings', function()
    local cases = {
      { 'hello',             'hello world',       { { 0, 5 } } },
      { 'bye',               'hello world',       false },
      { 'hello world',       'hello cruel world', { { 0, 5 }, { 12, 17 } } },
      { 'hello happy',       'hello cruel world', false },
      { 'world hello cruel', 'hello cruel world', { { 12, 17 }, { 0, 5 }, { 6, 11 } } },
      { [[cruel\ world]],    'hello cruel world', { { 6, 17 } } },
      { '',                  'hello world',       {} }
    }
    for _, case in pairs(cases) do
      local queries = prompt.build_queries(case[1])
      assert.are.same(prompt.match(queries, case[2]), case[3])
    end
  end)

  it("respects the user's ignorecase setting", function()
    local cases = {
      { 'hello', 'Hello world', { { 0, 5 } } },
      { 'hello', 'heLlO World', { { 0, 5 } } },
    }

    vim.cmd('set ignorecase')

    for _, case in pairs(cases) do
      local queries = prompt.build_queries(case[1])
      assert.are.same(prompt.match(queries, case[2]), case[3])
    end

    vim.cmd('set noignorecase')

    for _, case in pairs(cases) do
      local queries = prompt.build_queries(case[1])
      assert.are.same(prompt.match(queries, case[2]), false)
    end
  end)
end)
