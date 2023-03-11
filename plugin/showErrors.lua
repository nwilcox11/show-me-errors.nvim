-- TODO:
-- Set up auto command to refresh diagnostic list as user makes changes to file.
vim.api.nvim_create_user_command("ShowErrors", function()
  require('showmeerrors').show_me()
end, {})

vim.api.nvim_create_user_command("ShowErrorsReset", function()
  require('showmeerrors').reset()
end, {})

