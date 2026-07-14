local C = require("Const")
local COLOR, MOVE = C.COLOR, C.MOVE
local Utils = require("Utils")
local AGameUIObject = Utils.AGameUIObject
local Couple = require("Couple")
local Vector = Couple.Vector
local Draw = require("Draw")
local IRectFill, IRectLine = Draw.IRectFill, Draw.IRectLine
local Move = require("Move")
local moveVectors, IMove, IMoveX, IMoveY = Move.moveVectors, Move.IMove, Move.IMoveX, Move.IMoveY
local Collide = require("Collide")
local ICollideBlocker, ICollidePusher = Collide.ICollideBlocker, Collide.ICollidePusher
local Control = require("Control")
local IControlMove = Control.IControlMove
local Boy = require("demo/Boy").Boy
local SmallTextBlock = require("Components/SmallTextBlock").SmallTextBlock
local Data = require("Data")
local DataManager, IADataBroadcaster, IADataListener =
  Data.DataManager, Data.IADataBroadcaster, Data.IADataListener

local function test()
  love.graphics.setLineWidth(1)
  print(love.graphics.getLineStyle())
  love.graphics.setLineStyle("rough")

  local Rect2D = AGameUIObject:new(IControlMove, IMove, ICollidePusher, IRectLine)
  local RectPassive = AGameUIObject:new(ICollidePusher, IRectLine)
  local Rect1DX = AGameUIObject:new(IControlMove, IMoveX, ICollidePusher, IRectLine)
  local Rect1DY = AGameUIObject:new(IControlMove, IMoveY, ICollidePusher, IRectLine)
  local RectStatic = AGameUIObject:new(ICollideBlocker, IRectFill)
  local BlockerBoy = AGameUIObject:new(IControlMove, IMove, ICollidePusher, Boy)

  local dataManager = DataManager:new()

  local DATA_KEY = "abcdef"

  local rect1 = Rect2D:new({
    id = "red",
    x = 600,
    y = 100,
    w = 20,
    h = 20,
    speed = 12,
    vector = moveVectors[MOVE.NONE]:copy(),
    color = COLOR.RED,
    _getData = function(self, key)
      if key ~= DATA_KEY then
        error("UNKNOWN DATA KEY")
      end
      return self:c().x .. ", " .. self:c().y .. "\n" .. self._c.x .. ", " .. self._c.y
    end,
    _getKeys = function(self)
      return { DATA_KEY }
    end,
  }, IADataBroadcaster)

  local textBlock = SmallTextBlock:new({
    x = 500,
    y = 5,
    w = 200,
    h = 45,
    _getKeys = function(self)
      return { DATA_KEY }
    end,
    _pushData = function(self, value, key)
      if key ~= DATA_KEY then
        error("UNKNOWN DATA KEY")
      end
      self:print(value)
    end,
  }, IADataListener)

  dataManager:register(rect1)
  dataManager:subscribe(textBlock)

  local objects = {
    dataManager,
    rect1,
    -- rect2,
    -- rect3,
    -- rect4,
    -- rect5,
    -- rect6,
    -- rect7,
    -- boy,
    textBlock,
    RectStatic:new({
      id = "ceil",
      x = 0,
      y = 50,
      w = 800,
      h = 5,
      color = COLOR.BLUE,
    }),
    RectStatic:new({
      id = "left",
      x = 0,
      y = 55,
      w = 5,
      h = 540,
    }),
    RectStatic:new({
      id = "right",
      x = 795,
      y = 55,
      w = 5,
      h = 540,
    }),
    RectStatic:new({
      id = "floor",
      x = 0,
      y = 595,
      w = 800,
      h = 5,
      color = COLOR.BLUE,
    }),
  }

  local colorMap = {
    COLOR.MAGENTA,
    COLOR.GREEN,
  }
  local color = 1
  local altColor = function()
    color = color + 1
    return colorMap[1 + (color % 2)]
  end

  -- Movabel Boxes
  for i = 0, 3 do
    local r = RectPassive:new({
      id = "magenta",
      x = 100 + i * 50,
      y = 200,
      w = 45,
      h = 35,
      color = altColor(),
      _getData = function(self, key)
        if key ~= DATA_KEY .. i then
          error("UNKNOWN DATA KEY")
        end
        return self:c().x .. ", " .. self:c().y .. "\n" .. self._c.x .. ", " .. self._c.y
      end,
      _getKeys = function(self)
        return { DATA_KEY .. i }
      end,
    }, IADataBroadcaster)
    dataManager:register(r)
    table.insert(objects, r)
    local tb = SmallTextBlock:new({
      x = 100 + i * 100,
      y = 5,
      w = 105,
      h = 45,
      _getKeys = function(self)
        return { DATA_KEY .. i }
      end,
      _pushData = function(self, value, key)
        if key ~= DATA_KEY .. i then
          error("UNKNOWN DATA KEY")
        end
        self:print(value)
      end,
    }, IADataListener)
    dataManager:subscribe(tb)
    table.insert(objects, tb)
  end

  -- rulers
  for j = 0, 19 do
    table.insert(
      objects,
      RectStatic:new({
        id = "block",
        x = 700,
        y = 300 + j,
        w = 5,
        h = 1,
        color = altColor(),
      })
    )
    table.insert(
      objects,
      RectStatic:new({
        id = "block",
        x = 705,
        y = 300 + j * 2,
        w = 5,
        h = 2,
        color = altColor(),
      })
    )
    table.insert(
      objects,
      RectStatic:new({
        id = "block",
        x = 710,
        y = 300 + j * 5,
        w = 5,
        h = 5,
        color = altColor(),
      })
    )
  end

  -- dot ruler
  for k = 0, 19 do
    table.insert(
      objects,
      RectStatic:new({
        id = "dot",
        x = 700 + k,
        y = 100,
        w = 1,
        h = 1,
        color = altColor(),
      })
    )
  end

  for l = 0, 4 do
    table.insert(
      objects,
      RectStatic:new({
        id = "block",
        x = 100 + l * 100,
        y = 400,
        w = l + 1,
        h = l + 1,
      })
    )
  end

  table.insert(
    objects,
    RectPassive:new({
      id = "test",
      x = 0,
      y = 0,
      w = 10,
      h = 10,
    })
  )

  return objects
end

return test
