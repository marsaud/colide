-- CONFORT TWEAKS
require("workHelpers")
local love = love
-- END CONFORT TWEAKS

-- IMPORTS
-- local debug = require("Debug")()
local EventManager, _ = require("Event")()
-- END IMPORTS

--[[ GAME CLASSES

	An object may have interfaces:
	- Draw(able)
		- Anim(able)
	- Move(able)
		- Control(able)
		- Auto(matable)
	- Collide
		- Harm(able)

	An object may have properties:
	- box (Coord, Size)
	- move (Vector)
	- auto (callback)
	- anim (callback)
	- collide (callback), life, strength

	IAMove:control
	IAMove:move
		_move
		IMoveAuto:getMove
	resolve _resolve
	commit _commit
	hit _hit getHit

--]]

local contexts = {}
local pause
local contextIndex

function love.load()
  local boots = {}

  local demo = require("demo/demo")
  table.insert(boots, demo)

  local bricks = require("bricks/bricks")
  table.insert(boots, bricks)

  local invaders = require("invaders/invaders")
  table.insert(boots, invaders)

  local groupDemo = require("groupDemo/groupDemo")
  table.insert(boots, groupDemo)

  for _, b in ipairs(boots) do
    local c = EventManager:new()
    c:addObjects(table.unpack(b()))
    table.insert(contexts, c)
  end

  contextIndex = #contexts
  pause = false
end

local currentContextIndex

function love.update(dt)
  currentContextIndex = contextIndex
  if pause then
    return
  end
  contexts[currentContextIndex]:tick(dt)
  contexts[currentContextIndex]:purge()
end

function love.draw()
  contexts[currentContextIndex]:draw()
end

function love.keypressed(key)
  if key == "p" then
    pause = not pause
  end
  if key == "r" then
    love.event.quit("restart")
  end
  if key == "escape" then
    love.event.quit(0)
  end

  if key == "c" then
    contextIndex = contextIndex + 1
  end
  if contextIndex > #contexts then
    contextIndex = 1
  end
end
