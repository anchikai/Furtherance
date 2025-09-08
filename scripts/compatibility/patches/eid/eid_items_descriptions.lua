local Mod = Furtherance
local FR_EID = Mod.EID_Support
local DD = FR_EID.DynamicDescriptions

---@type {[CollectibleType]: {_modifier: fun(descObj: EID_DescObj, ...: any): any}}
local modifiers = {
	[Mod.Item.PALLAS.ID] = {
		_modifier = function(descObj, flatStone)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
				return flatStone
			end
			return ""
		end
	},
	[Mod.Item.BOOK_OF_LEVITICUS.ID] = {
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
				Card.CARD_REVERSE_TOWER, descObj.Entity, true)
			return desc.Description
		end
	},
	[Mod.Item.BOOK_OF_SWIFTNESS.ID] = {
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
				Card.CARD_ERA_WALK, descObj.Entity, true)
			return desc.Description
		end
	},
	[Mod.Item.KEY_CAPS.ID] = {
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
				Card.CARD_HUGE_GROWTH, descObj.Entity, true)
			return desc.Description
		end,
	},
	[Mod.Item.MUDDLED_CROSS.ID] = {
		_modifier = function(descObj, regularWord, replaceWord)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			local desc = Mod.EID_Support.GetFallbackDescription(descObj)
			if Mod.Character.PETER_B:IsPeterB(player) then
				local newDesc = string.gsub(desc, regularWord, replaceWord)
				return newDesc
			end
			return desc
		end
	}
}
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_items.items_en_us")(modifiers),
	spa = Mod.Include("scripts.compatibility.patches.eid.eid_items.items_spa")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for itemID, data in pairs(desc) do
		allDescData[itemID] = allDescData[itemID] or {}
		if modifiers[itemID] then
			Mod:AddToDictionary(allDescData[itemID], modifiers[itemID])
		end
		allDescData[itemID][lang] = data
	end
end

for id, collectibleDescData in pairs(allDescData) do
	for language, descData in pairs(collectibleDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local fallbackDesc = descData.FallbackDescription

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		if fallbackDesc and not DD:IsValidDescription(fallbackDesc) then
			Mod:Log("Invalid collectible fallback description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			fallbackDesc = nil
		end

		local minimized = DD:MakeMinimizedDescription(description)
		local minimizedFallback = fallbackDesc and DD:MakeMinimizedDescription(fallbackDesc)

		if not DD:ContainsFunction(minimized) and not collectibleDescData._AppendToEnd then
			EID:addCollectible(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla items that already have one
			if not EID.descriptions[language].collectibles[id] then
				local desc = minimizedFallback and table.concat(minimizedFallback, "") or ""
				EID:addCollectible(id, desc, name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd, fallbackDesc ~= nil), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE, id, language)
		end

		::continue::
	end
end
