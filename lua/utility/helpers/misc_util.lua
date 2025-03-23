--Taken directly from the source! Shoutouts to the modders who decompiled the Switch port.
---@param tear EntityTear
---@return string
function Furtherance:TearScaleToSizeAnim(tear)
	local scale = tear.Scale
	local anim = "8"

	if scale <= 0.3 then
		anim = "1"
	elseif scale <= 0.55 then
		anim = "2"
	elseif scale <= 0.675 then
		anim = "3"
	elseif scale <= 0.8 then
		anim = "4"
	elseif scale <= 0.925 then
		anim = "5"
	elseif scale <= 1.05 then
		anim = "6"
	elseif scale <= 1.175 then
		anim = "7"
	elseif 1.425 < scale then
		if scale <= 1.675 then
			anim = "9"
		elseif scale <= 1.925 then
			anim = "10"
		elseif scale <= 2.175 then
			anim = "11"
		elseif 2.55 < scale then
			anim = "12"
		end
		anim = "13"
	end
	return anim
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