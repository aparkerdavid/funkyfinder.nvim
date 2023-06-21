local Menu = require('nui.menu')
local Input = require('nui.input')
local Layout = require('nui.layout')

local ui = {}

function ui.picker(opts)
  local on_submit = opts.on_submit or function(_) end
  local on_change = opts.on_change or function(_) end
  local on_filter = opts.on_filter or function(_) return {} end
  local on_close = opts.on_close or function() end
  local candidates = opts.candidates or {}

  local menu = Menu({
    position = 0,
    size = { width = '100%', },
  }, {
    focusable = false,
    lines = candidates,
    max_width = 20,
    max_height = 10,
    on_change = on_change,
    on_close = on_close,
  })

  local input = Input({
    position = 0,
    size = { width = '100%', },
  }, {
    on_close = on_close,
    on_change = function(prompt_str)
      vim.schedule(function()
        menu.tree:set_nodes({})

        local results = on_filter(prompt_str)
        for _, result in ipairs(results) do
          menu.tree:add_node(result)
        end

        menu.tree:render()
        local focused_item = menu.tree:get_node()
        if focused_item then
          on_change(focused_item)
        end
      end)
    end
  })

  local layout = Layout({
      position = "100%",
      size = {
        width = "100%",
        height = 11,
      },
    },
    {
      Layout.Box({
        Layout.Box(menu, { size = { height = 10 } }),
        Layout.Box(input, { size = { height = 1 } }),
      }, { dir = "col", size = "100%" })
    })

  function layout:mount()
    self.previous_win_id = vim.api.nvim_get_current_win()
    Layout.mount(self)
    vim.api.nvim_set_current_win(input.winid)
  end

  function layout:unmount()
    vim.api.nvim_set_current_win(self.previous_win_id)
    Layout.unmount(self)
  end

  local function submit()
    local item = menu.tree:get_node()
    on_submit(item)
    layout:unmount()
  end

  input:map("n", "<Esc>", function()
    on_close()
    layout:unmount()
  end, { noremap = true })

  input:map("n", "k", function()
    menu.menu_props.on_focus_prev()
  end, { noremap = true })

  input:map("n", "j", function()
    menu.menu_props.on_focus_next()
  end, { noremap = true })

  input:map('i', '<CR>', submit, { noremap = true })
  input:map('n', '<CR>', submit, { noremap = true })
  menu:map('n', '<CR>', submit, { noremap = true })

  return layout
end

return ui
