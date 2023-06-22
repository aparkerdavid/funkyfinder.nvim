local Menu = require('nui.menu')
local Input = require('nui.input')

local ui = {}

function ui.picker(opts)
  local on_submit = opts.on_submit or function(_) end
  local on_change = opts.on_change or function(_) end
  local on_filter = opts.on_filter or function(_) return {} end
  local on_close = opts.on_close or function() end
  local candidates = opts.candidates or {}
  local picker = {}
  picker.max_height = 10

  picker.menu = Menu({
    position = '100%',
    size = { width = '100%', },
    border = {
      padding = {
        bottom = 1
      }
    }
  }, {
    focusable = false,
    lines = candidates,
    max_width = 20,
    max_height = picker.max_height - 1,
    on_change = on_change,
    on_close = on_close,
  })


  function picker.menu:set_height(height)
    self:set_size({ width = self.win_config.width, height = height })
  end

  function picker.menu:get_tree()
    return self.tree
  end

  picker.input = Input({
    position = '100%',
    size = { width = '100%', },
  }, {
    on_close = on_close,
    on_change = function(prompt_str)
      vim.schedule(function()
        local tree = picker.menu:get_tree()
        tree:set_nodes({})

        local results = on_filter(prompt_str)
        for _, result in ipairs(results) do
          tree:add_node(result)
        end

        if #results == 0 then
          picker:set_menu_height(1)
        elseif #results < picker.max_height then
          picker:set_menu_height(#results)
        else
          picker:set_menu_height(picker.max_height)
        end

        tree:render()
        if #results < picker.max_height then
          vim.api.nvim_buf_call(picker.menu.bufnr, function()
            vim.cmd('normal zb')
          end)
        end
        local focused_item = tree:get_node()
        if focused_item then
          on_change(focused_item)
        end
      end)
    end
  })

  function picker:set_menu_height(height)
    self.menu:set_height(height)
    self.menu:update_layout({ position = '100%' })
  end

  function picker:mount()
    self.previous_win_id = vim.api.nvim_get_current_win()
    self.input:mount()
    self.menu:mount()
    vim.api.nvim_set_current_win(self.input.winid)
  end

  function picker:unmount()
    vim.api.nvim_set_current_win(self.previous_win_id)
    self.input:unmount()
    self.menu:unmount()
  end

  local function submit()
    local item = picker.menu.tree:get_node()
    on_submit(item)
    picker:unmount()
  end

  picker.input:map("n", "<Esc>", function()
    on_close()
    picker:unmount()
  end, { noremap = true })

  picker.input:map("n", "k", function()
    picker.menu.menu_props.on_focus_prev()
  end, { noremap = true })

  picker.input:map("n", "j", function()
    picker.menu.menu_props.on_focus_next()
  end, { noremap = true })

  picker.input:map('i', '<CR>', submit, { noremap = true })
  picker.input:map('n', '<CR>', submit, { noremap = true })
  picker.menu:map('n', '<CR>', submit, { noremap = true })

  return picker
end

return ui
