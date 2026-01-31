-- IMPORTS
require("math-ext")
local new, Trait = require("POO")()
local Coord, Point, Size, Vector = require("Couple")()
-- END IMPORTS

-- CONSTANTS
local CONTROL = {
	UP = 1000,
	DOWN = 100,
	LEFT = 10,
	RIGHT = 1,
	NONE = 0
}

local MOVE = CONTROL

local COLOR = {
	WHITE = {1, 1, 1},
	BLACK = {0, 0, 0},
	RED = { 1, 0, 0 },
	GREEN = { 0, 1, 0 },
	BLUE = { 0, 0, 1 },
	YELLOW = { 1, 1, 0 },
	MAGENTA = { 1, 0, 1 },
	CYAN = { 0, 1, 1}
}
COLOR.DEFAULT = COLOR.WHITE
-- END CONSTANTS

-- INTERFACES

-- MOVE INTERFACES
local moveVectors = {
	[MOVE.UP] = Vector:new({ x  = 0, y = -1 }),
	[MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
	[MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
	[MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
	[MOVE.NONE] = Vector:new({ x = 0, y = 0 })
}

local IAMove = Trait:new({
	commit = function (self)
		if (self.d) then
			self.x = self.d.x or self.x
			self.y = self.d.y or self.y
			self.d = Coord:new({x = self.x, y = self.y})
		end
		self.vector = moveVectors[MOVE.NONE]:copy()
	end
})

local IAControl = Trait:new({
	move = function (self, m, dt)
		if not self.d then
			self.d = Coord:new({x = self.x, y = self.y})
		end
		if self._move then
			self:_move(m, dt)
			self.d = self.d + self.vector
		end
	end
})

local IControl2D = Trait:new({
	_move = function (self, m, dt)
		if m >= CONTROL.UP then
			m = m - CONTROL.UP
			self.vector = self.vector + moveVectors[CONTROL.UP]
		end
		if m >= CONTROL.DOWN then
			m = m - CONTROL.DOWN
			self.vector = self.vector + moveVectors[CONTROL.DOWN]
		end
		if m >= CONTROL.LEFT then
			m = m -CONTROL.LEFT
			self.vector = self.vector + moveVectors[CONTROL.LEFT]
		end
		if m >= CONTROL.RIGHT then
			self.vector = self.vector + moveVectors[CONTROL.RIGHT]
		end
		self.vector = (self.vector * self.speed * dt):round()
	end
})

local IControl1DX = Trait:new({
	_move = function (self, m, dt)
		if m >= CONTROL.UP then
			m = m - CONTROL.UP
		end
		if m >= CONTROL.DOWN then
			m = m - CONTROL.DOWN
		end
		if m >= CONTROL.LEFT then
			m = m -CONTROL.LEFT
			self.vector = self.vector + moveVectors[CONTROL.LEFT]
		end
		if m >= CONTROL.RIGHT then
			self.vector = self.vector + moveVectors[CONTROL.RIGHT]
		end
		self.vector = (self.vector * self.speed * dt):round()
	end
})

local IControl1DY = Trait:new({
	_move = function (self, m, dt)
		if m >= CONTROL.UP then
			m = m - CONTROL.UP
			self.vector = self.vector + moveVectors[CONTROL.UP]
		end
		if m >= CONTROL.DOWN then
			self.vector = self.vector + moveVectors[CONTROL.DOWN]
		end
		self.vector = (self.vector * self.speed * dt):round()
	end
})
-- END MOVE INTERFACES

-- DRAW INTERFACES
local IADraw = Trait:new({
	draw = function (self)
		love.graphics.setColor(self.color or COLOR.DEFAULT)
		if self._draw then
			self:_draw()
		end
	end
})

local IRect = Trait:new({
	_draw = function (self)
		love.graphics.rectangle("line", self.x, self.y,self.w, self.h)
	end
})
-- END DRAW INTERFACES

-- MAIN UTILITIES
local function pullControl()
	return (love.keyboard.isDown("up") and CONTROL.UP or 0) +
	(love.keyboard.isDown("down") and CONTROL.DOWN or 0) +
	(love.keyboard.isDown("left") and CONTROL.LEFT or 0) +
	(love.keyboard.isDown("right") and CONTROL.RIGHT or 0)
end

local function _resolveCollision1 (o1, o2)
	if o1.x >= (o2.x + o2.w) then return end -- right
	if (o1.x + o1.w) <= o2.x then return end -- left
	if o1.y >= (o2.y + o2.h) then return end -- under
	if (o1.y + o1.h) <= o2.y then return end -- on top

	p1, p2 = o1.priority, o2.priority
	if o1.vector == moveVectors[MOVE.NONE] then
		p1 = 0
	end
	if o2.vector == moveVectors[MOVE.NONE] then
		p2 = 0
	end
	if p1 + p2 == 0 then return end
	if p2 > p1 then
		o1, o2 = o2, o1
	end

	if (o1.vector.x > 0 and o1.x + o1.w < o2.x + o2.w / 2) or (o1.vector.x < 0 and o1.x > o2.x + o2.w / 2) then
		o2.vector = Vector:new({
			x = o1.vector.x,
			y = o2.vector.y
		})
		o2.x = o1.x + (o1.w * math.sign(o1.vector.x))
	end
	if (o1.vector.y > 0 and o1.y + o1.h < o2.y + o2.h / 2) or (o1.vector.y < 0 and o1.y > o2.y + o2.h / 2) then
		o2.vector = Vector:new({
			x = o2.vector.x,
			y = o1.vector.y
		})
		o2.y = o1.y + (o1.h * math.sign(o1.vector.y))
	end
end

local function _resolveCollision2 (o1, o2)
	if o1.x >= (o2.x + o2.w) then return end -- right
	if (o1.x + o1.w) <= o2.x then return end -- left
	if o1.y >= (o2.y + o2.h) then return end -- under
	if (o1.y + o1.h) <= o2.y then return end -- on top

	-- collision
	local p1, p2 = o1.priority, o2.priority
	if o1.vector == moveVectors[MOVE.NONE] then
		p1 = 0
	end
	if o2.vector == moveVectors[MOVE.NONE] then
		p2 = 0
	end
	if p1 + p2 == 0 then return end
	if p2 > p1 then
		o1, o2 = o2, o1
	end

	if (
		o1.vector.x > 0 and -- moving right
		o1.d.x + o1.w < o2.d.x + o2.w / 2 -- from the left
	)
		or
		(
			o1.vector.x < 0 and -- moving left
		o1.d.x > o2.d.x + o2.w / 2 -- from the right
	) then
		o2.vector = Vector:new({
			x = math.max(o1.vector.x, o2.vector.x),
			y = o2.vector.y
		})
		o2.d.x = o1.d.x + (o1.w * math.sign(o1.vector.x))
	end

	if (
		o1.vector.y > 0 and -- moving down
		o1.d.y + o1.h < o2.d.y + o2.h / 2 -- from top
	)
		or
		(
		o1.vector.y < 0 and -- moving up
		o1.d.y > o2.d.y + o2.h / 2 -- from under
	) then
		o2.vector = Vector:new({
			x = o2.vector.x,
			y = math.max(o1.vector.y, o2.vector.y)
		})
		o2.d.y = o1.d.y + (o1.h * math.sign(o1.vector.y))
	end

end

local function _resolveCollision (o1, o2)
	return _resolveCollision2 (o1, o2)
end

local function resolveCollisions (objects)
	for i = 1, (#objects - 1) do
		for j = i + 1, (#objects) do
			_resolveCollision(objects[i], objects[j])
		end
	end
end
-- END MAIN UTILITIES

-- GAME CLASSES

	--[[
An object may have interfaces:
- Draw(able)
	- Anim(able)
- Move(able)
	- Control(able)
	- Auto(matable)
- Collide
	- Harm(able)

An object may have properties:
- box (Coord, Size)
- move (Vector)
- auto (callback)
- anim (callback)
- collide (callback), life, strength
--]]

local AGameUIObject = {
	new = new,
	x = 0,
	y = 0,
	w = 100,
	h = 100,
	speed = 100,
	vector = moveVectors[MOVE.NONE]:copy()
} .. IADraw .. IAMove .. IAControl

local mObjects

function love.load()
	local ARect = AGameUIObject:new(IRect)
	local Rect2D = ARect:new(IControl2D)
	local Rect1DX = ARect:new(IControl1DX)
	local Rect1DY = ARect:new(IControl1DY)
	-- END GAME CLASSES

	-- GAME OBJECTS
	local rect1 = Rect2D:new({
		x = 10,
		y = 10,
		speed = 120,
		priority = 3,
		color = COLOR.RED
	})
	local rect2 = Rect2D:new({
		x = 120,
		y = 120,
		speed = 50,
		priority = 2,
		color = COLOR.GREEN
	})
	local rect3 = Rect2D:new({
		x = 230,
		y = 230,
		speed = 40,
		priority = 1,
		color = COLOR.BLUE
	})
	--[[
	rect4 = Rect1DX:new({
		x = 115,
		y = 115,
		speed = 110,
		color = COLOR.YELLOW
	})
	rect5 = Rect1DY:new({
		x = 240,
		y = 240,
		speed = 90,
		color = COLOR.MAGENTA
	})
	--]]

	mObjects = {
		rect1,
		rect2,
		rect3,
		--[[
		rect4,
		rect5
		--]]
	}
	-- END GAME OBJECTS
end

function love.update(dt)
	local move = pullControl()
	for _, o in ipairs(mObjects) do
		o:move(move, dt)
	end

	resolveCollisions(mObjects)

	for _, o in ipairs(mObjects) do
		o:commit()
	end
end

function love.draw()
	for _, o in ipairs(mObjects) do
		o:draw()
	end
end

