local L = require("lib")
local OOP = require("OOP")
local Class = OOP.Class
local socket = require("socket")

local HOST = "127.0.0.1"
local PORT = 5000

local Client = Class({
  __constructors = {
    Client = function(self)
      self._verbose = self.verbose or false
      self.verbose = nil
      self._host = self.host or HOST
      self.host = nil
      self._port = self.port or PORT
      self.port = nil
      self._buffer = ""
      self._messages = {}
    end,
  },

  print = function(self, ...)
    if self._verbose then
      print(...)
    end
  end,

  connect = function(self)
    local tcp, error = socket.tcp()

    if not tcp then
      self:print("Failed to create socket: " .. tostring(error))
      return false
    end

    -- Non-blocking socket.
    tcp:settimeout(0)

    local ok, err = tcp:connect(self._host, self._port)

    -- With a non-blocking socket, connect() may return:
    --   true
    --   nil, "timeout"
    --
    -- "timeout" here means the connection is still being established.
    if not ok and err ~= "timeout" then
      self:print("Connection failed: " .. tostring(err))
      tcp:close()
      return false
    end

    self._socket = tcp

    self:print("Connected to " .. self._host .. ":" .. self._port)

    return true
  end,

  disconnect = function(self)
    if self._socket then
      self._socket:close()
      self._socket = nil
      self._buffer = ""

      self:print("Disconnected")
    end
  end,

  send = function(self, message)
    if not self._socket then
      return false, "not connected"
    end

    if type(message) ~= "string" then
      message = tostring(message)
    end

    -- Our protocol uses newline as the message delimiter.
    if not message:match("\n$") then
      message = message .. "\n"
    end

    local bytes, err = self._socket:send(message)

    if not bytes then
      self:print("Send error: " .. tostring(err))
      self:disconnect()
      return false, err
    end

    return true
  end,

  update = function(self)
    if not self.socket then
      return
    end

    while true do
      local data, err, partial = self._socket:receive("*a")

      data = data or partial

      if data and #data > 0 then
        self._buffer = self._buffer .. data
      end

      -- Extract complete newline-delimited messages.
      while true do
        local newline = self._buffer:find("\n", 1, true)

        if not newline then
          break
        end

        local message = self._buffer:sub(1, newline - 1)

        self._buffer = self._buffer:sub(newline + 1)

        -- Remove optional \r from Windows-style line endings.
        message = message:gsub("\r$", "")

        table.insert(self._messages, message)
      end

      if err == "timeout" then
        -- No more data available right now.
        break
      elseif err == "closed" then
        self:print("Server closed the connection")
        self:disconnect()
        break
      elseif err then
        error("Receive error: " .. tostring(err))
        self:disconnect()
        break
      end

      -- If receive() returned data successfully, try again.
      if not data then
        break
      end
    end
  end,

  poll = function(self)
    if #self._messages == 0 then
      return nil
    end
    local message = table.remove(self._messages, 1)
    return message
  end,
})

return {
  Client = Client,
}
