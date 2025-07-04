local Mod = Furtherance
local FR_EID = Mod.EID_Support
local DD = FR_EID.DynamicDescriptions

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
		_modifier = function(itemID, desc)
			local power = Mod.Item.OLD_CAMERA.GHOST_AMOUNT[itemID]
			return { desc:format(power) }
		end
	}
}

local descriptions = {
	en_us = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_en_us")(modifiers),
	spa = Mod.Include("scripts.compatibility.patches.eid.eid_cards.cards_spa")(modifiers),
}

local allDescData = {}
for lang, desc in pairs(descriptions) do
	for cardID, data in pairs(desc) do
		allDescData[cardID] = allDescData[cardID] or {}
		if modifiers[cardID] then
			Mod:AddToDictionary(allDescData[cardID], modifiers[cardID])
		end
		allDescData[cardID][lang] = data
	end
end

for id, cardDescData in pairs(allDescData) do
	for language, descData in pairs(cardDescData) do
		if language:match('^_') then goto continue end -- skip helper private fields

		local name = descData.Name
		local description = descData.Description
		local metadata = cardDescData._metadata

		if not DD:IsValidDescription(description) then
			Mod:Log("Invalid card description for " .. name .. " (" .. id .. ")", "Language: " .. language)
			goto continue
		end

		local minimized = DD:MakeMinimizedDescription(description)

		if not DD:ContainsFunction(minimized) and not cardDescData._AppendToEnd then
			EID:addCard(id, table.concat(minimized, ""), name, language)
		else
			-- don't add descriptions for vanilla cards that already have one
			if not EID.descriptions[language].cards[id] then
				EID:addCard(id, "", name, language) -- description only contains name/language, the actual description is generated at runtime
			end

			DD:SetCallback(DD:CreateCallback(minimized, cardDescData._AppendToEnd), EntityType.ENTITY_PICKUP,
				PickupVariant.PICKUP_TAROTCARD, id, language)
		end

		if metadata then
			EID:addCardMetadata(id, metadata[1], metadata[2])
		end

		::continue::
	end
end

EID:addTarotClothBuffsCondition(Mod.Card.HOPE.ID, nil, 20)
EID:addTarotClothBuffsCondition(Mod.Card.CHARITY.ID, nil, 3)
