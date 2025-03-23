-- this code is licensed under a [copyleft](https://en.wikipedia.org/wiki/Copyleft) license: this code is completely okay to modify, copy, redistribute and improve upon, as long as you keep this license notice
-- Based on oatmealine's EVERYTHING FUNCTION (dump)

local entities = Furtherance:Set({
	"Entity",
	"EntityBomb",
	"EntityEffect",
	"EntityFamiliar",
	"EntityKnife",
	"EntityLaser",
	"EntityNPC",
	"EntityPickup",
	"EntityPlayer",
	"EntityProjectile",
	"EntityTear"
})
local gridEntities = Furtherance:Set({
	"GridEntity",
	"GridEntityDoor",
	"GridEntityPit",
	"GridEntityPoop",
	"GridEntityPressurePlate",
	"GridEntityRock",
	"GridEntitySpikes",
	"GridEntityTNT"
})

local function copyShallow(tab)
	local out = {}
	for k, v in pairs(tab) do
		out[k] = v
	end
	return out
end

local MAX_DEPTH = 15
local PADDING = "  " -- added for each depth level

---@param obj any \
---@param depth integer \
---@param seen table \
---@return string \
local function toString(obj, depth, seen)
	local objType = type(obj)

	if depth > MAX_DEPTH then return tostring(obj) end

	if objType == "userdata" then
		local t = getmetatable(obj).__type
		if entities[t] then
			return t .. ': ' .. (obj.Type or '0') .. '.' .. (obj.Variant or '0') .. '.' .. (obj.SubType or '0')
		elseif t == 'EntityRef' then
			return t .. ' -> ' .. toString(obj.Entity, depth, seen)
		elseif t == 'EntityPtr' then
			return t .. ' -> ' .. toString(obj.Ref, depth, seen)
		elseif gridEntities[t] then
			return t ..
				': ' ..
				obj:GetType() ..
				'.' .. obj:GetVariant() .. '.' .. obj.VarData .. ' at ' .. toString(obj.Position, depth, seen)
		elseif t == 'GridEntityDesc' then
			return t .. ' -> ' .. obj.Type .. '.' .. obj.Variant .. '.' .. obj.VarData
		elseif t == 'Vector' then
			return t .. '(' .. obj.X .. ', ' .. obj.Y .. ')'
		elseif t == 'Color' then
			return t ..
				'(' ..
				obj.R .. ', ' .. obj.G .. ', ' .. obj.B .. ', ' .. obj.RO .. ', ' .. obj.GO .. ', ' .. obj.BO .. ')'
		elseif t == 'Level' then
			return t .. ': ' .. obj:GetName()
		elseif t == 'RNG' then
			return t .. ': ' .. obj:GetSeed()
		elseif t == 'Sprite' then
			return t ..
				': ' ..
				obj:GetFilename() ..
				' - ' ..
				(obj:IsPlaying(obj:GetAnimation()) and 'playing' or 'stopped at') ..
				' ' .. obj:GetAnimation() .. ' f' .. obj:GetFrame()
		elseif t == 'TemporaryEffects' then
			local list = obj:GetEffectsList() ---@type EffectList
			local tab = {}
			for i = 0, #list - 1 do
				tab[#tab + 1] = list:Get(i)
			end

			return "TemporaryEffects: " ..
				toString(tab, depth + 1, seen) -- only increase depth for collection-type objects
		else
			local newt = {}
			for k, v in pairs(getmetatable(obj)) do
				if type(k) ~= 'userdata' and k:sub(1, 2) ~= '__' then
					newt[k] = v
				end
			end

			return 'userdata ' .. toString(newt, depth + 1, seen)
		end
	elseif objType == "table" then
		if seen[obj] then return '...' end

		seen[obj] = true
		local empty = true
		local tab = {}

		for k, v in pairs(obj) do
			local key
			if type(k) == "string" then
				key = k
			else
				key = '[' .. toString(k, depth + 1, copyShallow(seen)) .. ']'
			end

			local value = toString(v, depth + 1, copyShallow(seen))

			tab[#tab + 1] = string.rep('  ', depth + 1) .. key .. ': ' .. value
			empty = false
		end

		if empty then
			return '{}'
		else
			tab[#tab + 1] = string.rep(PADDING, depth) .. '}'
			return '{\n' .. table.concat(tab, ',\n')
		end
	elseif objType == "string" then
		return '"' .. obj .. '"'
	else
		return tostring(obj)
	end
end

---@param obj any
---@param depth? integer
--  This function will take in any type, any Isaac class and any vanilla lua type
--  and format it as a readable, comprehensible string you can shove in a `print()`.<br>
--  It will try to its best ability to format Isaac types, even the more obscure
--  ones, and if it fails itll fall back to listing all of its keys accessible
--  from getmetatable. It recurses through anything it finds, and makes sure to
--  mark circular elements as such, avoiding potential lag.
--
-- examples:
-- <hr>
-- ```
-- print(Dump(Isaac.GetPlayer(0)))
-- ```
--
-- Output:
--  `EntityPlayer: 1.0.7`
-- <hr>
-- ```
-- print(Dump(Color(0.5, 0.25, 0.75)))
-- ```
--
-- Output: `Color(0.5, 0.25, 0.75)`
-- <hr>
-- ```
-- print(Dump(Isaac.GetRoomEntities()))
-- ```
--
-- Output:
--
-- ```
-- {
--  [1]: Entity: 1.0.42,
--  [2]: Entity: 1000.21.0,
--  [3]: Entity: 1000.21.0,
--  [4]: Entity: 1000.21.0,
--  [5]: Entity: 1000.68.0,
--  -- ...
--  [n-1]: Entity: 1000.121.0,
--  [n]: Entity: 1000.121.0
-- }
-- ```
-- <hr>
return function(obj, depth)
	return toString(obj, depth or 0, {})
end
