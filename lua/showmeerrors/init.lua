local utils = require("showmeerrors.utils")

local ShowErrors = {}

local diagnostic_type = {
  [1] = "Error",
  [2] = "Warn",
  [3] = "Info",
  [4] = "Note",
}

ShowErrors.setup = function(opts)
  print("Options:", opts)
end

ShowErrors.print_diags = function()
  local diags = vim.diagnostic.get()
  P(diags)
end

ShowErrors.show_me = function()
  -- open new buffer
  vim.cmd("below new")
  vim.cmd("wincmd J")
  local diags_buf = vim.api.nvim_get_current_buf()
  local diags_win = vim.api.nvim_get_current_win()

  -- Get and process diagnostics
  local diags = vim.diagnostic.get()
  local processed_diags = {}
  for _, value in ipairs(diags) do
    local filename = vim.api.nvim_buf_get_name(value.bufnr)

    if processed_diags[filename] then
      table.insert(processed_diags[filename],
        {
          file_name = filename,
          diagnostic_line = {
            "    |" ..
                (value.lnum + 1) ..
                " " ..
                diagnostic_type[value.severity] ..
                "|" .. " " .. value.message .. " " .. "[" .. value.source .. " " .. value.code .. "]"
          }
        })
    else
      processed_diags[filename] = {}
      table.insert(processed_diags[filename],
        {
          file_name = filename,
          diagnostic_line = {
            "    |" ..
                (value.lnum + 1) ..
                " " ..
                diagnostic_type[value.severity] ..
                "|" .. " " .. value.message .. " " .. "[" .. value.source .. " " .. value.code .. "]"
          }
        })
    end
  end

  -- unlock buffer
  vim.api.nvim_buf_set_option(diags_buf, 'readonly', false)
  vim.api.nvim_buf_set_option(diags_buf, 'modifiable', true)

  vim.api.nvim_buf_set_name(diags_buf, 'showmeerrors')

  -- Set buffer options
  vim.cmd("setlocal nonu")
  vim.cmd("setlocal nornu")
  vim.api.nvim_buf_set_option(diags_buf, 'bufhidden', "wipe")
  vim.api.nvim_buf_set_option(diags_buf, 'buftype', "nofile")
  vim.api.nvim_buf_set_option(diags_buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(diags_buf, 'buflisted', false)

  -- Set window options
  vim.api.nvim_win_set_option(diags_win, 'winfixheight', true)
  vim.api.nvim_win_set_option(diags_win, 'winfixwidth', true)
  vim.api.nvim_win_set_height(diags_win, 10)

  for filename, diagnostic in pairs(processed_diags) do
    local diags_count = utils.count(diagnostic)
    vim.api.nvim_buf_set_lines(diags_buf, 1, 1, true, { filename .. " " .. diags_count })
    for i, renderable_diagnostic in ipairs(diagnostic) do
      vim.api.nvim_buf_set_lines(diags_buf, i + 1, i + 1, true, renderable_diagnostic.diagnostic_line)
    end
  end

  -- lock buffer
  vim.api.nvim_buf_set_option(diags_buf, 'readonly', true)
  vim.api.nvim_buf_set_option(diags_buf, 'modifiable', false)
end

ShowErrors.send_to_qf_list = function()
  vim.diagnostic.setqflist()
end

ShowErrors.reset = function()
  package.loaded["showmeerrors"] = nil
  print("showmeerrors has been reset")
end

return ShowErrors
