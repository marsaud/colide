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
local contextIndex
local currentContextIndex

local fullScreen
local currentFullScreen = fullScreen
local gameWidth = 800
local gameHeight = 600
local scale = 1
local offsetX = 0
local offsetY = 0

local pause


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

  contextIndex = 1
  pause = false
  fullScreen = false
end

function love.update(dt)
  currentContextIndex = contextIndex
  if pause then
    return
  end
  contexts[currentContextIndex]:tick(dt)
  contexts[currentContextIndex]:flush()
end

function love.draw()
  if currentFullScreen ~= fullScreen then
    currentFullScreen = fullScreen
      if currentFullScreen then
        local _, _, flags = love.window.getMode()
        local display = flags.display
        local screenW, screenH = love.window.getDesktopDimensions(display)
        scale = math.floor(math.min(screenW / gameWidth, screenH / gameHeight))
        offsetX = (screenW - gameWidth * scale) / 2
        offsetY = (screenH - gameHeight * scale) / 2
      else
        scale = 1
        offsetX = 0
        offsetY = 0
      end
      love.window.setFullscreen(fullScreen)
  end

  if currentFullScreen then
    love.graphics.push()
    love.graphics.translate(offsetX, offsetY)
    love.graphics.scale(scale, scale)
  end

  contexts[currentContextIndex]:draw()

  if currentFullScreen then
    love.graphics.pop()
  end
end

function love.keypressed(key)
  if key == "f" then
    fullScreen = not fullScreen
  end
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
