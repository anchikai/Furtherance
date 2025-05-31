local Mod = Furtherance
local FR_EID = Mod.EID_Support

local modifiers = {
	[Mod.Card.ACE_OF_SHIELDS.ID] = {
		_metadata = { 12, false }
	},
	[Mod.Card.CHARITY.ID] = {
		_metadata = { 2, false }
	},
	[Mod.Card.FAITH.ID] = {
		_metadata = { 2, false }
	},
	[Mod.Card.GOLDEN_CARD.ID] = {
		_metadata = { 12, false }
	},
	[Mod.Card.HOPE.ID] = {
		_metadata = { 2, false }
	},
	[Mod.Card.KEY_CARD.ID] = {
		_metadata = { 6, false }
	},
	[Mod.Card.REVERSE_CHARITY.ID] = {
		_metadata = { 2, false }
	},
	[Mod.Card.REVERSE_FAITH.ID] = {
		_metadata = { 2, false }
	},
	[Mod.Card.REVERSE_HOPE.ID] = {
		_metadata = { 2, false }
	},
	[Mod.Card.TRAP_CARD.ID] = {
		_metadata = { 1, false }
	},
	[Mod.Card.TWO_OF_SHIELDS.ID] = {
		_metadata = { 12, false }
	},
	[Mod.Rune.ESSENCE_OF_DEATH.ID] = {
		_metadata = { 4, true }
	},
	[Mod.Rune.ESSENCE_OF_DELUGE.ID] = {
		_metadata = { 1, true }
	},
	[Mod.Rune.ESSENCE_OF_DROUGHT.ID] = {
		_metadata = { 2, true }
	},
	[Mod.Rune.ESSENCE_OF_HATE.ID] = {
		_metadata = { 6, true }
	},
	[Mod.Rune.ESSENCE_OF_LIFE.ID] = {
		_metadata = { 2, true }
	},
	[Mod.Rune.ESSENCE_OF_LOVE.ID] = {
		_metadata = { 3, true }
	},
	[Mod.Rune.SOUL_OF_LEAH.ID] = {
		_metadata = { 6, true },
		_modifier = function(descObj, desc)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			if player and player:GetHealthType() == HealthType.COIN then
				return "#{{Player" .. player:GetPlayerType() .. "}} " .. desc
			end
			return ""
		end
	},
	[Mod.Rune.SOUL_OF_MIRIAM.ID] = {
		_metadata = { 12, true }
	},
	[Mod.Rune.SOUL_OF_PETER.ID] = {
		_metadata = { 6, true }
	},
	[Mod.Item.OLD_CAMERA.PHOTO_IDs[1]] = {
		_modifier = function(descObj, desc, strength)
			local player = FR_EID:ClosestPlayerTo(descObj.Entity)
			local power = Mod.Item.OLD_CAMERA:GetGhostAmount(player, strength)
			if player:HasCollectible(CollectibleType.COLLECTIBLE_TAROT_CLOTH) then
				desc = desc:format("{{ColorShinyPurple}}%s{{CR}}")
			end
			return{ desc:format(power)}
		end
	}
}
local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_en_us")(modifiers),
}

local descData = {}
for lang, desc in pairs(descriptions) do
	for cardID, data in pairs(desc) do
		descData[cardID] = descData[cardID] or {}
		if modifiers[cardID] then
			Mod:AddToDictionary(descData[cardID], modifiers[cardID])
		end
		descData[cardID][lang] = data
	end
end

return descData
