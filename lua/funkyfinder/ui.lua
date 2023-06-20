local Menu = require('nui.menu')
local Input = require('nui.input')
local Layout = require('nui.layout')

local ui = {}

function ui.picker(opts)
  local on_submit = opts.on_submit or function(_) end
  local on_change = opts.on_change or function(_) end
  local on_close = opts.on_close or function() end

  local menu = Menu({
    position = 0,
    size = { width = '100%', },
  }, {
    focusable = false,
    lines = opts.candidates,
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

        local results = opts.on_filter(prompt_str)
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
        Layout.Box(input, { size = { height = 1 } }),
        Layout.Box(menu, { size = { height = 10 } }),
      }, { dir = "col", size = "100%" })
    })

  local function submit()
    local item = menu.tree:get_node()
    on_submit(item)
    layout:unmount()
  end

  input:map("n", "<Esc>", function()
    on_close()
    input:unmount()
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

  function layout:mount()
    Layout.mount(self)
    vim.api.nvim_set_current_win(input.winid)
  end

  return layout
end

return ui
