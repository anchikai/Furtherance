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
			return desc and desc.Description or "{{Card72}} Uses XVI - The Tower?"
		end
	},
	[Mod.Item.BOOK_OF_SWIFTNESS.ID] = {
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
				Card.CARD_ERA_WALK, descObj.Entity, true)
			return desc and desc.Description or "{{Card54}} Uses Era Walk"
		end
	},
	[Mod.Item.KEY_CAPS.ID] = {
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
				Card.CARD_HUGE_GROWTH, descObj.Entity, true)
			return desc and desc.Description or "{{Card52}} Uses Huge Growth"
		end,
	},
	[Mod.Item.MUDDLED_CROSS.ID] = {
		_modifier = function(descObj, tPeterDesc, nonTPeterDesc)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if Mod.Character.PETER_B:IsPeterB(player) then
				return tPeterDesc
			else
				return nonTPeterDesc
			end
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

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid collectible description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not collectibleDescData._AppendToEnd then
			EID:addCollectible(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla items that already have one
			if not EID.descriptions[language].collectibles[id] then
				EID:addCollectible(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, collectibleDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_COLLECTIBLE, id, language)
		end

		::continue::
	end
end
