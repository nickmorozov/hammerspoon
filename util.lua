local log = hs.logger.new("util", "info")

local function dump(o)
	if type(o) == "table" then
		local s = "{ "
		for k, v in pairs(o) do
			if type(k) ~= "number" then
				k = '"' .. k .. '"'
			end
			s = s .. "[" .. k .. "] = " .. dump(v) .. ","
		end
		return s .. "} "
	else
		return tostring(o)
	end
end

local i = function(o)
	log.i(dump(o))
end

local d = function(o)
	log.d(dump(o))
end

local e = function(o)
	log.e(dump(o))
end

local function has(t, v)
	for index, v in ipairs(t) do
		if v == v then
			return true
		end
	end

	return false
end

return {
	dump = dump,
	has = has,
	i = i,
	d = d,
	e = e,
}
