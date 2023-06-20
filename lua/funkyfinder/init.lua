local Menu = require('nui.menu')
local scan_dir = require('plenary.scandir').scan_dir
local Path = require('plenary.path')
local ui = require 'funkyfinder.ui'
local prompt = require('funkyfinder.prompt')

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

local function open_file(win_id, path)
  vim.api.nvim_set_current_win(win_id)
  vim.cmd('e ' .. path)
end

local function orderless_search(candidates)
  return function(prompt_str)
    local results = {}
    local queries = prompt.build_queries(prompt_str)
    for _, candidate in ipairs(candidates) do
      if prompt.match(queries, candidate.text) then
        table.insert(results, candidate)
      end
    end
    return results
  end
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
    on_filter = orderless_search(candidates),
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

function funkyfinder.find_file(dir)
  local win_id = vim.api.nvim_get_current_win()
  dir = dir or vim.fn.getcwd()

  local absolute_paths = scan_dir(dir, { respect_gitignore = true })
  local candidates = {}
  for idx, path in ipairs(absolute_paths) do
    local relative_path = Path.new(path):normalize(dir)
    candidates[idx] = Menu.item(relative_path, { id = idx })
  end

  ui.picker({
    candidates = candidates,
    on_filter = orderless_search(candidates),
    on_submit = function(item)
      local absolute_path = absolute_paths[item.id]
      open_file(win_id, absolute_path)
    end,
  }):mount()
end

return funkyfinder
