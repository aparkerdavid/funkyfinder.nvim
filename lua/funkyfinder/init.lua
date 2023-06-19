local Input = require('nui.input')
local Menu = require('nui.menu')
local Layout = require('nui.layout')
local prompt = require('funkyfinder.prompt')

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

local funkyfinder = {}

function funkyfinder.picker(opts)
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

function funkyfinder.search_buffer()
  local bufnr = vim.fn.bufnr()
  local candidates = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for idx, line in pairs(candidates) do
    candidates[idx] = Menu.item(line, { id = idx })
  end

  funkyfinder.picker({
    candidates = candidates,
    on_change = function(item)
      jump_to_line(bufnr, item.id)
    end,
    on_submit = function()
      clear_highlight(bufnr)
    end,
    on_close = function()
      clear_highlight(bufnr)
    end,
  }):mount()
end

return funkyfinder
