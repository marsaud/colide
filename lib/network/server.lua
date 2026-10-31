local L = require("lib")
local OOP = require("OOP")
local Class = OOP.Class
local socket = require("socket")

local HOST = "127.0.0.1"
local PORT = 5000

local Server = Class({
  __constructors = {
    Server = function(self)
      if not L.x(self.listener) then
        error("AServerListener instance required")
      end
      self._listener = self.listener
      self.listener = nil
      self._verbose = self.verbose or false
      self.verbose = nil
      self._host = self.host or HOST
      self.host = nil
      self._port = self.port or PORT
      self.port = nil
      self._clients = {}
      self._server = assert(socket.bind(self._host, self._port))
      self._server:settimeout(0)
      self._running = false
      if self._verbose then
        print(string.format("Server listening on %s:%d", HOST, PORT))
      end
    end,
  },

  print = function(self, ...)
    if self._verbose then
      print(...)
    end
  end,

  createClient = function(self, _socket)
    _socket:settimeout(0)
    local client = {
      socket = _socket,
      address = tostring(_socket),
      buffer = "",
    }
    self._clients[_socket] = client

    if self._verbose then
      self:print("Client connected: " .. client.address)
      local count = 0
      for _ in pairs(self._clients) do
        count = count + 1
      end
      self:print("Connected clients: " .. count)
    end

    return client
  end,

  removeClient = function(self, client)
    local _client = self._clients[client.socket]

    if _client then
      _client.socket:close()
      self._clients[_client.socket] = nil
      self:print("Client disconnected: " .. _client.address)
    end
  end,

  sendToClient = function(self, client, message)
    local ok, err = client.socket:send(message)

    if not ok then
      self:print("Send error (" .. client.address .. "): " .. tostring(err))
      self:removeClient(client)
      return false
    end

    return true
  end,

  broadCast = function(self, message, except)
    for client, _ in pairs(self._clients) do
      if client ~= except then
        self:sendToClient(client, message)
      end
    end
  end,

  start = function(self)
    local lastBroadcast = socket.gettime()
    self._running = true
    self:print("Server loop started")
    while self._running do
      local readable = { self._server }

      for client in pairs(self._clients) do
        table.insert(readable, client)
      end

      -- Wait until something happens.
      local ready = socket.select(readable, nil, 0.1)

      local messages = {}

      for _, _socket in ipairs(ready) do
        -- New connection
        if _socket == self._server then
          local clientSocket = self._server:accept()

          if clientSocket then
            local client = self:createClient(clientSocket)
          end
        else
          local client = self._clients[_socket]
          local data, err, partial = client.socket:receive("*a")

          data = data or partial

          if data and #data > 0 then
            client.buffer = client.buffer .. data

            while true do
              local newline = client.buffer:find("\n", 1, true)

              if not newline then
                break
              end

              local message = client.buffer:sub(1, newline - 1)
              client.buffer = client.buffer:sub(newline + 1)

              -- Remove CR from CRLF
              message = message:gsub("\r$", "")

              self:print("Received (" .. client.address .. "): " .. message)

              table.insert(messages, message)
            end
          end

          if err == "closed" then
            self:removeClient(client)
          end
        end
      end

      self._listener:listen(messages)
      messages = {}

      socket.sleep(0.01)
    end
    self:print("Server loop stopped")
  end,

  stop = function(self)
    self._running = false
  end,

  flush = function(self)
    for _, client in pairs(self._clients) do
      client.socket:receive("*a")
      client.buffer = ""
    end
  end,

  close = function(self)
    self:flush()
    for _, client in pairs(self._clients) do
      self:removeClient(client)
    end
    self._server:close()
    self:stop()
    self:print("Server closed")
  end,
})

AServerListner = {
  listen = function(self, messages)
    if self._listen then
      self:_listen(messages)
    end
  end,
}

return {
  Server = Server,
  AServerListner = AServerListner,
}
