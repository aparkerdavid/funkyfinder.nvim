local Input = require('nui.input')
local Menu = require('nui.menu')

local function build_input()
  local bufnr = vim.fn.bufnr()
  return Input({
    position = 0,
    size = { width = '100%', },
  }, {
    on_change = function(value)
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd('normal ' .. value .. 'ggzz')
      end)
    end
  })
end

local popup_options = {
  relative = 'editor',
  position = "100%",
  size = { width = '100%', },
}

local function build_menu()
  local bufnr = vim.fn.bufnr()
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  for idx, line in pairs(lines) do
    lines[idx] = Menu.item(line, { id = idx })
  end

  local menu = Menu(popup_options, {
    lines = lines,
    max_width = 20,
    max_height = 10,
    keymap = {
      focus_next = { "j", "<Down>", "<Tab>" },
      focus_prev = { "k", "<Up>", "<S-Tab>" },
      close = { "<Esc>", "<C-c>" },
      submit = { "<CR>", "<Space>" },
    },
    on_change = function(item)
      vim.api.nvim_buf_call(bufnr, function()
        vim.cmd('normal ' .. item.id .. 'ggzz')
      end)
    end,
  })

  return menu
end
-- build_input():mount()
build_menu():mount()
