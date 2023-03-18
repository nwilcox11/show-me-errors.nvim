-- TODO:

-- FEAT:
-- * Can we figure out how to get all diags from the root of the project?
-- * Refresh diags if changes occur and error window is open.
-- * Some type of severity sorting

-- CHORE:
-- * Tests?
-- * Refactor
-- * Some color

local utils = require("showmeerrors.utils")

local diagnostic_type = {
  [1] = "Error",
  [2] = "Warn",
  [3] = "Info",
  [4] = "Hint",
}

local mapped_actions = {
  select = "y",
}

local ShowErrors = {}
local Diag_view = {}
Diag_view.__index = Diag_view

local view

function Diag_view:new()
  local this = {
    win = vim.api.nvim_get_current_win(),
    buf = vim.api.nvim_get_current_buf(),
    diags = {}
  }
  setmetatable(this, self)
  return this
end

function Diag_view:close()
  if vim.api.nvim_buf_is_valid(self.buf) then
    vim.api.nvim_buf_delete(self.buf, {})
  end
end

ShowErrors.set_up = function(buf)
  for action, key in pairs(mapped_actions) do
    vim.api.nvim_buf_set_keymap(buf, "n", key, [[<cmd>lua require("showmeerrors").doaction("]] .. action .. [[")<cr>]],
      { silent = true, nowait = true })
  end
end

ShowErrors.is_view_open = function ()
  return view and view:is_open() or false
end

function Diag_view:is_open()
  return self.buf ~= nil and vim.api.nvim_buf_is_valid(self.buf) and vim.api.nvim_buf_is_valid(self.buf)
end

ShowErrors.toggle = function()
  if ShowErrors.is_view_open() then
    ShowErrors.close()
  else
    ShowErrors.open()
  end
end

ShowErrors.doaction = function(action_kind)
  if action_kind == 'select' then
    local row = vim.api.nvim_win_get_cursor(view.win)[1]
    local current_diag = view.diags[row]

    if current_diag ~= nil and current_diag.is_file == false then
      local prev_win = vim.fn.win_getid(vim.fn.winnr('#'))

      if not vim.bo[current_diag.buf].buflisted then
        vim.bo[current_diag.buf].buflisted = true
      end

      if not vim.api.nvim_buf_is_loaded(current_diag.buf) then
        vim.fn.bufload(current_diag.buf)
      end

      vim.api.nvim_set_current_win(prev_win)
      vim.api.nvim_set_current_buf(current_diag.buf)
      vim.api.nvim_win_set_cursor(prev_win, current_diag.loc)
    end
  end
end

ShowErrors.open = function()
  -- open new buffer
  vim.cmd("below new")
  vim.cmd("wincmd J")

  view = Diag_view:new()
  P(view)

  -- Group diags by filename
  local diags = vim.diagnostic.get()
  local processed_diags = {}

  -- TODO: Refactor
  for _, value in ipairs(diags) do
    local filename = vim.api.nvim_buf_get_name(value.bufnr)
    if processed_diags[filename] then
      table.insert(processed_diags[filename],
        {
          buf = value.bufnr,
          file_name = filename,
          loc = { value.lnum + 1, value.col },
          diagnostic_line =
          "    |" ..
              (value.lnum + 1) ..
              " " ..
              diagnostic_type[value.severity] ..
              "|" .. " " .. value.message .. " " .. "[" .. value.source .. " " .. value.code .. "]"

        })
    else
      processed_diags[filename] = {}
      table.insert(processed_diags[filename],
        {
          buf = value.bufnr,
          file_name = filename,
          loc = { value.lnum + 1, value.col },
          diagnostic_line =
          "    |" ..
              (value.lnum + 1) ..
              " " ..
              diagnostic_type[value.severity] ..
              "|" .. " " .. value.message .. " " .. "[" .. value.source .. " " .. value.code .. "]"

        })
    end
  end

  -- unlock buffer
  vim.api.nvim_buf_set_option(view.buf, 'readonly', false)
  vim.api.nvim_buf_set_option(view.buf, 'modifiable', true)

  vim.api.nvim_buf_set_name(view.buf, 'showmeerrors')

  ShowErrors.set_up(view.buf)

  -- Set buffer options
  vim.cmd("setlocal nonu")
  vim.cmd("setlocal nornu")
  vim.api.nvim_buf_set_option(view.buf, 'bufhidden', "wipe")
  vim.api.nvim_buf_set_option(view.buf, 'buftype', "nofile")
  vim.api.nvim_buf_set_option(view.buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(view.buf, 'buflisted', false)

  -- Set window options
  vim.api.nvim_win_set_option(view.win, 'winfixheight', true)
  vim.api.nvim_win_set_option(view.win, 'winfixwidth', true)
  vim.api.nvim_win_set_height(view.win, 10)

  -- Map diags into trackable format
  local lineNr = 1
  for filename, diagnostic in pairs(processed_diags) do
    view.diags[lineNr] = { is_file = true, filename = filename, message = filename .. " " .. utils.count(diagnostic) }
    lineNr = lineNr + 1

    for _, renderable_diagnostic in ipairs(diagnostic) do
      view.diags[lineNr] = { buf = renderable_diagnostic.buf, is_file = false, loc = renderable_diagnostic.loc,
        filename = filename,
        message = renderable_diagnostic.diagnostic_line }
      lineNr = lineNr + 1
    end
  end

  -- Map trackable diags into renderable format
  local lines = {}
  for i, renderable in pairs(view.diags) do
    lines[i] = renderable.message
  end

  -- render lines
  vim.api.nvim_buf_set_lines(view.buf, 0, -1, false, lines)

  -- Set Cursor pos
  vim.api.nvim_win_set_cursor(view.win, { 1, 0 })

  -- lock buffer
  vim.api.nvim_buf_set_option(view.buf, 'readonly', true)
  vim.api.nvim_buf_set_option(view.buf, 'modifiable', false)
end

ShowErrors.close = function ()
  view:close()
end

ShowErrors.send_to_qf_list = function()
  vim.diagnostic.setqflist()
end

ShowErrors.reset = function()
  package.loaded["showmeerrors"] = nil
  print("showmeerrors has been reset")
end

return ShowErrors
