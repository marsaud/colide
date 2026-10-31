local _uid_ = 1

local function _s(o)
  if type(o) == "number" then
    return o
  elseif type(o) == "string" then
    return string.format("%q", o)
  elseif type(o) == "table" then
    if o.__NOT_SERIALIZABLE then
      return nil
    end
    local data = { "{" }
    for k, v in pairs(o) do
      if type(k) == "string" and k:sub(1, 2) == "__" then
        -- skip
      else
        local skey = _s(k)
        if skey == nil then
          -- skip
        else
          local svalue = _s(v)
          if svalue == nil then
            -- skip
          elseif type(k) == "number" then
            table.insert(data, svalue .. ",")
          else
            table.insert(data, "[" .. skey .. "]=" .. svalue .. ",")
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

local serialize = function(o, unserializeCallbackName)
  if not unserializeCallbackName then
    unserializeCallbackName = DEFAULT_UNSERIALIZE_CALLBACK_NAME
  end
  return "return " .. unserializeCallbackName .. "(" .. _s(o) .. ")"
end

local Serializable = {
  __constructors = {
    Serializable = function(self)
      self._uid_ = _uid_
      _uid_ = _uid_ + 1
    end,
  },

  serialize = function(self, unserializeCallbackName)
    return serialize(self, unserializeCallbackName)
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
