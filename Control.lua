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

local AController = Class({
  _constructors = {
    Controller = function(self)
      self._pile = {}
    end,
  },

  poll = function(self)
    return table.remove(self._pile, 1)
  end,
})

local function pullControl()
  return (love.keyboard.isDown("space") and CONTROL.ACT1 or 0)
    + (love.keyboard.isDown("up") and CONTROL.UP or 0)
    + (love.keyboard.isDown("down") and CONTROL.DOWN or 0)
    + (love.keyboard.isDown("left") and CONTROL.LEFT or 0)
    + (love.keyboard.isDown("right") and CONTROL.RIGHT or 0)
end

local KeyboardController = AController:extend({
  fetch = function(self)
    table.insert(self._pile, pullControl())
  end,
})

local NetworkController = AController:new({
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

local function testControl(state, value)
  if state == nil then
    return false
  end
  return bit.band(state, value) ~= 0
end

local IAControl = {
  control = function(self, ctrl, dt)
    local result = false
    if self.runPrePlugins then
      result = self:runPrePlugins("_control", self, ctrl, dt)
    end
    if self._control then
      result = self:_control(ctrl, dt) or result
    end
    if self.runPostPlugins then
      result = self:runPostPlugins("_control", self, ctrl, dt) or result
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
  IAControl = IAControl,
  IControlMove = IControlMove,
  KeyboardController = KeyboardController,
}
