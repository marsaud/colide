-- CONFORT TWEAKS
	local love = love
	table.unpack = unpack
-- END CONFORT TWEAKS
-- IMPORTS
	-- local debug = require("Debug")()
	require("math-ext")
	local Class = require("POO")()
	local COLOR, CONTROL, _, MOVE = require("Const")()
	local
		moveVectors,
		IAMove,
		IMove,
		IMoveNot,
		IMoveX,
		IMoveY = require("Move")()
	local
		IACollide,
		ICollideBlocker,
		_,
		_,
		_,
		ICollidePusher = require("Collide")()
	local EventManager, IEventCatcher = require("Event")()
	local _, _, Point, Vector = require("Couple")()
-- END IMPORTS

-- DRAW INTERFACES
	local IADraw = {
		draw = function (self)
			love.graphics.setColor(self.color or COLOR.DEFAULT)
			if self._draw then
				self:_draw()
			end
		end
	}

	local IRectLine = {
		_draw = function (self)
			love.graphics.rectangle("line", self.x, self.y,self.w, self.h)
		end
	}

	local IRectFill = {
		_draw = function (self)
			love.graphics.rectangle("fill", self.x, self.y,self.w, self.h)
		end
	}
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

	IAMove:control
	IAMove:move
		_move
		IMoveAuto:getMove
	resolve _resolve
	commit _commit
	hit _hit getHit

--]]

local PluginManager = {
	_initPluginManager = function (self)
		if self._pluginManagerInit then return end
		self._plugins = {}
		self._pluginManagerInit = true
	end,
	addPlugin = function (self, id, func)
		self:_initPluginManager()
		if not self._plugins[id] then
			self._plugins[id] = {}
		end
		table.insert(self._plugins[id], func)
	end,
	runPlugins = function (self, id, ...)
		self:_initPluginManager()
		for _, func in ipairs(self._plugins[id] or {}) do
			func(...)
		end
	end
}

local AGameUIObject = Class(IADraw, IAMove, IACollide, IEventCatcher, PluginManager)

local AutoMove = {
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
}

local AutoBounce = {
	autoVector = moveVectors[MOVE.UP]:copy() + moveVectors[MOVE.RIGHT]:copy(),
	_hit = function (self, _, _, vector)
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
}

local ICollapse = {
	_hit = function (self, who, by, _)
		local damage = by.getHit and by:getHit(who) or 0
		self.health = self.health - damage
		if self.health <= 0 and self.eventManager then
			self.eventManager:delete(self)
		end
	end
}

local contexts = {}
local pause
local contextIndex

function love.load()
	local Rect2D = AGameUIObject:new(IMove, ICollidePusher)
	local RectPassive = AGameUIObject:new (IMoveNot, ICollidePusher)
	local Rect1DX = AGameUIObject:new(IMoveX, ICollidePusher)
	local Rect1DY = AGameUIObject:new(IMoveY, ICollidePusher)
	local RectStatic = AGameUIObject:new(IMoveNot, ICollideBlocker, ICollidePusher, IRectFill)

	local boots = {}

	table.insert(boots, function ()
		local rect1 = Rect2D:new({
			id = 'red',
			x = 25,
			y = 300,
			w = 50,
			h = 50,
			speed = 120,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.RED
		}, IRectLine)
		local rect2 = Rect1DX:new({
			id = 'green',
			x = 125,
			y = 300,
			w = 140,
			h = 100,
			speed = 50,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.GREEN
		}, IRectLine)
		local rect3 = Rect1DY:new({
			id = 'blue',
			x = 265,
			y = 300,
			w = 110,
			h = 25,
			speed = 40,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.BLUE
		}, IRectLine)
		local rect4 = RectPassive:new({
			id = 'magenta',
			x = 385,
			y = 300,
			w = 40,
			h = 120,
			speed = 90,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.MAGENTA
		}, IRectLine)
		local rect5 = Rect2D:new({
			id = 'yellow',
			x = 505,
			y = 300,
			w = 60,
			h = 90,
			speed = 110,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.YELLOW
		}, AutoMove, IRectLine)
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
		local rect7 = Rect2D:new({
			id = 'bouncer',
			x = 25,
			y = 400,
			w = 60,
			h = 90,
			speed = 240,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.ORANGE
		}, AutoBounce, IRectLine)

		local objects = {
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

		return objects
	end)

	table.insert(boots, function ()
		local Bat = AGameUIObject:new(IMoveX, ICollideBlocker, ICollidePusher)
		local Brick = AGameUIObject:new(IMoveNot, ICollideBlocker, ICollapse, IRectFill)
		local Ball = Rect2D:new(AutoBounce, IRectLine, ICollapse,
		{
			getHit = function (_, _) return 50 end
		})

		local bat = Bat:new({
			id = 'bat',
			x = 200,
			y = 580,
			w = 150,
			h = 10,
			speed = 400,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.CYAN
		}, IRectLine)

		local ball = Ball:new({
			id = 'ball',
			x = 400,
			y = 300,
			w = 10,
			h = 10,
			health = 100,
			speed = 240,
			vector = moveVectors[MOVE.NONE]:copy(),
			color = COLOR.YELLOW
		}, AutoBounce, IRectLine)

		ball:addPlugin('_hit', ICollapse._hit)

		local objects = {
			bat,
			ball,
			RectStatic:new({
				id = 'ceil',
				x = 0,
				y = 0,
				w = 800,
				h = 3,
			}),
			RectStatic:new({
				id = 'left',
				x = 0,
				y = 3,
				w = 3,
				h = 597,
			}),
			RectStatic:new({
				id = 'right',
				x = 797,
				y = 3,
				w = 3,
				h = 597,
			}),
			RectStatic:new({
				id = 'floor',
				x = 3,
				y = 597,
				w = 794,
				h = 3,
				color = COLOR.RED,
				getHit = function (_, who)
					if (who and who.id == 'ball') then
						return 100
					end
				end
			}),
		}
		for x = 50, 700, 50 do
			for y = 10, 210, 40 do
				table.insert(objects, Brick:new({
					id = 'brick',
					health = 50,
					x = x,
					y = y,
					w = 45,
					h = 35
				}))
			end
		end

		return objects
	end)

	table.insert(boots, function ()
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
				table.insert(objects, Rect2D:new({
					id = 'vessel',
					x = x,
					y = y,
					w = 40,
					h = 40,
					health = 100,
					speed = 10,
					vector = moveVectors[MOVE.NONE]:copy(),
					getHit = function (_, _) return 100 end,
				}, IRectLine, ICollapse, Vessel))
			end
		end

		local Missile = Rect1DY:new({
			getHit = function (_, _) return 100 end,
			getMove = function () return moveVectors[MOVE.UP] end
		}, ICollapse)

		local shipFire = function (self, ctrl, dt)
			if ctrl >= CONTROL.ACT3 then ctrl = ctrl - CONTROL.ACT3 end
			if ctrl >= CONTROL.ACT2 then ctrl = ctrl - CONTROL.ACT2 end
			if ctrl >= CONTROL.ACT1 then
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
	end)

	for _, b in ipairs(boots) do
		local c = EventManager:new()
		c:addObjects(table.unpack(b()))
		table.insert(contexts, c)
	end

	contextIndex = #contexts
	pause = false
end

local currentContextIndex

function love.update(dt)
	currentContextIndex = contextIndex
	if pause then return end
	contexts[currentContextIndex]:tick(dt)
	contexts[currentContextIndex]:purge()
end

function love.draw()
	for _, o in ipairs(contexts[currentContextIndex]:getObjects()) do
		o:draw()
	end
end

function love.keypressed (key)
	if key == "p" then pause = not pause end
	if key == "c" then contextIndex = contextIndex + 1 end
	if contextIndex > #contexts then contextIndex = 1 end
end
