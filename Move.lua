-- IMPORTS
require("math-ext")
local _, Trait = require("POO")()
local Coord, _, _, Vector = require("Couple")()
local _, _, MOVE = require("Const")()
-- END IMPORTS

local moveVectors = {
	[MOVE.UP] = Vector:new({ x  = 0, y = -1 }),
	[MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
	[MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
	[MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
	[MOVE.NONE] = Vector:new({ x = 0, y = 0 })
}

local IAMove = Trait:new({
	_new = function (self)
		self._c = Coord:new({x = self.x, y = self.y})
		self._d = self._c:copy()
		self.d = self._d:copy()
	end,
	move = function (self)
		if self._move then
			self:_move()
		end
	end,
	commit = function (self)
		if self._commit then
			self:_commit()
		end
	end
})

local IMoveMove = Trait:new({
	_move = function (self)
		self._d = self._c + self.vector
		self.d = self._d:round()
	end,
	_commit = function (self)
		if not (self.d == self._d:round()) then
			self._d = self.d:copy()
		end
		self._c = self._d:copy()
		self.x = math.round(self._c.x)
		self.y = math.round(self._c.y)
		self.vector = moveVectors[MOVE.NONE]:copy()
	end
})

local IMoveNot = Trait:new({
	_move = function (self)
		self._d = self._c:copy()
		self.d = self._c:copy()
	end,
	_commit = function (self)
		self._d = self._c:copy()
		self.d = self._c:copy()
	end
})

return function () return moveVectors, IAMove, IMoveMove, IMoveNot end