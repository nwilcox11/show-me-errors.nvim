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

  -- Get and process diagnostics
  local diags = vim.diagnostic.get()
  local processed_diags = {}
  for _, value in ipairs(diags) do
    local filename = vim.api.nvim_buf_get_name(value.bufnr)
    table.insert(processed_diags,
      {
        filename ..
            "|" ..
            (value.lnum + 1) ..
            " " ..
            diagnostic_type[value.severity] ..
            "|" .. " " .. value.message .. " " .. "[" .. value.source .. " " .. value.code .. "]"
      })
  end

  -- unlock buffer
  vim.api.nvim_buf_set_option(diags_buf, 'readonly', false)
  vim.api.nvim_buf_set_option(diags_buf, 'modifiable', true)

  vim.api.nvim_buf_set_name(diags_buf, 'showmeerrors')

  -- Set buffer options
  vim.api.nvim_buf_set_option(diags_buf, 'bufhidden', "wipe")
  vim.api.nvim_buf_set_option(diags_buf, 'buftype', "nofile")
  vim.api.nvim_buf_set_option(diags_buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(diags_buf, 'buflisted', false)

  -- Write processed diagnostics to buffer
  for i, lines in ipairs(processed_diags) do
    vim.api.nvim_buf_set_lines(diags_buf, i, i, true, lines)
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
