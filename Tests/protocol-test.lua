require("workHelpers")
local parse = require("network/protocol").parse

local stringPrint = function(...)
  local args = { ... }
  for i, v in ipairs(args) do
    args[i] = "`" .. v .. "`"
  end
  print(table.unpack(args))
end

local data = {
  { "foo bar baz" },
  { "foo bar baz", " " },
  { "foo bar baz", "b" },
}

local run = function()
  print("network/protocol.lua")
  for i, v in ipairs(data) do
    print("test " .. i)
    stringPrint(table.unpack(v))
    stringPrint("output", parse(table.unpack(v)))
  end
end

return run, "protocol.lua"
