-- TODO: Figure out a good way to write tests.
-- We probably shouldn't be testing implementation details, just the public api.
describe("Showmeerrors", function()
  it("can be required", function()
    require("showmeerrors")
  end)

  it("renders the correct diagnostics", function()
    local toggle = require("showmeerrors").toggle
    local view = toggle()
    P(view)
  end)
end)
