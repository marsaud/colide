local Class = require("OOP")()
local IADraw, _IRectFill, _IRectLine, _rectangle = require("Draw")()
local _COLOR, _CONTROL, _EVENT, _MOVE, _PLUGIN, STYLE = require("Const")()

local SmallTextBlock = Class({
  _constructors = {
    SmallTextBlock = function(self)
      if not self.x then
        self.x = 0
      end
      if not self.y then
        self.y = 0
      end
      if not self.w then
        self.w = 200
      end
      if not self.h then
        self.h = 50
      end
      if not self.text then
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

  dataPush = function(self, key, value)
    if self.dataKey == key then
      self:print(value)
    end
  end,
}, IADraw)

return function()
  return SmallTextBlock
end
