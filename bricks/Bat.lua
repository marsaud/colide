local Collide = require("Collide")
local ICollideBlocker, ICollidePusher = Collide.ICollideBlocker, Collide.ICollidePusher
local IControlMove = require("Control").IControlMove
local IRectLine = require("Draw").IRectLine
local IMoveX = require("Move").IMoveX
local AGameUIObject = require("Utils").AGameUIObject

local Bat = AGameUIObject:new(IControlMove, IMoveX, ICollideBlocker, ICollidePusher, IRectLine)

return {
  Bat = Bat,
}
