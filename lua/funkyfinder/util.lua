local Job = require 'plenary.job'
local util = {}

function util.dir_files(dir)
  local paths = {}
  Job:new(
    {
      command = 'fd',
      cwd = dir,
      on_stdout = function(_, out)
        table.insert(paths, out)
      end
    }
  ):sync()
  return paths
end

return util
