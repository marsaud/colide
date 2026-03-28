---@diagnostic disable-next-line: undefined-global
local bit = bit
-- IMPORTS
require("math-ext")
local Coord, _, _, Vector = require("Couple")()
local _, CONTROL, EVENT, MOVE = require("Const")()
local _, testControl = require("Control")()
-- local debug = require("Debug")()
-- END IMPORTS

local moveVectors = {
	[MOVE.UP] = Vector:new({ x = 0, y = -1 }),
	[MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
	[MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
	[MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
	[MOVE.NONE] = Vector:new({ x = 0, y = 0 })
}

local IAMove = {
	IAMove = true,

	_new = function (self)
		self._c = Coord:new({x = self.x, y = self.y})  -- internal coord
		self._d = self._c:copy() -- internal destination
		self.d = self._d:copy() -- visible destination
	end,

	_control = function (self, ctrl, dt)
		return self:move(ctrl, dt)
	end,

	move = function (self, ctrl, dt)
		if self._move then
			self.vector = self:_move(self.vector, ctrl, dt)
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

	commit = function (self)
		if self.group then return end
		if self._commit then
			self:_commit()
		end
		return true
	end,

	_commit = function (self)
		if self.d ~= self._d:round() then
			self._d = self.d:copy()
		end
		self._c = self._d:copy()
		self.x = math.round(self._c.x)
		self.y = math.round(self._c.y)
		self.vector = self:_initVector()
	end,

	_initVector = function (_)
		return moveVectors[MOVE.NONE]:copy()
	end,
}

local IMove = {
	_move = function (_, v, ctrl, _)
		if v == nil then
			v = moveVectors[MOVE.NONE]
		else
			v = v:copy()
		end
		if testControl(ctrl, CONTROL.UP) then
			v = v + moveVectors[MOVE.UP]
		end
		if testControl(ctrl, CONTROL.DOWN) then
			v = v + moveVectors[MOVE.DOWN]
		end
		if testControl(ctrl, CONTROL.LEFT) then
			v = v + moveVectors[MOVE.LEFT]
		end
		if testControl(ctrl, CONTROL.RIGHT) then
			v = v + moveVectors[MOVE.RIGHT]
		end
		return v
	end,
}

local IMoveX = {
	_move = function (_, v, ctrl, _)
		v = v:copy()
		if testControl(ctrl, CONTROL.LEFT) then
			v = v + moveVectors[MOVE.LEFT]
		end
		if testControl(ctrl, CONTROL.RIGHT) then
			v = v + moveVectors[MOVE.RIGHT]
		end
		return v
	end,
}

local IMoveY = {
	_move = function (_, v, ctrl, _)
		v = v:copy()
		if testControl(ctrl, CONTROL.UP) then
			v = v + moveVectors[MOVE.UP]
		end
		if testControl(ctrl, CONTROL.DOWN) then
			v = v + moveVectors[MOVE.DOWN]
		end
		return v
	end,
}

local IMoveNot = {
	_move = function (self, _, _, _)
		return moveVectors[MOVE.NONE]:copy()
	end,
}

local IMoveGroup = {
	_move = function (self, v, ctrl, dt)
		return self.group:_move(v, ctrl, dt)
	end
}

return function () return
	moveVectors,
	IAMove,
	IMove,
	IMoveNot,
	IMoveX,
	IMoveY,
	IMoveGroup
end