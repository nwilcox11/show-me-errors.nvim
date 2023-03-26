local Diag_view = require("showmeerrors.diag_view")

local ShowErrors = {}
local view

ShowErrors.is_view_open = function ()
  return view and view:is_open() or false
end

ShowErrors.toggle = function()
  if ShowErrors.is_view_open() then
    ShowErrors.close()
  else
    ShowErrors.open()
  end

  return view
end

ShowErrors.doaction = function(action_kind)
  if action_kind == 'select' then
    local current_diag = view:get_current_diagnostic()

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
  view = Diag_view:create_view()
  view:render()
end

ShowErrors.close = function ()
  view:close()
end

ShowErrors.send_to_qf_list = function()
  vim.diagnostic.setqflist()
end

return ShowErrors
