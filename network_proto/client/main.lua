package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local c = require("network/client")
local Client = c.Client

local Control = require("Control")
local DispatchController = Control.DispatchController
local KeyboardController = Control.KeyboardController
local defaultKeyMaps = Control.defaultKeyMaps

local client
local dc

local messages = {
  a = "Alan",
  z = "Zachary",
  e = "Elon",
  r = "Roger",
  t = "Tim",
  y = "Yann",
}

function love.load()
  dc = DispatchController:new()
  local kbc1 = KeyboardController:new({ map = defaultKeyMaps[1] })
  local kbc2 = KeyboardController:new({ map = defaultKeyMaps[2] })
  dc:addController(kbc1, 1)
  dc:addController(kbc2, 2)

  client = Client:new({ verbose = true })
  client:connect()
end

function love.update()
  dc:fetch()
  local m, ch = dc:poll()
  while m do
    client:send(m .. "|" .. ch)
    m, ch = dc:poll()
  end
end

function love.draw() end

function love.keypressed(key)
  local message = messages[key]
  if message ~= nil then
    -- client:send(message)
  end
end
