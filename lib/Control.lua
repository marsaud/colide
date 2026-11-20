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
local format = require("network.protocol").format

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

local AController = Class({
  __constructors = {
    Controller = function(self)
      self._pile = {}
    end,
  },

  fetch = function(self)
    error("AController.fetch is abstract")
  end,

  poll = function(self)
    return table.remove(self._pile, 1)
  end,
})

local KeyboardController = AController:extend({
  __constructors = {
    KeyboardController = function(self)
      if self.map then
        self._map = self.map
        self.map = nil
      end
      if self.channel then
        self._channel = self.channel
        self.channel = nil
      else
        self._channel = DEFAULT_CONTROL_CHANNEL
      end
    end,
  },

  fetch = function(self, _test)
    local ctrl = pullControl(self._map or defaultKeyMaps[1], _test or love)
    if ctrl ~= CONTROL.NONE then
      table.insert(self._pile, { [self._channel] = ctrl })
    end
  end,
})

local DispatchController = AController:extend({
  __constructors = {
    DispatchController = function(self)
      self._controllers = {}
      self.pile = {}
    end,
  },

  addController = function(self, controller)
    self._controllers[controller._channel or DEFAULT_CONTROL_CHANNEL] = controller
    return self
  end,

  removeController = function(self, channel)
    self._controllers[channel or DEFAULT_CONTROL_CHANNEL] = nil
    return self
  end,

  fetch = function(self, _test)
    local next = next
    local ctrls = {}
    for ch, c in pairs(self._controllers) do
      c:fetch(_test)
      local ctrl = c:poll()
      while ctrl ~= nil do
        ctrls[ch] = ctrl[ch]
        ctrl = c:poll()
      end
    end
    if next(ctrls) ~= nil then
      table.insert(self._pile, ctrls)
    end
  end,

  poll = function(self)
    return table.remove(self._pile, 1)
  end,
})

local ClientControllerWrapper = AController:extend({
  __constructors = {
    ClientControllerWrapper = function(self)
      if not L.x(self.controller) then
        error("Missing wrapped controller")
      end
      if not L.x(self.client) then
        error("Missing Client instance")
      end
      self._controller = self.controller
      self.controller = nil
      self._client = self.client
      self.client = nil
    end,
  },

  fetch = function(self, _test)
    return self._controller:fetch(_test)
  end,

  poll = function(self)
    local ctrls = self._controller:poll()
    if ctrls == nil then
      return nil
    end
    local ctrlms = {}
    for ch, ctrl in pairs(ctrls) do
      table.insert(ctrlms, format("|", ctrl, ch))
    end
    local message = format("%", table.unpack(ctrlms))
    local _, err = self._client:send(message)
    if err then
      error(err)
    end
    return ctrls
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
  AController = AController,
  ClientControllerWrapper = ClientControllerWrapper,
  DispatchController = DispatchController,
  IAControl = IAControl,
  IControlMove = IControlMove,
  KeyboardController = KeyboardController,
  defaultKeyMaps = defaultKeyMaps,
  pullControl = pullControl,
  testControl = testControl,
}
