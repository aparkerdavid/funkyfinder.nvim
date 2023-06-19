local Menu = require('nui.menu')
local Input = require('nui.input')
local Layout = require('nui.layout')
local prompt = require('funkyfinder.prompt')

local ui = {}

function ui.picker(opts)
  local menu = Menu({
    position = 0,
    size = { width = '100%', },
  }, {
    focusable = false,
    lines = opts.candidates,
    max_width = 20,
    max_height = 10,
    on_change = opts.on_change,
    on_submit = opts.on_submit,
    on_close = opts.on_close,
  })

  local input = Input({
    position = 0,
    size = { width = '100%', },
  }, {
    on_close = opts.on_close,
    on_submit = opts.on_submit,
    on_change = function(prompt_str)
      vim.schedule(function()
        local queries = prompt.build_queries(prompt_str)
        menu.tree:set_nodes({})

        for _, candidate in pairs(opts.candidates) do
          if prompt.match(queries, candidate.text) then
            menu.tree:add_node(candidate)
          end
        end

        menu.tree:render()
        local focused_item = menu.tree:get_node()
        if focused_item then
          opts.on_change(focused_item)
        end
      end)
    end
  })

  input:map("n", "<Esc>", function()
    input:unmount()
    opts.on_close()
  end, { noremap = true })

  input:map("n", "k", function()
    menu.menu_props.on_focus_prev()
  end, { noremap = true })

  input:map("n", "j", function()
    menu.menu_props.on_focus_next()
  end, { noremap = true })

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

  function layout:mount()
    Layout.mount(self)
    vim.api.nvim_set_current_win(input.winid)
  end

  return layout
end

return ui
