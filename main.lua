-- CONFORT TWEAKS
	local love = love
	table.unpack = unpack
-- END CONFORT TWEAKS
-- IMPORTS
	-- local debug = require("Debug")()
	require("math-ext")
	local _, Trait = require("POO")()
	local COLOR, _, MOVE = require("Const")()
	local
		moveVectors,
		IAMove,
		IMove,
		IMoveAuto,
		IMoveNot,
		IMoveX,
		IMoveY = require("Move")()
	local pullControl = require("Control")()
	local
		IACollide,
		ICollideBlocker,
		_,
		_,
		_,
		ICollidePusher = require("Collide")()
	local EVENT, EventManager, IEventCatcher = require("Event")()
	local _, _, _, Vector = require("Couple")()
-- END IMPORTS

-- DRAW INTERFACES
	local IADraw = Trait:new({
		draw = function (self)
			love.graphics.setColor(self.color or COLOR.DEFAULT)
			if self._draw then
				self:_draw()
			end
		end
	})

	local IRectLine = Trait:new({
		_draw = function (self)
			love.graphics.rectangle("line", self.x, self.y,self.w, self.h)
		end
	})
	local IRectFill = Trait:new({
		_draw = function (self)
			love.graphics.rectangle("fill", self.x, self.y,self.w, self.h)
		end
	})
-- END DRAW INTERFACES

--[[ GAME CLASSES

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

local AGameUIObject = IADraw .. IAMove .. IACollide .. IEventCatcher

local AutoMove = Trait:new({
	stateIndex = 1,
	stateTimer = 0,
	states = {
		moveVectors[MOVE.UP],
		moveVectors[MOVE.RIGHT],
		moveVectors[MOVE.DOWN],
		moveVectors[MOVE.LEFT],
	},
	getMove = function (self, _, _, dt)
		self.stateTimer = self.stateTimer + dt
		if self.stateTimer > 2 then
			self.stateTimer = 0
			self.stateIndex = self.stateIndex + 1
			if self.stateIndex > #self.states then
				self.stateIndex = 1
			end
		end
		return self.states[self.stateIndex]:copy()
	end
})

local AutoBounce = Trait:new({
	autoVector = moveVectors[MOVE.UP]:copy() + moveVectors[MOVE.RIGHT]:copy(),
	hit = function (self, vector)
		if vector then
			local x = self.autoVector.x
			if vector.x ~= 0 then
				x = x * math.sign(x) * math.sign(vector.x)
			end
			local y = self.autoVector.y
			if vector.y ~= 0 then
				y = y * math.sign(y) * math.sign(vector.y)
			end
			self.autoVector = Vector:new({
				x = x,
				y = y
			})
			return true
		else
			return false
		end
	end,
	getMove = function (self, _, _, _)
		return self.autoVector:copy()
	end
})

local mObjects

function love.load()
	local ARectLine = AGameUIObject:new(IRectLine)
	local ARectFill = AGameUIObject:new(IRectFill)
	local Rect2D = ARectLine:new(IMove .. ICollidePusher)
	local RectAuto = ARectLine:new(IMoveAuto .. ICollidePusher)
	local RectPassive = ARectLine:new (IMoveNot .. ICollidePusher)
	local Rect1DX = ARectLine:new(IMoveX .. ICollidePusher)
	local Rect1DY = ARectLine:new(IMoveY .. ICollidePusher)
	local RectStatic = ARectFill:new(IMoveNot .. ICollideBlocker .. ICollidePusher)

	-- GAME OBJECTS
	local function load()
		local rect1 = Rect2D:new({
			id = 'red',
			x = 25,
			y = 300,
			w = 50,
			h = 50,
			speed = 120,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.RED
		})
		local rect2 = Rect1DX:new({
			id = 'green',
			x = 125,
			y = 300,
			w = 140,
			h = 100,
			speed = 50,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.GREEN
		})
		local rect3 = Rect1DY:new({
			id = 'blue',
			x = 265,
			y = 300,
			w = 110,
			h = 25,
			speed = 40,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.BLUE
		})
		local rect4 = RectPassive:new({
			id = 'magenta',
			x = 385,
			y = 300,
			w = 40,
			h = 120,
			speed = 90,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.MAGENTA
		})
		local rect5 = RectAuto:new({
			id = 'yellow',
			x = 505,
			y = 300,
			w = 60,
			h = 90,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.YELLOW
		} .. AutoMove)
		local rect6 = RectStatic:new({
			id = 'cyan',
			x = 625,
			y = 300,
			w = 100,
			h = 100,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.CYAN
		})
		local rect7 = RectAuto:new({
			id = 'bouncer',
			x = 25,
			y = 400,
			w = 60,
			h = 90,
			speed = 240,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.ORANGE
		} .. AutoBounce)

		mObjects = {
			rect1,
			rect2,
			rect3,
			rect4,
			rect5,
			rect6,
			rect7,
			RectStatic:new({
				id = 'wall',
				x = 0,
				y = 0,
				w = 800,
				h = 3,
			}),
			RectStatic:new({
				id = 'wall',
				x = 0,
				y = 3,
				w = 3,
				h = 594,
			}),
			RectStatic:new({
				id = 'wall',
				x = 797,
				y = 3,
				w = 3,
				h = 594,
			}),
			RectStatic:new({
				id = 'wall',
				x = 0,
				y = 597,
				w = 800,
				h = 3,
			})
		}
	end

	local function load2()
		local rect1 = Rect2D:new({
			id = 'red',
			x = 10,
			y = 200,
			w = 50,
			h = 50,
			speed = 120,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.RED
		})
		local rect2 = RectPassive:new({
			id = 'green',
			x = 100,
			y = 200,
			w = 140,
			h = 100,
			speed = 50,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.GREEN
		})
		local rect3 = RectStatic:new({
			id = 'blue',
			x = 610,
			y = 200,
			w = 100,
			h = 100,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.CYAN
		})
		local rect4 = Rect2D:new({
			id = 'magenta',
			x = 10,
			y = 10,
			w = 50,
			h = 50,
			speed = 120,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.RED
		})
		local rect5 = RectPassive:new({
			id = 'yellow',
			x = 100,
			y = 10,
			w = 140,
			h = 100,
			speed = 50,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.GREEN
		})
		local rect6 = RectStatic:new({
			id = 'cyan',
			x = 610,
			y = 10,
			w = 100,
			h = 100,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.CYAN
		})

		mObjects = {
			rect1,
			rect2,
			rect3,
			rect4,
			rect5,
			rect6,
		}
	end

	load()
	-- END GAME OBJECTS
	local eventManager = EventManager:new()
	eventManager:addListener(EVENT.MOVE, table.unpack(mObjects))
	eventManager:addListener(EVENT.COMMIT, table.unpack(mObjects))
	eventManager:addListener(EVENT.HIT, table.unpack(mObjects))
end

local pause = false

function love.update(dt)
	if pause then return end
	local ctrl = pullControl()
	for _, o in ipairs(mObjects) do
		o:move(ctrl, dt)
	end
end

function love.draw()
	for _, o in ipairs(mObjects) do
		o:draw()
	end
end

function love.keypressed (key)
	if key == "p" then pause = not pause end
end

