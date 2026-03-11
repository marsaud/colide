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

return function () return
	pullControl, testControl
end