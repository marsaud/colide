local love = love

local IACollide, _, _, _, _, _ = require("Collide")()
local IADraw, _, _ = require("Draw")()
local _, IEventCatcher = require("Event")()
local _, IAMove, _, _, _, _ = require("Move")()
local Class = require("OOP")()
local PluginManager = require("Plugin")()

local AGameUIObject = Class(IADraw, IAMove, IACollide, IEventCatcher, PluginManager)

return function () return AGameUIObject end