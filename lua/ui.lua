local Input = require('nui.input')
local Menu = require('nui.menu')
local Layout = require('nui.layout')
local prompt = require('prompt')

local selected_line_ns = vim.api.nvim_create_namespace('funky_selected_line')

local function clear_highlight(bufnr)
  vim.api.nvim_buf_clear_namespace(bufnr, selected_line_ns, 0, -1)
end

local function jump_to_line(bufnr, line_number)
  vim.api.nvim_buf_call(bufnr, function()
    clear_highlight(bufnr)
    vim.cmd('normal ' .. line_number .. 'ggzz')
    vim.api.nvim_buf_add_highlight(bufnr, selected_line_ns, 'Visual', line_number - 1, 0, -1)
  end)
end

local layout = Layout({
    position = 0,
    size = { width = 1, height = 1, },
  },
  {
    Layout.Box(Menu({ position = 0, size = 1 }, { lines = { Menu.item("") } }), { size = 1 })
  })

local bufnr = vim.fn.bufnr()
local candidates = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
local lines = {}
for idx, line in pairs(candidates) do
  lines[idx] = Menu.item(line, { id = idx })
end


local menu = Menu({
  position = 0,
  size = { width = '100%', },
}, {
  focusable = false,
  lines = lines,
  max_width = 20,
  max_height = 10,
  on_change = function(item)
    jump_to_line(bufnr, item.id)
  end,
  on_close = function()
    clear_highlight(bufnr)
  end,
  on_submit = function()
    clear_highlight(bufnr)
  end,
})

local input = Input({
  position = 0,
  size = { width = '100%', },
}, {
  on_close = function()
    clear_highlight(bufnr)
  end,
  on_submit = function()
    clear_highlight(bufnr)
  end,
  on_change = function(prompt_str)
    vim.schedule(function()
      local queries = prompt.build_queries(prompt_str)
      menu.tree:set_nodes({})

      for idx, candidate in pairs(candidates) do
        if prompt.match(queries, candidate) then
          menu.tree:add_node(Menu.item(candidate, { id = idx }))
        end
      end

      menu.tree:render()
      local focused_item = menu.tree:get_node()
      if focused_item then
        jump_to_line(bufnr, focused_item.id)
      end
    end)
  end
})

input:map("n", "<Esc>", function()
  input:unmount()
  clear_highlight(bufnr)
end, { noremap = true })

input:map("n", "k", function()
  menu.menu_props.on_focus_prev()
end, { noremap = true })

input:map("n", "j", function()
  menu.menu_props.on_focus_next()
end, { noremap = true })

layout:update({
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

layout:mount()
vim.api.nvim_set_current_win(input.winid)
