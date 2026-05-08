local love = love

local COLOR, _, _, _ = require("Const")()

local IADraw = {
  draw = function(self)
    if self._draw then
      love.graphics.setColor(self.color or COLOR.DEFAULT)
      self:_draw()
    end
  end,
}

local _rectDraw = function(o, style)
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
    _rectDraw(self, "line")
  end,
}

local IRectFill = {
  _draw = function(self)
    _rectDraw(self, "fill")
  end,
}

return function()
  return IADraw, IRectFill, IRectLine
end
