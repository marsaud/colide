local _uid_ = 1

local function _s(o)
  if type(o) == "number" then
    return o
  elseif type(o) == "string" then
    return string.format("%q", o)
  elseif type(o) == "table" then
    local data = { "{" }
    for k, v in pairs(o) do
      if type(v) ~= "function" then
        if type(k) == "number" then
          table.insert(data, _s(v) .. ",")
        else
          table.insert(data, "[" .. _s(k) .. "]=" .. _s(v) .. ",")
        end
      end
    end
    table.insert(data, "}")
    return table.concat(data)
  end
end

local serialize = function(o)
  return "return unz(" .. _s(o) .. ")"
end

local unz = function(data)
  return data
end

local Serializable = {
  _constructors = {
    Serializable = function(self)
      self._uid_ = _uid_
      _uid_ = _uid_ + 1
    end,
  },

  serialize = function(self)
    return serialize(self)
  end,
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
  unz = unz,
  serialize = serialize,
  Serializable = Serializable,
  unserialize = unserialize,
}
