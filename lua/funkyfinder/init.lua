local Menu = require('nui.menu')
local ui = require 'funkyfinder.ui'

local selected_line_ns = vim.api.nvim_create_namespace('funkyfinder_selected_line')

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

function funkyfinder.search_buffer()
  local bufnr = vim.fn.bufnr()
  local candidates = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for idx, line in pairs(candidates) do
    candidates[idx] = Menu.item(line, { id = idx })
  end

  ui.picker({
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
