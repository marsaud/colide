local Collide = require("Collide")
local ICollideBlocker, ICollidePusher = Collide.ICollideBlocker, Collide.ICollidePusher
local IControlMove = require("Control").IControlMove
local IRectLine = require("Draw").IRectLine
local IMoveX = require("Move").IMoveX
local AGameUIObject = require("AGameUIObject").AGameUIObject

local Bat = AGameUIObject:extend(IControlMove, IMoveX, ICollideBlocker, ICollidePusher, IRectLine)

return {
  Bat = Bat,
}
