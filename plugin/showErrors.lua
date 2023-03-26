-- TODO:
-- Set up auto command to refresh diagnostic list as user makes changes to file.
vim.api.nvim_create_user_command("ShowErrors", function()
  require('showmeerrors').open()
end, {})

vim.api.nvim_create_user_command("ShowErrorsToggle", function()
  require('showmeerrors').toggle()
end, {})

vim.api.nvim_create_user_command("ShowErrorsReset", function()
  require('showmeerrors.utils').reset()
end, {})

