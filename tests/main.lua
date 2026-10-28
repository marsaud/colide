package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local runs = {}

-- local pT = require("protocol-test")
-- table.insert(runs, pT)
-- local cT = require("control-test")
-- table.insert(runs, cT)
local oT = require("oop-test")
table.insert(runs, oT)
for _, r in ipairs(runs) do
  r()
end

love.event.quit(0)
