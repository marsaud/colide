local L = require("lib")

local _uid_ = 1

local function _s(o, params)
  local keyMap, keyProtect, value = params.keyMap, params.keyProtect, params.value
  if L.n(o) then
    return o
  elseif L.s(o) then
    if keyProtect then
      return string.format("%q", o)
    elseif value then
      return "\"" .. o .. "\""
    else
      return o
    end
  elseif L.t(o) then
    if o.__NOT_SERIALIZABLE then
      return nil
    end
    local data = { "{" }
    for k, v in pairs(o) do
      if L.t(keyMap) and not keyMap[k] then
        --skip
      elseif L.s(k) and k:sub(1, 2) == "__" then
        -- skip
      else
        local skey = _s(k, { keyProtect = keyProtect })
        if skey == nil then
          -- skip
        else
          local svalue = _s(v, { keyProtect = keyProtect, value = true })
          if svalue == nil then
            -- skip
          elseif L.n(k) then
            table.insert(data, svalue .. ",")
          elseif keyProtect then
            table.insert(data, "[" .. skey .. "]=" .. svalue .. ",")
          else
            table.insert(data, skey .. "=" .. svalue .. ",")
          end
        end
      end
    end

    table.insert(data, "}")
    return table.concat(data)
  else
    return nil
  end
end

local unz = function(data)
  return data
end
local DEFAULT_UNSERIALIZE_CALLBACK_NAME = "unz"

local serialize = function(o, keyMap, unserializeCallbackName)
  if not unserializeCallbackName then
    unserializeCallbackName = DEFAULT_UNSERIALIZE_CALLBACK_NAME
  end
  return "return " .. unserializeCallbackName .. "(" .. _s(o, { keyMap = keyMap }) .. ")"
end

local Serializable = {
  __constructors = {
    Serializable = function(self)
      if L.x(self.uid) then
        if L.n(self.uid) then
          error("Forced serialization UID must not be a number")
        end
        self._uid_ = self.uid
      else
        self._uid_ = _uid_
        _uid_ = _uid_ + 1
      end
    end,
  },

  serialize = function(self, keyMap, unserializeCallbackName)
    return serialize(self, keyMap, unserializeCallbackName)
  end,
}

local NotSerializable = {
  __constructors = {
    NotSerializable = function(self)
      self.__NOT_SERIALIZABLE = true
    end,
  },
}

local function unserialize(data)
  local u, err = load(data, "_", "t", { unz = unz })
  if err then
    print(data)
    error(err)
  end
  if u == nil then
    error("Unserialization failure: " .. data)
  end
  return u()
end

return {
  _s = _s,
  NotSerializable = NotSerializable,
  serialize = serialize,
  Serializable = Serializable,
  unserialize = unserialize,
  unz = unz,
}
