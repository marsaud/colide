local bit = bit

local _, ICollideBlocker, _, _, _, ICollidePusher = require("Collide")()
local _, CONTROL, _, MOVE = require("Const")()
local _, testControl = require("Control")()
local _, Point, _, _ = require("Couple")()
local _, IRectFill, IRectLine = require("Draw")()
local moveVectors, _, IMove, _, IMoveX, IMoveY = require("Move")()
local AGameUIObject = require("Utils")()

local helpers = require("helpers")
local ICollapse = helpers.ICollapse

local function invaders ()
		local Vessel = {
			vesselStateIndex = 1,
			vesselStates = {
				MOVE.RIGHT,
				MOVE.DOWN,
				MOVE.LEFT,
				MOVE.DOWN,
			},
			getMove = function (self, _, _, _)
				if not self.vesselOrigin then
					self.vesselOrigin = Point:new({x = self.x, y = self.y})
				end
				if self.vesselStateIndex == 1 then
					local delta = self.x - self.vesselOrigin.x
					if delta >= 100 then
						self.vesselStateIndex = 2
					end
				end
				if self.vesselStateIndex == 2 then
					local delta = self.y - self.vesselOrigin.y
					if delta >= 50 then
						self.vesselStateIndex = 3
					end
				end
				if self.vesselStateIndex == 3 then
					local delta = self.x - self.vesselOrigin.x
					if delta <= 0 then
						self.vesselStateIndex = 4
					end
				end
				if self.vesselStateIndex == 4 then
					local delta = self.y - self.vesselOrigin.y
					if delta >= 100 then
						self.vesselStateIndex = 1
						self.vesselOrigin = Point:new({x = self.x, y = self.y})
					end
				end
				return moveVectors[self.vesselStates[self.vesselStateIndex]]:copy()
			end
		}

		local objects = {}

		for x = 20, 620, 50 do
			for y = 50, 300, 50 do
				table.insert(objects, AGameUIObject:new({
					id = 'vessel',
					x = x,
					y = y,
					w = 40,
					h = 40,
					health = 100,
					speed = 10,
					vector = moveVectors[MOVE.NONE]:copy(),
					getHit = function (_, _) return 100 end,
				}, IMove, ICollidePusher, IRectLine, ICollapse, Vessel))
			end
		end

		local Missile = AGameUIObject:new({
			getHit = function (_, _) return 100 end,
			getMove = function () return moveVectors[MOVE.UP] end
		}, IMoveY, ICollidePusher, ICollapse)

		local shipFire = function (self, ctrl, dt)
			if testControl(ctrl, CONTROL.ACT1) then
				if self.eventManager then
					if self._SHIP_FIRE_DELAY and self._SHIP_FIRE_DELAY >= 0 then
						self._SHIP_FIRE_DELAY = self._SHIP_FIRE_DELAY - dt
					else
						local missile = Missile:new({
							id = 'missile',
							x = self.x + 18,
							y = self.y - 10,
							w = 4,
							h = 10,
							speed = 50,
							vector = moveVectors[MOVE.NONE]:copy(),
							health = 100
						}, IRectFill)
						self.eventManager:addObjects(missile)
						self._SHIP_FIRE_DELAY = 0.3
					end
				end
			end
		end

		local Ship = AGameUIObject:new(IMoveX, ICollideBlocker, ICollidePusher, {
			_control = shipFire
		})
		local ship = Ship:new({
			id = 'ship',
			x = 400,
			y = 550,
			w = 40,
			h = 40,
			speed = 300,
			vector = moveVectors[MOVE.NONE]:copy(),
		}, IRectLine)
		table.insert(objects, ship)

		return objects
	end

  return invaders