Furtherance.RandomRNG = RNG()
Furtherance.RandomRNG:SetSeed(Random() + 1)

---@param lower? integer
---@param upper? integer
function Furtherance:RandomNum(lower, upper)
	if upper then
		return Furtherance.RandomRNG:RandomInt((upper - lower) + 1) + lower
	elseif lower then
		return Furtherance.RandomRNG:RandomInt(lower) + 1
	else
		return Furtherance.RandomRNG:RandomFloat()
	end
end

---Takes the `allNums` table and removes identical values found in `selectedNum`, then randomly returning one of the values
---@generic V
---@param selectedNums table
---@param allNums V[]
---@param rng RNG
---@return V
function Furtherance:GetDifferentRandomValue(selectedNums, allNums, rng)
	local filteredNums = {}

	for _, int in pairs(allNums) do
		for _, checkInt in pairs(selectedNums) do
			if int == checkInt then goto continue end
		end
		Furtherance:Insert(filteredNums, int)
		::continue::
	end
	return filteredNums[rng:RandomInt(#filteredNums) + 1]
end

---@generic V
---@param selectedNums table
---@param allNums {[V]: any}
---@param rng RNG
---@return V
function Furtherance:GetDifferentRandomKey(selectedNums, allNums, rng)
	local filteredNums = {}

	for int, _ in pairs(allNums) do
		if not selectedNums[int] then
			Furtherance:Insert(filteredNums, int)
		end
	end
	return filteredNums[rng:RandomInt(#filteredNums) + 1]
end

--Credit to DeadInfinity for Lerping directly with angles!
---@param a1 number
---@param a2 number
function Furtherance:GetAngleDifference(a1, a2)
	local sub = a1 - a2
	return (sub + 180) % 360 - 180
end

---@param aStart number
---@param aEnd number
---@param percent number
function Furtherance:LerpAngleDegrees(aStart, aEnd, percent)
	return aStart + Furtherance:GetAngleDifference(aEnd, aStart) * percent
end

---@param first number
---@param second number
---@param percent number
---@function
function Furtherance:Lerp(first, second, percent)
	return (first + (second - first) * percent)
end

---@param vec1 Vector
---@param vec2 Vector
---@param percent number
---@function
function Furtherance:VecLerp(vec1, vec2, percent)
	return vec1 * (1 - percent) + vec2 * percent
end

---@param value number
---@param min number
---@param max number
---@function
function Furtherance:Clamp(value, min, max)
	-- this is actually faster than math.min(math.max)
	if value < min then
		return min
	elseif value > max then
		return max
	else
		return value
	end
end

---Exists so that random will never have 0 for a seed, which would otherwise crash the game
function Furtherance:Random()
	return math.max(Random(), 1)
end

---@param vec Vector
---@return Direction
function Furtherance:GetRoundedDirection(vec)
	if vec.X == 0 and vec.Y == 0 then
		return Direction.DOWN
	end
	local angle = vec:Normalized():GetAngleDegrees()
	if angle < 0 then
		angle = 360 + angle
	end
	local degrees = {
		0,
		90,
		180,
		270,
		360
	}
	local closestAngle
	local closestSubtraction
	for _, degree in ipairs(degrees) do
		if not closestAngle or math.abs(angle - degree) < closestSubtraction then
			closestSubtraction = math.abs(angle - degree)
			closestAngle = degree
		end
	end
	if closestAngle == 360 then
		closestAngle = 0
	end
	local dirAngles = {
		[0] = Direction.RIGHT,
		[90] = Direction.DOWN,
		[180] = Direction.LEFT,
		[270] = Direction.UP,
	}

	return dirAngles[closestAngle]
end

---@param dir integer
function Furtherance:DirectionToVector(dir)
	return Vector(-1, 0):Rotated(90 * dir)
end

---@param num number
---@param dp? integer
function Furtherance:Round(num, dp)
	dp = dp or 2
	local mult = 10^dp
	return math.floor(num * mult + 0.5)/mult
end

---Takes two 2d vectors and checks them to see if they are equal
---@param vec1 Vector
---@param vec2 Vector
function Furtherance:VectorsAreEqual(vec1, vec2)
	return vec1.X == vec2.X
		and vec1.Y == vec2.Y
end

---@param num number
function Furtherance:FlattenFloatValue(num)
	return math.floor(num) == num and math.floor(num) or num
end
