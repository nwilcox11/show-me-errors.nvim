local utils = require("showmeerrors.utils")

local Processer = {}
Processer.__index = Processer

Processer.items = {}

local diagnostic_type = {
  [1] = "Error",
  [2] = "Warn",
  [3] = "Info",
  [4] = "Hint",
}

function Processer:new()
  local this = {
    items = {}
  }

  setmetatable(this, self)
  return this
end

function Processer:group_diagnostics()
  local diags = vim.diagnostic.get()
  local grouped = {}

  for _, value in ipairs(diags) do
    local filename = vim.api.nvim_buf_get_name(value.bufnr)

    if grouped[filename] == nil then
      grouped[filename] = {}
    end

    local diag_item = self:grouped_diagnostic_item(value, filename)

    table.insert(grouped[filename], diag_item)
  end

  return grouped
end

function Processer:process_diagnostics()
  local grouped = Processer:group_diagnostics()
  -- Map diags into trackable format
  local lineNr = 1
  for filename, diagnostic in pairs(grouped) do
    self.items[lineNr] = self:trackable_diagnostic_file(filename, diagnostic)
    lineNr = lineNr + 1

    for _, renderable_diagnostic in ipairs(diagnostic) do
      self.items[lineNr] = self:trackable_diagnostic_item(filename, renderable_diagnostic)
      lineNr = lineNr + 1
    end
  end
end

---@private
function Processer:build_line_message(diagnostic)
  return "    | " ..
      (diagnostic.lnum + 1) ..
      " " ..
      diagnostic_type[diagnostic.severity] ..
      " |" .. " " .. diagnostic.message .. " " .. "[" .. diagnostic.source .. " " .. diagnostic.code .. "]"
end

---@private
function Processer:grouped_diagnostic_item(diagnostic, filename)
  return {
    buf = diagnostic.bufnr,
    file_name = filename,
    loc = { diagnostic.lnum + 1, diagnostic.col },
    diagnostic_line = self:build_line_message(diagnostic)
  }
end


---@private
function Processer:trackable_diagnostic_file(filename, diagnostic_list)
  return {
    is_file = true,
    filename = filename,
    message = filename .. " " .. utils.count(diagnostic_list),
  }
end

---@private
function Processer:trackable_diagnostic_item(filename, grouped_diagnostic)
  return {
    is_file = false,
    buf = grouped_diagnostic.buf,
    loc = grouped_diagnostic.loc,
    message = grouped_diagnostic.diagnostic_line,
    filename = filename,
  }
end


return Processer
