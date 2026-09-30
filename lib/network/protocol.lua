-- CONFORT TWEAKS
require("workHelpers")
-- END CONFORT TWEAKS

local Message = {
  format = function(control)
    return tostring(control)
  end,

  parse = function(message)
    return tonumber(message)
  end,
}

local parse = function(str, separator)
  local parsed = {}
  local i = 1

  local word = ""
  local c = string.sub(str, i, i)
  while c ~= "" do
    while c ~= separator and c ~= "" do
      word = word .. c
      i = i + 1
      c = string.sub(str, i, i)
    end
    table.insert(parsed, word)
    word = ""
    i = i + 1
    c = string.sub(str, i, i)
  end
  return table.unpack(parsed)
end

return {
  parse = parse,
  Message = Message,
}
