local L = require("lib")
local OOP = require("OOP")
local Class = OOP.Class
local socket = require("socket")

local HOST = "127.0.0.1"
local PORT = 5000

local WAIT_SOCKETS = 0.01
local WAIT_LOOP = 0.01

local SERVER_EVENTS = {
  CLIENT_CREATED = "clientCreated",
  CLIENT_REMOVED = "clientRemoved"
}

local Server = Class({
  __constructors = {
    Server = function(self)
      if L.x(self.listener) then
        self._listener = self.listener
        self._listener:setServer(self)
        self.listener = nil
      end
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
      self._listeners = {}
      if self._verbose then
        print(string.format("Server listening on %s:%d", HOST, PORT))
      end
      self._count = 0
    end,
  },

  addListener = function(self, listener)
    self._listeners[listener] = listener
  end,

  removeListener = function(self, listener)
    self._listeners[listener] = nil
  end,

  _event = function(self, E, ...)
    for _, listener in pairs(self._listeners) do
      listener[E](listener, ...)
    end
  end,

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

    self:_event(SERVER_EVENTS.CLIENT_CREATED, client)

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

    if _client and _client == client then
      _client.socket:close()
      self._clients[_client.socket] = nil

      self:_event(SERVER_EVENTS.CLIENT_REMOVED, client)

      self:print("Client disconnected: " .. _client.address)
    end
  end,

  sendToClient = function(self, client, message)
    -- Our protocol uses newline as the message delimiter.
    if not message:match("\n$") then
      message = message .. "\n"
    end

    local ok, err = client.socket:send(message)

    if not ok then
      self:print("Send error (" .. client.address .. "): " .. tostring(err))
      self:removeClient(client)
      return false, err
    end
    self:print("Server sent to " .. client.address .. " (" .. self._count .. "): " .. message)

    return true
  end,

  broadCast = function(self, message, except)
    local ok, err = true, nil
    for _, client in pairs(self._clients) do
      if client ~= except then
        ok, err = self:sendToClient(client, message)
        if not ok then
          break
        end
      end
    end
    self._count = self._count + 1
    return ok, err
  end,

  poll = function(self)
    local readable = { self._server }

    for client in pairs(self._clients) do
      table.insert(readable, client)
    end

    -- Wait until something happens.
    local ready = socket.select(readable, nil, WAIT_SOCKETS)

    local messages = {}

    for _, _socket in ipairs(ready) do
      -- New connection
      if _socket == self._server then
        local clientSocket = self._server:accept()

        if clientSocket then
          self:createClient(clientSocket)
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
    return messages
  end,

  start = function(self)
    if not L.x(self._listener) then
      error("AServerListener instance required for loop mode")
    end
    self._running = true
    self:print("Server loop started")
    while self._running do
      local messages = self:poll()
      self._listener:listen(messages)
      socket.sleep(WAIT_LOOP)
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
  [SERVER_EVENTS.CLIENT_CREATED] = function(self, client)
    error("REQUIRES IMPLEMENTATION")
  end,

  [SERVER_EVENTS.CLIENT_REMOVED] = function(self, client)
    error("REQUIRES IMPLEMENTATION")
  end,
}

return {
  Server = Server,
  AServerListner = AServerListner,
  SERVER_EVENTS = SERVER_EVENTS
}
