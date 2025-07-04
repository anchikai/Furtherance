local Mod = Furtherance
local FR_EID = Mod.EID_Support
local DD = FR_EID.DynamicDescriptions

local modifiers = {}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_characters.characters_en_us")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for playerType, data in pairs(desc) do
		allDescData[playerType] = allDescData[playerType] or {}
		if modifiers[playerType] then
			Mod:AddToDictionary(allDescData[playerType], modifiers[playerType])
		end
		allDescData[playerType][lang] = data
	end
end

for playerId, charDescData in pairs(allDescData) do
	for lang, descData in pairs(charDescData) do
		if not DD:IsValidDescription(descData.Description) or DD:ContainsFunction(descData.Description) then
			Mod:Log("Invalid character description for " .. descData.Name, "Language: " .. lang)
		else
			EID:addCharacterInfo(playerId, table.concat(descData.Description, ""), descData.Name, lang)
		end
	end
end
