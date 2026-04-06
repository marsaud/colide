local IACollide, _, _, _, _, _ = require("Collide")()
local _, _, IAControl = require("Control")()
local IADraw, _, _ = require("Draw")()
local _, IEventCatcher = require("Event")()
local IAPlace = require("Place")()
local _, IAMove, _, _, _, _ = require("Move")()
local Class = require("OOP")()
local PluginManager = require("Plugin")()

local AGameUIObject =
  Class(IAControl, IAPlace, IADraw, IAMove, IACollide, IEventCatcher, PluginManager)

local Group = Class(IEventCatcher, {
  add = function(self, ...)
    if not self._group then
      self._group = {}
    end
    local arg = { ... }
    for _, o in ipairs(arg) do
      if o.group then
        error("Group: object already in a group")
      end
      if o._group then
        error("Group: don't add groups to groups")
      end
      o.group = self
      table.insert(self._group, o)
    end
  end,
  remove = function(self, o)
    if not self._group then
      self._group = {}
    end
    for i, v in ipairs(self._group) do
      if v == o then
        table.remove(self._group, v)
        v.group = nil
        break
      end
    end
    return o
  end,
})

return function()
  return AGameUIObject, Group
end
