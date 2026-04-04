require("workHelpers")

local function debug(...)
  local arg = { ... }
  local r = {}
  for _, i in ipairs(arg) do
    if i == true or i == false or type(i) == "number" then
      i = tostring(i)
    elseif type(i) == "function" then
      i = "function"
    elseif i.id then
      i = i.id
    elseif i.x and i.y then
      i = "(" .. i.x .. "," .. i.y .. ")"
    end
    table.insert(r, i)
  end
  print(table.unpack(r))
end

local function noop() end

return function()
  return debug
end
