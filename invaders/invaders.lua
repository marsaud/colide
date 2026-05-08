local Collide = require("Collide")
local ICollideBlocker, ICollidePusher = Collide.ICollideBlocker, Collide.ICollidePusher
local C = require("Const")
local COLOR, CONTROL, MOVE = C.COLOR, C.CONTROL, C.MOVE
local Control = require("Control")
local testControl, IAControl, IControlMove =
  Control.testControl, Control.IAControl, Control.IControlMove
local Draw = require("Draw")
local IRectFill, IRectLine = Draw.IRectFill, Draw.IRectLine
local Move = require("Move")
local moveVectors, IMoveX = Move.moveVectors, Move.IMoveX
local Utils = require("Utils")
local AGameUIObject = Utils.AGameUIObject
local Hit = require("Hit")
local IAHit = Hit.IAHit

local function invaders()
  local Vessel = {
    vesselStateIndex = 1,
    vesselStates = {
      MOVE.RIGHT,
      MOVE.DOWN,
      MOVE.LEFT,
      MOVE.DOWN,
    },
    _move = function(self, id, _, _)
      local c = self:c()
      if not self.vesselOrigin then
        self.vesselOrigin = c
      end
      if self.vesselStateIndex == 1 then
        local delta = c.x - self.vesselOrigin.x
        if delta >= 100 then
          self.vesselStateIndex = 2
        end
      elseif self.vesselStateIndex == 2 then
        local delta = c.y - self.vesselOrigin.y
        if delta >= 50 then
          self.vesselStateIndex = 3
        end
      elseif self.vesselStateIndex == 3 then
        local delta = c.x - self.vesselOrigin.x
        if delta <= 0 then
          self.vesselStateIndex = 4
        end
      elseif self.vesselStateIndex == 4 then
        local delta = c.y - self.vesselOrigin.y
        if delta >= 100 then
          self.vesselStateIndex = 1
          self.vesselOrigin = c
        end
      end
      return moveVectors[self.vesselStates[self.vesselStateIndex]]:copy()
    end,
  }

  local objects = {}

  local fleat = {}
  for x = 1, 13 do
    fleat[x] = {}
    for y = 1, 6 do
      local vessel = AGameUIObject:new({
        id = "vessel",
        x = (x - 1) * 50 + 20,
        y = (y - 1) * 50 + 50,
        w = 40,
        h = 40,
        px = x,
        py = y,
        health = 100,
        speed = 10,
        vector = moveVectors[MOVE.NONE]:copy(),
        _getDamage = function(_, _)
          return 100
        end,
      }, IAHit, IControlMove, ICollidePusher, IRectLine, Vessel)
      vessel:addPlugin("_hit", function(self, _, _, _)
        if self.health <= 0 then
          table.remove(fleat[self.px], self.py)
          if #fleat[self.px] then
            table.remove(fleat, self.px) -- BUG this invalidates px values
          end
        end
      end)
      table.insert(objects, vessel)
      fleat[x][y] = vessel
    end
  end

  -- for i, v in ipairs(fleat) do
  -- 	for j, _ in ipairs(v) do
  -- 		local vessel =  AGameUIObject:new({
  -- 			id = 'vessel',
  -- 			x = (i - 1) * 50 + 20,
  -- 			y = (j - 1) * 50 + 50,
  -- 			w = 40,
  -- 			h = 40,
  -- 			px = i,
  -- 			py = j,
  -- 			health = 100,
  -- 			speed = 10,
  -- 			vector = moveVectors[MOVE.NONE]:copy(),
  -- 			getHit = function (_, _) return 100 end,
  -- 		}, IMove, ICollidePusher, IRectLine, ICollapse, Vessel)
  -- 		vessel:addPlugin(
  -- 			'_hit',
  -- 			function (self, _, _, _)
  -- 				if self.health <= 0 then
  -- 					fleat[self.px][self.py] = false
  -- 				end
  -- 			end
  -- 		)
  -- 		table.insert(objects, vessel)
  -- 	end
  -- end

  local Bomb = AGameUIObject:new({
    _getDamage = function(_, _)
      return 100
    end,
    _move = function(id, _, _, _)
      return moveVectors[MOVE.DOWN]
    end,
  }, IControlMove, ICollidePusher, IAHit, IRectFill)

  local vesselFire = function(self, _, dt)
    if self.eventManager then
      if not self._VESSEL_FIRE_DELAY then
        math.randomseed(os.time())
        self._VESSEL_FIRE_DELAY = 2
        return
      else
        if self._VESSEL_FIRE_DELAY and self._VESSEL_FIRE_DELAY >= 0 then
          self._VESSEL_FIRE_DELAY = self._VESSEL_FIRE_DELAY - dt
        else
          local vessel
          while not vessel do
            local randX = math.floor(math.random(#fleat + 1))
            if randX == #fleat + 1 then
              randX = #fleat
            end
            vessel = fleat[randX][#fleat[randX]]
          end
          local bomb = Bomb:new({
            id = "bomb",
            x = vessel.x + 18,
            y = vessel.y + 50,
            w = 4,
            h = 10,
            speed = 50,
            vector = moveVectors[MOVE.NONE]:copy(),
            health = 100,
          })
          self.eventManager:addObjects(bomb)
          self._VESSEL_FIRE_DELAY = 2
        end
      end
    end
  end

  table.insert(objects, { id = "vesselFire", IAControl, _control = vesselFire })

  local Missile = AGameUIObject:new({
    _getDamage = function(_, _)
      return 100
    end,
    _move = function(id, _, _, _)
      return moveVectors[MOVE.UP]
    end,
  }, IControlMove, ICollidePusher, IRectFill)

  local shipFire = function(self, ctrl, dt)
    if testControl(ctrl, CONTROL.ACT1) then
      if self.eventManager then
        if self._SHIP_FIRE_DELAY and self._SHIP_FIRE_DELAY >= 0 then
          self._SHIP_FIRE_DELAY = self._SHIP_FIRE_DELAY - dt
        else
          local c = self:c()
          local missile = Missile:new({
            id = "missile",
            x = c.x + 18,
            y = c.y - 10,
            w = 4,
            h = 10,
            speed = 50,
            vector = moveVectors[MOVE.NONE]:copy(),
            health = 100,
          })
          self.eventManager:addObjects(missile)
          self._SHIP_FIRE_DELAY = 0.3
        end
      end
    end
  end

  local Ship = AGameUIObject:new(IMoveX, ICollidePusher, IRectLine)
  Ship:addPlugin("_control", shipFire)
  local ship = Ship:new({
    id = "ship",
    x = 400,
    y = 550,
    w = 40,
    h = 40,
    speed = 300,
    vector = moveVectors[MOVE.NONE]:copy(),
  })

  table.insert(objects, ship)

  local RectStatic = AGameUIObject:new(ICollideBlocker, IRectFill)
  table.insert(
    objects,
    RectStatic:new({
      id = "ceil",
      x = 0,
      y = 0,
      w = 800,
      h = 3,
      color = COLOR.RED,
      _getDamage = function(_, target)
        if target and target.id == "missile" then
          return 100
        end
      end,
    })
  )

  return objects
end

return invaders
