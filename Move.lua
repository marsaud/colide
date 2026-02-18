-- IMPORTS
require("math-ext")
local _, Trait = require("POO")()
local Coord, _, _, Vector = require("Couple")()
local _, CONTROL, MOVE = require("Const")()
local EVENT, _ = require("Event")()
-- local debug = require("Debug")()
-- END IMPORTS

local moveVectors = {
	[MOVE.UP] = Vector:new({ x = 0, y = -1 }),
	[MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
	[MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
	[MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
	[MOVE.NONE] = Vector:new({ x = 0, y = 0 })
}

local IAMove = Trait:new({
	IAMove = true,
	_new = function (self)
		self._c = Coord:new({x = self.x, y = self.y})  -- internal coord
		self._d = self._c:copy() -- internal destination
		self.d = self._d:copy() -- visible destination
	end,
	move = function (self, ctrl, dt)
		if ctrl >= CONTROL.ACT1 then ctrl = ctrl - CONTROL.ACT1 end
		if ctrl >= CONTROL.ACT2 then ctrl = ctrl - CONTROL.ACT2 end
		if ctrl >= CONTROL.ACT3 then ctrl = ctrl - CONTROL.ACT3 end
		if ctrl >= CONTROL.UP then
			ctrl = ctrl - CONTROL.UP
			self.vector = self.vector + moveVectors[CONTROL.UP]
		end
		if ctrl >= CONTROL.DOWN then
			ctrl = ctrl - CONTROL.DOWN
			self.vector = self.vector + moveVectors[CONTROL.DOWN]
		end
		if ctrl >= CONTROL.LEFT then
			ctrl = ctrl -CONTROL.LEFT
			self.vector = self.vector + moveVectors[CONTROL.LEFT]
		end
		if ctrl >= CONTROL.RIGHT then
			self.vector = self.vector + moveVectors[CONTROL.RIGHT]
		end
		if self._move then
			self:_move(ctrl, dt)
		end
		self.vector = (self.vector * (self.speed or 1) * dt)
		self._d = self._c + self.vector
		self.d = self._d:round()
		if self.eventManager then
			if self._d ~= self._c then
				self.eventManager:fire(EVENT.MOVE, self)
			end
		end
	end,
	commit = function (self, next, ...)
		if self._commit then
			self:_commit()
		end
		if self.d ~= self._d:round() then
			self._d = self.d:copy()
		end
		self._c = self._d:copy()
		self.x = math.round(self._c.x)
		self.y = math.round(self._c.y)
		self.vector = self:_initVector()
		if next then
			next:commit(...)
		end
	end,
	_initVector = function (_)
		return moveVectors[MOVE.NONE]:copy()
	end
})

local IMoveX = Trait:new({
	_move = function (self, _, _)
		self.vector.y = 0
	end,
})

local IMoveY = Trait:new({
	_move = function (self, _, _)
		self.vector.x = 0
	end,
})

local IMove = Trait:new({
})

local IMoveAuto = Trait:new({
	_move = function (self, ctrl, dt)
		if self.getMove then
			self.vector = self:getMove(self.vector, ctrl, dt)
		end
	end
})

local IMoveNot = Trait:new({
	_move = function (self)
		self.vector.x = 0
		self.vector.y = 0
	end,
})

return function () return
	moveVectors,
	IAMove,
	IMove,
	IMoveAuto,
	IMoveNot,
	IMoveX,
	IMoveY
end