local M = {}

M.count = function(iterator)
  local result = 0
  for _ in pairs(iterator) do
    result = result + 1
  end
  return result
end

M.reset = function()
  package.loaded["showmeerrors"] = nil
  print("RESET")
end

return M
