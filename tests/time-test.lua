local monotime = require("time").monotime

local run = function()
  local ellapsed = 0
  local start = monotime()

  while ellapsed < 3 do
    ellapsed = monotime() - start
    print(ellapsed)
  end
end

return run, "time.lua"
