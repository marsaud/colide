package.path = "lib/?.lua;lib/?/init.lua;assets/?.lua;" .. package.path

-- CONFORT TWEAKS
require("workHelpers")
-- local love = love
-- END CONFORT TWEAKS

-- IMPORTS
-- local debug = require("Debug").debug
local EventManager = require("Event").EventManager
local speedFactor = require("Move").speedFactor
local Control = require("Control")
-- END IMPORTS

local L = require("lib")
local Server = require("network.server").Server
local parse = require("network.protocol").parse
local AController = Control.AController

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

local ServerController = AController:extend({
  __constructors = {
    ServerController = function(self)
      if not L.x(self.server) then
        error("Server instance required")
      end
      self._server = self.server
      self.server = nil
    end,
  },

  fetch = function(self)
    local messages = self._server:poll()
    for _, message in ipairs(messages) do
      local ctrlms = parse(message, "%", true)
      local ctrls = {}
      for _, ctrlm in pairs(ctrlms) do
        local ctrl, channel = parse(ctrlm, "|")
        ctrl = tonumber(ctrl)
        if ctrl ~= nil then
          ctrls[channel] = ctrl
        end
      end
      local next = next
      if next(ctrls) ~= nil then
        table.insert(self._pile, ctrls)
      end
    end
  end,

  poll = function(self)
    return table.remove(self._pile, 1)
  end,
})

local server = Server:new()

---@diagnostic disable-next-line: duplicate-set-field
function love.load()
  local boots = {}

  local demo = require("demo")
  table.insert(boots, demo)

  -- local bricks = require("bricks/bricks")
  -- table.insert(boots, bricks)

  -- local invaders = require("invaders/invaders")
  -- table.insert(boots, invaders)

  -- local groupDemo = require("groupDemo/groupDemo")
  -- table.insert(boots, groupDemo)

  -- local test = require("collideDebug/test")
  -- table.insert(boots, test)

  local sc = ServerController:new({ server = server })

  for _, b in ipairs(boots) do
    local c = EventManager:new({
      controller = sc,
      keyMap = {
        _uid_ = true,
        h = true,
        w = true,
        _c = true,
        _health = true,
        _state = true,
      },
    })
    c:addObjects(table.unpack(b()))
    c:startDiff()
    table.insert(contexts, c)
  end

  contextIndex = 1
  pause = false
  fullScreen = false

  love.graphics.setLineWidth(1)
  love.graphics.setLineStyle("rough")
end

---@diagnostic disable-next-line: duplicate-set-field
function love.update(dt)
  currentContextIndex = contextIndex
  if pause then
    return
  end
  contexts[currentContextIndex]:tick(dt)
  local _, gameStateDiff = contexts[currentContextIndex]:flush()
  if L.x(gameStateDiff) then
    local ok, err = server:broadCast(gameStateDiff)
    if not ok then
      error(err)
    end
  end
end

---@diagnostic disable-next-line: duplicate-set-field
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

---@diagnostic disable-next-line: duplicate-set-field
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
    server:close()
  end
  if key == "escape" then
    love.event.quit(0)
    server:close()
  end

  if key == "c" then
    contextIndex = contextIndex + 1
  end
  if contextIndex > #contexts then
    contextIndex = 1
  end
end
