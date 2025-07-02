local Mod = Furtherance
local FR_EID = Mod.EID_Support

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
		---@param descObj EID_DescObj
		_modifier = function(descObj)
			local desc = EID:getDescriptionObj(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD,
				Card.CARD_REVERSE_TOWER, descObj.Entity, true)
			return desc and desc.Description or "{{Card72}} Uses XVI - The Tower?"
		end
	},
	[Mod.Item.BOOK_OF_SWIFTNESS.ID] = {
		---@param descObj EID_DescObj
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
	}
}
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_items.items_en_us")(modifiers),
	spa = Mod.Include("scripts.compatibility.patches.eid.eid_items.items_spa")(modifiers),
}

local descData = {}
for lang, desc in pairs(descriptions) do
	for itemID, data in pairs(desc) do
		descData[itemID] = descData[itemID] or {}
		if modifiers[itemID] then
			Mod:AddToDictionary(descData[itemID], modifiers[itemID])
		end
		descData[itemID][lang] = data
	end
end

return descData
