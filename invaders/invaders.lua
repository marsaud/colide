local _, ICollideBlocker, _, _, _, ICollidePusher = require("Collide")()
local COLOR, CONTROL, _, MOVE = require("Const")()
local _, testControl = require("Control")()
local _, IRectFill, IRectLine = require("Draw")()
local moveVectors, _, _, _, IMoveX, _ = require("Move")()
local AGameUIObject = require("Utils")()
local _, _, _, IControlMove = require("Control")()

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

  for x = 20, 620, 50 do
    for y = 50, 300, 50 do
      table.insert(
        objects,
        AGameUIObject:new({
          id = "vessel",
          x = x,
          y = y,
          w = 40,
          h = 40,
          health = 100,
          speed = 10,
          vector = moveVectors[MOVE.NONE]:copy(),
          _getDamage = function(_, _)
            return 100
          end,
        }, IControlMove, ICollidePusher, IRectLine, Vessel)
      )
    end
  end

  local Missile = AGameUIObject:new({
    _getDamage = function(_, _)
      return 100
    end,
    _move = function(id, _, _, _)
      return moveVectors[MOVE.UP]
    end,
  }, IControlMove, ICollidePusher)

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
          }, IRectFill)
          self.eventManager:addObjects(missile)
          self._SHIP_FIRE_DELAY = 0.3
        end
      end
    end
  end

  local Ship = AGameUIObject:new(IControlMove, IMoveX, ICollidePusher)
  Ship:addPlugin("_control", shipFire)
  local ship = Ship:new({
    id = "ship",
    x = 400,
    y = 550,
    w = 40,
    h = 40,
    speed = 300,
    vector = moveVectors[MOVE.NONE]:copy(),
  }, IRectLine)

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
