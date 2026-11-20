package.path = "lib/?.lua;lib/?/init.lua;assets/?.lua;" .. package.path

-- CONFORT TWEAKS
require("workHelpers")
local love = love
-- END CONFORT TWEAKS

-- IMPORTS
-- local debug = require("Debug").debug
local EventManager = require("Event").EventManager
local speedFactor = require("Move").speedFactor
local Control = require("Control")
local KeyboardController = Control.KeyboardController
local DispatchController = Control.DispatchController
local ClientControllerWrapper = Control.ClientControllerWrapper
local defaultKeyMaps = Control.defaultKeyMaps
local Client = require("network.client").Client
local unserialize = require("Serializable").unserialize
-- END IMPORTS

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

local objectReader = {
  open = function(self, state)
    self._state = state
  end,
  read = function(self)
    if self._state == "" then
      return nil
    end
    local newObject
    local separator = self._state:find("%", 1, true)
    if not separator then
      newObject = self._state
      self._state = ""
    else
      newObject = self._state:sub(1, separator - 1)
      self._state = self._state:sub(separator + 1)
    end
    return newObject
  end,
}

local pause
local client = Client:new()

function love.load()
  local boots = {}

  local demo = require("demo")
  table.insert(boots, demo)

  local kc = KeyboardController:new()
  local kc2 = KeyboardController:new({ channel = "boy2", map = defaultKeyMaps[2] })
  local dc = DispatchController:new()
  dc:addController(kc):addController(kc2)

  local controller = ClientControllerWrapper:new({
    controller = dc,
    client = client,
  })

  for _, b in ipairs(boots) do
    local c = EventManager:new({
      controller = controller,
      keyMap = {
        _uid_ = true,
        h = true,
        w = true,
        _c = true,
        x = true,
        y = true,
        _health = true,
      },
    })
    c:addObjects(table.unpack(b()))
    table.insert(contexts, c)
    client:connect()
  end

  contextIndex = 1
  pause = false
  fullScreen = false

  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")
end

function love.update(dt)
  currentContextIndex = contextIndex
  if pause then
    return
  end
  local context = contexts[currentContextIndex]
  context:tick(dt, true):flush()

  client:update()
  local gameState = client:poll()
  while gameState ~= nil do
    objectReader:open(gameState)
    local object = objectReader:read()
    while object ~= nil do
      local o = unserialize(object)
      context:updateObject(o)
      object = objectReader:read()
    end
    gameState = client:poll()
  end
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
  if key == "*" then
    speedFactor(true)
  end
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
