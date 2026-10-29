package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local runs = {}

local tests = {
  "protocol-test",
  "control-test",
  "oop-test",
}

for _, test in ipairs(tests) do
  local r = require(test)
  print("--- RUNNING : " .. test .. "----\n")
  r()
end

love.event.quit(0)
