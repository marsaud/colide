package.path = "./lib/?.lua;./lib/?/init.lua;" .. package.path

local OOP = require("OOP")
local Class = OOP.Class

local s = require("network/server")
local Server = s.Server
local AServerListener = s.AServerListner

local messageCount = 0

local Listener = Class(AServerListener, {
  _listen = function(self, messages)
    for _, m in pairs(messages) do
      messageCount = messageCount + 1
      print(messageCount .. ": " .. m)
    end
  end,
})

local listener = Listener:new()

local server = Server:new({
  listener = listener,
  verbose = true,
})

server:start()
