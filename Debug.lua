require("workHelpers")

local function _debug(...)
  local arg = { ... }
  local r = ""
  for _, i in ipairs(arg) do
    if i == true or i == false or type(i) == "number" then
      i = tostring(i)
    elseif type(i) == "function" then
      i = "function"
    elseif i.id then
      i = i.id
    elseif type(i) == "table" then
      local _i = tostring(i) .. "\n"
      for k, v in pairs(i) do
        _i = _i .. _debug(k, v) .. "\n"
      end
      _i = _i .. "END " .. tostring(i) .. "\n"
      i = _i
    elseif i.c then
      i = "(" .. i:c().x .. "," .. i:c().y .. ")"
    elseif i.x and i.y then
      i = "(" .. i.x .. "," .. i.y .. ")"
    end
    r = r .. tostring(i) .. " "
  end
  return r
end

local function debug(...)
  local r = _debug(...)
  print(r)
end

return function()
  return debug
end
