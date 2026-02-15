-- IMPORTS
	require("math-ext")
	local _, Trait = require("POO")()
	local COLOR, _, MOVE = require("Const")()
	local moveVectors, IAMove, IMove, IMoveNot, IMoveX, IMoveY = require("Move")()
	local pullControl = require("Control")()
	local
		IACollide,
		ICollideBlocker,
		_,
		_,
		_,
		ICollidePusher = require("Collide")()
	local EVENT, EventManager, IEventCatcher = require("Event")()
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

	local IRect = Trait:new({
		_draw = function (self)
			love.graphics.rectangle("line", self.x, self.y,self.w, self.h)
		end
	})
-- END DRAW INTERFACES

-- MAIN UTILITIES
	local function resolveCollisions (objects)
		for i = 1, (#objects) do
			if (objects[i].IACollide) then
				objects[i]:process(objects)
			end
		end
		for _, o in ipairs(objects) do
			if (o.IACollide) then
				o:flushCollisionStates()
			end
		end
	end
-- END MAIN UTILITIES

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

local mObjects

function love.load()
	local ARect = AGameUIObject:new(IRect)
	local Rect2D = ARect:new(IMove .. ICollidePusher)
	local RectPassive = ARect:new (IMoveNot .. ICollidePusher)
	local Rect1DX = ARect:new(IMoveX .. ICollidePusher)
	local Rect1DY = ARect:new(IMoveY .. ICollidePusher)
	local RectStatic = ARect:new(IMoveNot .. ICollideBlocker .. ICollidePusher)
	-- END GAME CLASSES

	-- GAME OBJECTS
	local function load()
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
		local rect2 = Rect1DX:new({
			id = 'green',
			x = 100,
			y = 200,
			w = 140,
			h = 100,
			speed = 50,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.GREEN
		})
		local rect3 = Rect1DY:new({
			id = 'blue',
			x = 250,
			y = 200,
			w = 110,
			h = 25,
			speed = 40,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.BLUE
		})
		local rect4 = RectPassive:new({
			id = 'magenta',
			x = 370,
			y = 200,
			w = 40,
			h = 120,
			speed = 90,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.MAGENTA
		})
		local rect5 = RectPassive:new({
			id = 'yellow',
			x = 490,
			y = 200,
			w = 60,
			h = 90,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.YELLOW
		})
		local rect6 = RectStatic:new({
			id = 'cyan',
			x = 610,
			y = 200,
			w = 100,
			h = 100,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.CYAN
		})

		mObjects = {
			---[[
			rect1,
			rect2,
			rect3,
			rect4,
			rect5,
			rect6,
			--]]
		}

		local eventManager = EventManager:new()
		eventManager:addListener(EVENT.MOVE, rect1, rect2, rect3, rect4, rect5, rect6)
	end

	load()
	-- END GAME OBJECTS
end

function love.update(dt)
	local ctrl = pullControl()
	for _, o in ipairs(mObjects) do
		o:move(ctrl, dt)
	end

	-- resolveCollisions(mObjects)

	for _, o in ipairs(mObjects) do
		o:commit()
	end
end

function love.draw()
	for _, o in ipairs(mObjects) do
		o:draw()
	end
end

