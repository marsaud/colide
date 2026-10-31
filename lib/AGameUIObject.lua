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
local Serializable = require("Serializable").Serializable

local AGameUIObject = Class(
  IACollide,
  IAControl,
  IADraw,
  IAHit,
  IAMove,
  IAPlace,
  IAState,
  IEventCatcher,
  PluginManager,
  Serializable
)

return {
  AGameUIObject = AGameUIObject,
}
