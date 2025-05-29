---Credit to Epiphany's "CreateTooltip" function in deadseascrolls.lua
---@param font Font
---@param string string
---@param stringLengthLimit integer
function Furtherance:FitStringInBox(font, string, stringLengthLimit)
	local endTable = {}
	local currentString = ""
	for w in string:gmatch("%S+") do
		local newString = currentString .. w .. " "
		if font:GetStringWidth(newString) >= stringLengthLimit then
			Furtherance.Insert(endTable, currentString)
			currentString = ""
		end

		currentString = currentString .. w .. " "
	end

	Furtherance.Insert(endTable, currentString)
	return endTable
end

---@param typeVarSub string
---@return integer type, integer variant, integer subtype
function Furtherance:GetTypeVarSubFromString(typeVarSub)
	local firstDot = string.find(typeVarSub, ".", 1, true)
	local secondDot = string.find(typeVarSub, ".", firstDot + 1, true)
	local type = tonumber(string.sub(typeVarSub, 1, firstDot and firstDot - 1 or -1))
	if not type then return 0, 0, 0 end
	local var
	local sub
	if firstDot then
		local endPoint = secondDot and secondDot - 1 or -1
		var = tonumber(string.sub(typeVarSub, firstDot + 1, endPoint))
	end
	if secondDot then
		sub = tonumber(string.sub(typeVarSub, secondDot + 1, -1))
	end
	var = var or 0
	sub = sub or 0
	return type, var, sub
end

---@param entityConfig EntityConfigEntity
function Furtherance:GetTypeVarSubFromEntityConfig(entityConfig)
	local typeVarSub = entityConfig:GetType() .. "." .. entityConfig:GetVariant()
	typeVarSub = entityConfig:GetSubType() > 0 and typeVarSub .. "." .. entityConfig:GetSubType() or typeVarSub
	return typeVarSub
end

---@param ent Entity
---@param asString? nil
---@return EntityType, integer, integer
---@overload fun(self: ModReference, ent: Entity, asString: boolean): string
function Furtherance:GetTypeVarSubFromEnt(ent, asString)
	local entType, var, sub = ent.Type, ent.Variant, ent.SubType
	if asString then
		return tostring(entType) .. "." .. tostring(var) .. "." .. tostring(sub)
	else
		return entType, var, sub
	end
end

---@param name string
---@param asString? nil
---@return EntityType, integer, integer
---@overload fun(self: ModReference, name: string, asString: boolean): string
function Furtherance:GetTypeVarSubFromName(name, asString)
	local entType, var, sub = Isaac.GetEntityTypeByName(name), Isaac.GetEntityVariantByName(name), Isaac.GetEntitySubTypeByName(name)
	if asString then
		return tostring(entType) .. "." .. tostring(var) .. "." .. tostring(sub)
	else
		return entType, var, sub
	end
end

---@param category string
---@param key string
function Furtherance:TryGetTranslatedString(category, key)
	local localizedStr = Isaac.GetString(category, key)
	if localizedStr and localizedStr ~= "StringTable::InvalidKey" then
		return localizedStr
	end
	return key
end

function Furtherance:StandardCapitilization(text)
	return string.upper(string.sub(text, 1, 1)) .. string.lower(string.sub(text, 2, -1))
end

---@param num number
---@param maxLength integer
function Furtherance:FillNumberWithZeros(num, maxLength)
	local numString = tostring(num)
	for _ = 1, maxLength do
		if string.len(numString) < maxLength then
			numString = "0" .. numString
		end
	end
	return numString
end
