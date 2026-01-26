function love.load()

	-- MATH
	math.sign = function (n) return n / math.abs(n) end
	math.round = function (n) return math.ceil(n) - n > 0.5 and math.floor(n) or math.ceil(n) end
	-- END MATH

	-- IMPORTS
	new, Trait = require("poo")()
	-- END IMPORTS

	Coord = {
		new = new,
		__add = function (v1, v2)
			return Coord:new({
				x = v1.x + v2.x,
				y = v1.y + v2.y
			})
		end,
		__mul = function (v, f)
			if (type(f) ~= "number") then
				v, f = f, v
			end
			if (getmetatable(v) ~= Coord) then
				error("Type violation: Coord.__mul takes (Coord, number) or (number, Coord)")
			else
				return Coord:new({
				x = v.x * f,
				y = v.y * f
			})
			end
		end,
		__eq = function (v1, v2)
			return v1.x == v2.x and v1.y == v2.y
		end,
		copy = function (self)
			return Coord:new({ x = self.x, y = self.y })
		end
	}

	Vector = Coord
	Point = Coord

	-- CONSTANTS
	CONTROL = {
		UP = 1000,
		DOWN = 100,
		LEFT = 10,
		RIGHT = 1,
		NONE = 0
	}

	MOVE = CONTROL

	COLOR = {
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
	--[[
	An object may have interfaces:
	- Draw(able)
		- Anim(able)
	- Move(able)
		- Control(able)
		- Auto(matable)
	- Collide
		- Harm(able)
	--]]

	-- MOVE INTERFACES
	moveVectors = {
		[MOVE.UP] = Vector:new({ x  = 0, y = -1 }),
		[MOVE.DOWN] = Vector:new({ x = 0, y = 1 }),
		[MOVE.LEFT] = Vector:new({ x = -1, y = 0 }),
		[MOVE.RIGHT] = Vector:new({ x = 1, y = 0 }),
		[MOVE.NONE] = Vector:new({ x = 0, y = 0 })
	}

	IAControl = Trait:new({
		move = function (self, m, dt)
			if self._move then
				self:_move(m, dt)
			end
		end,
		commit = function (self)
			self.x = self.x + self.vector.x
			self.y = self.y + self.vector.y
			self.vector = moveVectors[MOVE.NONE]:copy()
		end
	})

	IControl2D = Trait:new({
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
			self.vector = self.vector * self.speed * dt
		end
	})

	IControl1DX = Trait:new({
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
			self.vector = self.vector * self.speed * dt
		end
	})

	IControl1DY = Trait:new({
		_move = function (self, m, dt)
			if m >= CONTROL.UP then
				m = m - CONTROL.UP
				self.vector = self.vector + moveVectors[CONTROL.UP]
			end
			if m >= CONTROL.DOWN then
				self.vector = self.vector + moveVectors[CONTROL.DOWN]
			end
			self.vector = self.vector * self.speed * dt
		end
	})
	-- END MOVE INTERFACES

	-- DRAW INTERFACES
	IADraw = Trait:new({
		draw = function (self)
			love.graphics.setColor(self.color or COLOR.DEFAULT)
			if self._draw then
				self:_draw()
			end
		end
	})

	IRect = Trait:new({
		_draw = function (self)
			local w = 100
			love.graphics.rectangle("line", self.x, self.y, w, w)
		end
	})
	-- END DRAW INTERFACES

	-- MAIN UTILITIES
	function pullControl()
		return (love.keyboard.isDown("up") and CONTROL.UP or 0) +
		(love.keyboard.isDown("down") and CONTROL.DOWN or 0) +
		(love.keyboard.isDown("left") and CONTROL.LEFT or 0) +
		(love.keyboard.isDown("right") and CONTROL.RIGHT or 0)
	end

	function _resolveCollision1 (o1, o2)
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

	function _resolveCollision2 (o1, o2)
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

	function _resolveCollision (o1, o2)
		return _resolveCollision1 (o1, o2)
	end

	function resolveCollisions (objects)
		for i = 1, (#objects - 1) do
			for j = i + 1, (#objects) do
				_resolveCollision(objects[i], objects[j])
			end
		end
	end
	-- END MAIN UTILITIES

	-- GAME CLASSES
	AGameUIObject = {
		new = new,
		x = 0,
		y = 0,
		w = 100,
		h = 100,
		speed = 100,
		vector = moveVectors[MOVE.NONE]:copy()
	} + IADraw

	ARect = AGameUIObject:new(IRect + IAControl)
	Rect2D = ARect:new(IControl2D)
	Rect1DX = ARect:new(IControl1DX)
	Rect1DY = ARect:new(IControl1DY)
	-- END GAME CLASSES

	-- GAME OBJECTS
	rect1 = Rect2D:new({
		x = 10,
		y = 10,
		speed = 120,
		priority = 3,
		color = COLOR.RED
	})
	rect2 = Rect2D:new({
		x = 120,
		y = 120,
		speed = 50,
		priority = 2,
		color = COLOR.GREEN
	})
	rect3 = Rect2D:new({
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
	for i, o in ipairs(mObjects) do
		o:move(move, dt)
	end

	resolveCollisions(mObjects)

	for i, o in ipairs(mObjects) do
		o:commit()
	end
end

function love.draw()
	for i, o in ipairs(mObjects) do
		o:draw()
	end
end

