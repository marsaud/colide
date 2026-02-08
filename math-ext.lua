	math.sign = function (n)
		if n == 0 then return 0 end
		return n / math.abs(n)
	end
	math.round = function (n) return math.ceil(n) - n > 0.5 and math.floor(n) or math.ceil(n) end