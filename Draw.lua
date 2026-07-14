local love = love

local L = require("lib")
local C = require("Const")
local COLOR, STYLE = C.COLOR, C.STYLE

local IADraw = {
  draw = function(self)
    if L.f(self._draw) then
      love.graphics.setColor(self.color or COLOR.DEFAULT)
      self:_draw()
    end
  end,
}

local rectangle = function(o, style)
  local c
  if o.c then
    c = o:c()
  else
    c = o
  end
  if style == STYLE.FILL then
    love.graphics.rectangle(style, c.x, c.y, o.w, o.h)
  else
    love.graphics.rectangle(style, c.x + 0.5, c.y + 0.5, o.w - 1, o.h - 1)
  end
end

local IRectLine = {
  _draw = function(self)
    rectangle(self, STYLE.LINE)
  end,
}

local IRectFill = {
  _draw = function(self)
    rectangle(self, STYLE.FILL)
  end,
}

return {
  IADraw = IADraw,
  IRectFill = IRectFill,
  IRectLine = IRectLine,
  rectangle = rectangle,
}
