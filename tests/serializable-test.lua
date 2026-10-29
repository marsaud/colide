local _s = require("Serializable")._s
local serialize = require("Serializable").serialize
local unserialize = require("Serializable").unserialize

local testData = {
  1,
  "a",
  { 1, 2 },
  {
    2,
    "foo",
  },
  {
    x = 1,
    y = "bar",
    z = {
      3,
      "baz",
    },
    j = {
      k = 4,
      l = 'q"U"x',
    },
    {
      33,
      tt = "qq",
      rr = "ss",
      66,
    },
  },
}

local test1 = function()
  for n, d in ipairs(testData) do
    local sout = _s(d)
    print(sout)
  end
end

local function printT(t, p)
  if type(t) == "table" then
    for k, v in pairs(t) do
      print((p or "") .. "\t", k, v)
      printT(v, "\t")
    end
  end
end

local test2 = function()
  for n, d in ipairs(testData) do
    local sout = serialize(d)
    local uout = unserialize(sout)
    print(n, d, _s(d), sout, uout)
    printT(uout)
  end
end

local run = function()
  -- test1()
  test2()
end

return run, "Serializable.lua"
