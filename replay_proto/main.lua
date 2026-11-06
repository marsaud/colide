package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

-- CONFORT TWEAKS
require("workHelpers")
local love = love
-- END CONFORT TWEAKS

-- IMPORTS
-- local debug = require("Debug").debug
require("math-ext")
local unserialize = require("Serializable").unserialize
local D = require("Draw")
local IRectLine = D.IRectLine
-- END IMPORTS

local fullScreen
local currentFullScreen = fullScreen
local gameWidth = 800
local gameHeight = 600
local scale = 1
local offsetX = 0
local offsetY = 0

local stateReader = {
  open = function(self, path)
    local file = io.open(path, "rb")
    if file == nil then
      error("File not found")
    end
    self.content = file:read("*a")
    file:close()
  end,
  read = function(self)
    if self.content == "" then
      return nil
    end
    local newLine
    local separator = self.content:find("\n")
    if not separator then
      newLine = self.content
      self.content = ""
    else
      newLine = self.content:sub(1, separator - 1)
      self.content = self.content:sub(separator + 1)
    end
    return newLine
  end,
}

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

local state
local objects = {}

local path = "../stateDiff"

function love.load()
  fullScreen = false

  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")

  stateReader:open(path)
  state = stateReader:read()

  if state == nil then
    love.event.quit(0)
  else
    objectReader:open(state)
    local object = objectReader:read()
    while object ~= nil do
      local o = unserialize(object)
      o.draw = IRectLine._draw
      o.c = function(self)
        return { x = math.round(self._c.x), y = math.round(self._c.y) }
      end
      objects[o._uid_] = o
      object = objectReader:read()
    end
  end
end

function love.update(dt)
  state = stateReader:read()
  if state == nil then
    stateReader:open(path)
    state = stateReader:read()
  end
  if state ~= nil then
    objectReader:open(state)
    local object = objectReader:read()
    while object ~= nil do
      local o = unserialize(object)
      o.draw = IRectLine._draw
      o.c = function(self)
        return { x = math.round(self._c.x), y = math.round(self._c.y) }
      end
      objects[o._uid_] = o
      object = objectReader:read()
    end
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

  for _, obj in pairs(objects) do
    obj:draw()
  end

  if currentFullScreen then
    love.graphics.pop()
  end
end

function love.keypressed(key)
  if key == "f" then
    fullScreen = not fullScreen
  end
  if key == "r" then
    love.event.quit("restart")
  end
  if key == "escape" then
    love.event.quit(0)
  end
end
