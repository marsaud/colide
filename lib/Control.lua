---@diagnostic disable-next-line: undefined-global
local love = love
---@diagnostic disable-next-line: undefined-global
local bit = bit

local L = require("lib")
local OOP = require("OOP")
local Class = OOP.Class
local C = require("Const")
local CONTROL = C.CONTROL
-- local debug = require("Debug").debug
local DEFAULT_CONTROL_CHANNEL = C.DEFAULT_CONTROL_CHANNEL

local AController = Class({
  _constructors = {
    Controller = function(self)
      self._pile = {}
    end,
  },

  fetch = function(self)
    error("AController.fetch is abstract")
  end,

  poll = function(self)
    return table.remove(self._pile, 1), DEFAULT_CONTROL_CHANNEL
  end,
})

local defaultKeyMaps = {
  {
    [CONTROL.ACT1] = "space",
    [CONTROL.UP] = "up",
    [CONTROL.DOWN] = "down",
    [CONTROL.LEFT] = "left",
    [CONTROL.RIGHT] = "right",
  },
  {
    [CONTROL.ACT1] = "x",
    [CONTROL.UP] = "z",
    [CONTROL.DOWN] = "s",
    [CONTROL.LEFT] = "q",
    [CONTROL.RIGHT] = "d",
  },
}

local function pullControl(map, _test)
  if not map then
    map = defaultKeyMaps[1]
  end
  local ctrl = 0
  for c, k in pairs(map) do
    ctrl = ctrl + ((_test or love).keyboard.isDown(k) and c or 0)
  end
  return ctrl
end

local KeyboardController = AController:extend({
  _constructors = {
    KeyboardController = function(self)
      if self.map then
        self._map = self.map
        self.map = nil
      end
    end,
  },

  fetch = function(self, _test)
    local ctrl = pullControl(self._map or defaultKeyMaps[1], _test or love)
    if ctrl ~= CONTROL.NONE then
      table.insert(self._pile, ctrl)
    end
  end,
})

local NetworkController = AController:extend({
  _constructors = {
    NetworkController = function(self)
      if not L.x(self.server) then
        error("Server instance required")
      end
      self._server = self.server
      self.server = nil
    end,
  },

  fetch = function(self)
    local message = self._server:poll()
    while message ~= nil do
      table.insert(self._pile, message)
      message = self._server:poll()
    end
  end,
})

local DispatchController = AController:extend({
  _constructors = {
    DispatchController = function(self)
      self._controllers = {}
      self.pile = {}
    end,
  },

  addController = function(self, controller, channel)
    self._controllers[channel or DEFAULT_CONTROL_CHANNEL] = controller
  end,

  removeController = function(self, channel)
    self._controllers[channel or DEFAULT_CONTROL_CHANNEL] = nil
  end,

  fetch = function(self, _test)
    for ch, c in pairs(self._controllers) do
      c:fetch(_test)
      local m = c:poll()
      while m ~= nil do
        table.insert(self._pile, { m = m, ch = ch })
        m = c:poll()
      end
    end
  end,

  poll = function(self)
    local mch = table.remove(self._pile, 1)
    if mch ~= nil then
      return mch.m, mch.ch
    end
    return nil
  end,
})

local function testControl(state, value)
  if state == nil then
    return false
  end
  return bit.band(state, value) ~= 0
end

local IAControl = {
  control = function(self, ctrl, dt, channel)
    local result = false
    if (self.channel or DEFAULT_CONTROL_CHANNEL) ~= (channel or DEFAULT_CONTROL_CHANNEL) then
      return result
    end
    if self.runPrePlugins then
      result = self:runPrePlugins("_control", ctrl, dt)
    end
    if self._control then
      result = self:_control(ctrl, dt) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("_control", ctrl, dt) or result
    end
    return result
  end,
}

local IControlMove = {
  _control = function(self, ctrl, dt)
    if self.move then
      return self:move(0, ctrl, dt)
    else
      return false
    end
  end,
}

return {
  pullControl = pullControl,
  testControl = testControl,
  DispatchController = DispatchController,
  IAControl = IAControl,
  IControlMove = IControlMove,
  KeyboardController = KeyboardController,
  NetworkController = NetworkController,
  defaultKeyMaps = defaultKeyMaps,
}
