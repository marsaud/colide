local OrderedTable = {}
OrderedTable.__index = OrderedTable

function OrderedTable:new()
  return setmetatable({ __keys = {}, __values = {} }, self)
end

function OrderedTable:set(key, value)
  if self.__values[key] == nil then
    table.insert(self.__keys, key)
  end
  self.__values[key] = value
end

function OrderedTable:iterate()
  local i = 0
  return function()
    i = i + 1
    local key = self.__keys[i]
    if key ~= nil then
      return key, self.__values[key]
    end
  end
end

return {
  OrderedTable = OrderedTable,
}
