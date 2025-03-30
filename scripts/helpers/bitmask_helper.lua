---Credit to Epiphany

---@param bitmaskOffset integer
---@return TearFlags
---@function
function Furtherance:TearFlag(bitmaskOffset)
	return bitmaskOffset >= 64 and BitSet128(0, 1 << (bitmaskOffset - 64)) or BitSet128(1 << bitmaskOffset, 0)
end

---Returns an array of names from given bitmask
---@param flagTable table @enum table that contains all flags
---@param bitmask integer @bitmask to split
---@param maxInt integer @max offset to check
---@return string[]
function Furtherance:GetNamesInBitmask(flagTable, bitmask, maxInt)
	local names = {}
	local inv = Furtherance:Invert(flagTable)
	for i = 0, maxInt do
		if bitmask & (1 << i) == (1 << i) then
			names[#names + 1] = inv[1 << i]
		end
	end
	return names
end

---Returns true if the first agument contains the second argument
---@generic flag
---@param flags flag
---@param checkFlag flag
function Furtherance:HasBitFlags(flags, checkFlag)
	if not checkFlag then
		error("BitMaskHelper: checkFlag is nil", 2)
	end
	return flags & checkFlag == checkFlag
end

---Returns true if the first argument contains any of the flags in the second argument. A looser version of HasBitFlags.
---@generic flag
---@param flags flag
---@param checkFlag flag
function Furtherance:HasAnyBitFlags(flags, checkFlag)
	return flags & checkFlag > 0
end

---Adds the second argument bitflag to the first
---@generic flag
---@param flags flag
---@param addFlag flag
---@return flag
function Furtherance:AddBitFlags(flags, addFlag)
	flags = flags | addFlag
	return flags
end

---Removes the second argument bitflag from the first. If it doesn't have it, it will remain the same
---@generic flag
---@param flags flag
---@param removeFlag flag
---@return flag
function Furtherance:RemoveBitFlags(flags, removeFlag)
	flags = flags & ~removeFlag
	return flags
end
