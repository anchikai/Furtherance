local Mod = Furtherance
local FR_EID = Mod.EID_Support
local DD = FR_EID.DynamicDescriptions

local modifiers = {
	[Mod.Pill.HEARTACHE.ID_UP] = {
		_metadata = { 4, "3-" },
	},
	[Mod.Pill.HEARTACHE.ID_DOWN] = {
		_metadata = { 6, "3+" },
	},
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_pills.pills_en_us")(modifiers),
	spa = Mod.Include("scripts.compatibility.patches.eid.eid_pills.pills_spa")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for pillEffect, data in pairs(desc) do
		allDescData[pillEffect] = allDescData[pillEffect] or {}
		if modifiers[pillEffect] then
			Mod:AddToDictionary(allDescData[pillEffect], modifiers[pillEffect])
		end
		allDescData[pillEffect][lang] = data
	end
end

for id, pillDescData in pairs(allDescData) do
	for language, descData in pairs(pillDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local metadata = pillDescData._metadata

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid pill description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not pillDescData._AppendToEnd then
			EID:addPill(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla pills that already have one
			if not EID.descriptions[language].pills[id + 1] then
				EID:addPill(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, pillDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_PILL, id, language)
		end

		if metadata then
			EID:addPillMetadata(id, metadata[1], metadata[2])
		end

		::continue::
	end
end

