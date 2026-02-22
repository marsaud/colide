local love = love
-- IMPORTS
local _, CONTROL, EVENT, _ = require("Const")()
-- END IMPORTS

local function pullControl(eventManager, dt)
	local ctrlState =
	(love.keyboard.isDown("space") and CONTROL.ACT1 or 0) +
	(love.keyboard.isDown("up") and CONTROL.UP or 0) +
	(love.keyboard.isDown("down") and CONTROL.DOWN or 0) +
	(love.keyboard.isDown("left") and CONTROL.LEFT or 0) +
	(love.keyboard.isDown("right") and CONTROL.RIGHT or 0)
	eventManager:fire(EVENT.CONTROL, ctrlState, dt)
end

return function () return
	pullControl
end