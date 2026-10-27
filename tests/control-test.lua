require("workHelpers")

local debug = require("Debug").debug

local Control = require("Control")
local KeyboardController = Control.KeyboardController
local DispatchController = Control.DispatchController
local defaultKeyMaps = Control.defaultKeyMaps
local pullControl = Control.pullControl

local keys = {}

local tLove = {
  keyboard = {
    isDown = function(key)
      return keys[key]
    end,
  },
}

local prepareKeys = function()
  for i, m in ipairs(defaultKeyMaps) do
    print("Prepare map " .. i)
    for _, key in pairs(m) do
      keys[key] = false
    end
  end
  debug(keys)
end

local testPullControl = function()
  print("TEST: pullControl")
  for i, m in ipairs(defaultKeyMaps) do
    print("Test map " .. i)
    debug(m)
    for key, _ in pairs(keys) do
      print("Test " .. key)
      keys[key] = true
      print("result " .. pullControl(m, tLove))
      keys[key] = false
    end
  end
end

local testKeyboardController = function()
  print("TEST: KeyboardController")
  for i, m in ipairs(defaultKeyMaps) do
    print("Test map " .. i)
    local kc = KeyboardController:new({ map = m })
    for key, _ in pairs(keys) do
      print("Test " .. key)
      keys[key] = true
      kc:fetch(tLove)
      local r = kc:poll()
      while r ~= nil do
        debug("result ", r)
        r = kc:poll()
      end
      keys[key] = false
    end
  end
end

local testDispatchController = function()
  print("TEST: DispatchController")
  local k1 = KeyboardController:new({ map = defaultKeyMaps[1] })
  local k2 = KeyboardController:new()
  local k3 = KeyboardController:new({ map = defaultKeyMaps[2] })
  local dc = DispatchController:new()
  dc:addController(k1, "k1")
  dc:addController(k2)
  dc:addController(k3, "k3")
  for key, _ in pairs(keys) do
    print("Test " .. key)
    keys[key] = true
    dc:fetch(tLove)
    local r, ch = dc:poll()
    while r ~= nil do
      debug("result ", r, ch)
      r, ch = dc:poll()
    end
    keys[key] = false
  end
end

local run = function()
  prepareKeys()
  testPullControl()
  testKeyboardController()
  testDispatchController()
end

return run, "Control.lua"
