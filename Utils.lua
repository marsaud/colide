local OOP = require("OOP")
local Class = OOP.Class
local Collide = require("Collide")
local IACollide = Collide.IACollide
local Control = require("Control")
local IAControl = Control.IAControl
local Draw = require("Draw")
local IADraw = Draw.IADraw
local Hit = require("Hit")
local IAHit = Hit.IAHit
local Move = require("Move")
local IAMove = Move.IAMove
local Place = require("Place")
local IAPlace = Place.IAPlace
local State = require("State")
local IAState = State.IAState
local Event = require("Event")
local IEventCatcher = Event.IEventCatcher
local Plugin = require("Plugin")
local PluginManager = Plugin.PluginManager

local AGameUIObject =
  Class(IACollide, IAControl, IADraw, IAHit, IAMove, IAPlace, IAState, IEventCatcher, PluginManager)

local Group = Class({
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
      if o.setOrigin then
        o:setOrigin(self)
      end
      if o.setMover then
        o:setMover(self)
      end
      table.insert(self._group, o)
    end
  end,
  remove = function(self, o)
    if not self._group then
      self._group = {}
    end
    for _, v in ipairs(self._group) do
      if v == o then
        table.remove(self._group, v)
        v.group = nil
        if v.removeOrigin then
          v:removeOrigin()
        end
        if v.removeMover then
          v:removeMover()
        end
        break
      end
    end
    return o
  end,
}, IEventCatcher)

return {
  AGameUIObject = AGameUIObject,
  Group = Group,
}
