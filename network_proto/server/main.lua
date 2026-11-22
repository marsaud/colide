package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local OOP = require("OOP")
local Class = OOP.Class

local s = require("network/server")
local Server = s.Server
local ALoopListener = s.ALoopListener

local messageCount = 0

local Listener = Class(ALoopListener, {
  _listen = function(self, messages)
    for _, m in pairs(messages) do
      messageCount = messageCount + 1
      print(messageCount .. ": " .. m)
      if m == "quit" then
        self:getServer():stop()
      end
    end
  end,
})

local listener = Listener:new()

local server = Server:new({
  loopListener = listener,
  verbose = true,
})

server:start()
