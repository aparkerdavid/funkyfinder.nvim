local Menu = require 'nui.menu'
local Path = require 'plenary.path'
local Line = require 'nui.line'
local Text = require 'nui.text'
local log = require 'logging'.log
local ui = require 'funkyfinder.ui'
local util = require 'funkyfinder.util'
local prompt = require 'funkyfinder.prompt'

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

local function is_match(idx, match)
  local idx_is_match = false
  for _, range in pairs(match) do
    if idx > range[1] and idx <= range[2] then
      idx_is_match = true
    end
  end
  return idx_is_match
end

local function orderless_search(candidates)
  return function(prompt_str)
    local results = {}
    local queries = prompt.build_queries(prompt_str)
    for _, candidate in ipairs(candidates) do
      local match = prompt.match(queries, candidate.text)
      if match then
        local line = Line(Text(''))
        for i = 1, string.len(candidate.text) do
          local char = candidate.text:sub(i, i)
          if is_match(i, match) then
            log(char)
            line:append(char, 'Search')
          else
            line:append(char)
          end
        end

        table.insert(results, Menu.item(line, { id = candidate.id }))
      end
    end
    return results
  end
end

local funkyfinder = {}

function funkyfinder.search_buffer()
  local bufnr = vim.fn.bufnr()
  local win_id = vim.api.nvim_get_current_win()
  local current_line = vim.api.nvim_win_get_cursor(win_id)[1]

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)

  local candidates = {}

  for i = current_line, #lines do
    table.insert(candidates, Menu.item(lines[i], { id = i }))
  end

  for i = 1, current_line - 1 do
    table.insert(candidates, Menu.item(lines[i], { id = i }))
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
      jump_to_line(bufnr, current_line)
      clear_highlight(bufnr)
    end,
  }):mount()
end

function funkyfinder.find_file(dir)
  local win_id = vim.api.nvim_get_current_win()
  dir = dir or vim.fn.getcwd()

  local absolute_paths = util.dir_files(dir)
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
