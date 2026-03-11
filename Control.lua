local love = love
local bit = bit
-- IMPORTS
local _, CONTROL, _, _ = require("Const")()
-- END IMPORTS

local function pullControl()
	return
	(love.keyboard.isDown("space") and CONTROL.ACT1 or 0) +
	(love.keyboard.isDown("up") and CONTROL.UP or 0) +
	(love.keyboard.isDown("down") and CONTROL.DOWN or 0) +
	(love.keyboard.isDown("left") and CONTROL.LEFT or 0) +
	(love.keyboard.isDown("right") and CONTROL.RIGHT or 0)
end

local function testControl(state, value)
	return bit.band(state, value) ~= 0
end

local IAControl = {
	control = function (self, ctrl, dt)
		if self.runPlugins then
			self:runPlugins('_control', self, ctrl, dt)
		end
		if self._control then
			return self:_control(ctrl, dt)
		end
	end
}

return function () return
	pullControl, testControl, IAControl
end