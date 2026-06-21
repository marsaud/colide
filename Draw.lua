local love = love

local C = require("Const")
local COLOR, STYLE = C.COLOR, C.STYLE

local IADraw = {
  draw = function(self)
    if self._draw then
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
  love.graphics.rectangle(style, c.x, c.y, o.w, o.h)
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
