	math.sign = function (n) return n / math.abs(n) end
	math.round = function (n) return math.ceil(n) - n > 0.5 and math.floor(n) or math.ceil(n) end