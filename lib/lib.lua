return {
  f = function(v)
    return type(v) == "function"
  end,
  x = function(v)
    return type(v) ~= "nil"
  end,
  n = function(v)
    return type(v) == "number"
  end,
  s = function(v)
    return type(v) == "string"
  end,
  t = function(v)
    return type(v) == "table"
  end,
}
