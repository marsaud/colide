local love = love

local COLOR, _, _, _ = require("Const")()

local IADraw = {
  draw = function(self)
    love.graphics.setColor(self.color or COLOR.DEFAULT)
    if self._draw then
      self:_draw()
    end
  end,
}

local IRectLine = {
  _draw = function(self)
    love.graphics.rectangle("line", self.x, self.y, self.w, self.h)
  end,
}

local IRectFill = {
  _draw = function(self)
    love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
  end,
}

return function()
  return IADraw, IRectFill, IRectLine
end
