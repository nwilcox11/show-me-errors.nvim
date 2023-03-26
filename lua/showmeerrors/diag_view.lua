local Processer = require("showmeerrors.processer")

local View = {}
View.__index = View

View.buf = nil
View.win = nil
View.owning_buf = nil
View.processer = nil

local mapped_actions = {
  select = "y",
}

function View:new()
  vim.cmd("below new")
  vim.cmd("wincmd J")

  local this = {
    win = vim.api.nvim_get_current_win(),
    buf = vim.api.nvim_get_current_buf(),
  }

  setmetatable(this, self)
  return this
end

function View:create_view()
  local view = self:new()
  view.processer = Processer:new()
  view:setup()
  return view
end

function View:setup()
  self:un_lock()
  vim.api.nvim_buf_set_name(self.buf, 'Errors')

  -- Set buffer options
  vim.cmd("setlocal nonu")
  vim.cmd("setlocal nornu")
  vim.api.nvim_buf_set_option(self.buf, 'bufhidden', "wipe")
  vim.api.nvim_buf_set_option(self.buf, 'buftype', "nofile")
  vim.api.nvim_buf_set_option(self.buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(self.buf, 'buflisted', false)

  -- Set window options
  vim.api.nvim_win_set_option(self.win, 'winfixheight', true)
  vim.api.nvim_win_set_option(self.win, 'winfixwidth', true)
  vim.api.nvim_win_set_height(self.win, 10)

  for action, key in pairs(mapped_actions) do
    vim.api.nvim_buf_set_keymap(self.buf, "n", key, [[<cmd>lua require("showmeerrors").doaction("]] .. action .. [[")<cr>]],
      { silent = true, nowait = true })
  end

  self:lock()
  self.processer:process_diagnostics()
end

function View:render()
  local lines = {}
  for i, renderable in pairs(self.processer.items) do
    lines[i] = renderable.message
  end

  self:un_lock()
  vim.api.nvim_buf_set_lines(self.buf, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(self.win, { 1, 0 })
  self:lock()
end

function View:get_current_diagnostic()
  local row = self:get_current_row()
  return self.processer.items[row]
end

---@private
function View:get_current_row()
  return vim.api.nvim_win_get_cursor(self.win)[1]
end

function View:close()
  if vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_delete(self.buf, {})
  end
end

function View:is_open()
  return self.buf ~= nil and vim.api.nvim_buf_is_valid(self.buf) and vim.api.nvim_buf_is_valid(self.buf)
end

function View:un_lock()
  vim.api.nvim_buf_set_option(self.buf, 'readonly', false)
  vim.api.nvim_buf_set_option(self.buf, 'modifiable', true)
end

function View:lock()
  vim.api.nvim_buf_set_option(self.buf, 'readonly', true)
  vim.api.nvim_buf_set_option(self.buf, 'modifiable', false)
end

return View
