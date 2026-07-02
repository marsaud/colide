local L = require("lib")
local OOP = require("OOP")
local Class = OOP.Class
local Draw = require("Draw")
local IADraw = Draw.IADraw
local C = require("Const")
local STYLE = C.STYLE

local SmallTextBlock = Class({
  _constructors = {
    SmallTextBlock = function(self)
      if not L.x(self.x) then
        self.x = 0
      end
      if not L.x(self.y) then
        self.y = 0
      end
      if not L.x(self.w) then
        self.w = 200
      end
      if not L.x(self.h) then
        self.h = 50
      end
      if not L.x(self.text) then
        self.text = ""
      end
    end,
  },

  print = function(self, text)
    self.text = text
  end,

  clean = function(self)
    self:print("")
  end,

  _draw = function(self)
    love.graphics.rectangle(STYLE.LINE, self.x, self.y, self.w, self.h)
    love.graphics.print(self.text, self.x + 5, self.y + 5)
  end,

  pushData = function(self, key, value)
    if self.dataKey == key then
      self:print(value)
    end
  end,
}, IADraw)

return {
  SmallTextBlock = SmallTextBlock,
}
