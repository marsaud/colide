local OrderedTable = {}
OrderedTable.__index = OrderedTable

function OrderedTable:new()
  return setmetatable({ keys = {}, values = {} }, self)
end

function OrderedTable:set(key, value)
  if self.values[key] == nil then
    table.insert(self.keys, key)
  end
  self.values[key] = value
end

function OrderedTable:iterate()
  local i = 0
  return function()
    i = i + 1
    local key = self.keys[i]
    if key then
      return key, self.values[key]
    end
  end
end

return function()
  return OrderedTable
end
