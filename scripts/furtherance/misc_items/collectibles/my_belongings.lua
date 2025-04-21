local Mod = Furtherance

local MY_BELONGINGS = {}

Furtherance.Item.MY_BELONGINGS = MY_BELONGINGS

MY_BELONGINGS.ID = Isaac.GetItemIdByName("My Belongings")

MY_BELONGINGS.CARD_DROPS = {
	Card.CARD_HUGE_GROWTH,
	Card.CARD_ANCIENT_RECALL,
	Card.CARD_ERA_WALK,
	Card.CARD_HUMANITY,
	Card.CARD_GET_OUT_OF_JAIL,
	Card.CARD_HOLY,
	Card.CARD_WILD,
	Card.CARD_EMERGENCY_CONTACT,
	Card.CARD_DICE_SHARD,
	Card.CARD_CRACKED_KEY
}

MY_BELONGINGS.TRINKET_DROPS = {
	TrinketType.TRINKET_BIBLE_TRACT,
	TrinketType.TRINKET_PAPER_CLIP,
	TrinketType.TRINKET_MYSTERIOUS_CANDY,
	TrinketType.TRINKET_CARTRIDGE,
	TrinketType.TRINKET_ISAACS_FORK,
	TrinketType.TRINKET_LUCKY_ROCK,
	TrinketType.TRINKET_PUSH_PIN,
	TrinketType.TRINKET_RED_PATCH,
	TrinketType.TRINKET_RUSTED_KEY,
	TrinketType.TRINKET_CRACKED_DICE,
	TrinketType.TRINKET_FADED_POLAROID,
	TrinketType.TRINKET_SAFETY_SCISSORS,
	TrinketType.TRINKET_BAG_LUNCH,
	TrinketType.TRINKET_DIM_BULB,
	TrinketType.TRINKET_VIBRANT_BULB,
	TrinketType.TRINKET_DOOR_STOP,
	TrinketType.TRINKET_DUCT_TAPE,
	TrinketType.TRINKET_EXTENSION_CORD,
	TrinketType.TRINKET_HAIRPIN,
	TrinketType.TRINKET_LOST_CORK,
	TrinketType.TRINKET_SUPER_BALL,
	TrinketType.TRINKET_WOODEN_CROSS,
	TrinketType.TRINKET_BROKEN_GLASSES,
	TrinketType.TRINKET_BROKEN_MAGNET,
	TrinketType.TRINKET_CHEWED_PEN,
	TrinketType.TRINKET_DICE_BAG,
	TrinketType.TRINKET_JAW_BREAKER,
	TrinketType.TRINKET_OLD_CAPACITOR,
	TrinketType.TRINKET_RC_REMOTE,
	TrinketType.TRINKET_KIDS_DRAWING
}

---@param card Card
function MY_BELONGINGS:IsCardAvailable(card)
	local cardConfig = Mod.ItemConfig:GetCard(card)
	return Mod.PersistGameData:Unlocked(cardConfig.AchievementID)
end

---@param trinket TrinketType
function MY_BELONGINGS:IsTrinketAvailable(trinket)
	local trinketConfig = Mod.ItemConfig:GetTrinket(trinket)
	return Mod.PersistGameData:Unlocked(trinketConfig.AchievementID)
end

---@param itemID CollectibleType
---@param firstTime boolean
---@param player EntityPlayer
function MY_BELONGINGS:OnFirstPickup(itemID, _, firstTime, _, _, player)
	if firstTime then
		local cardList = {}
		for _, card in ipairs(MY_BELONGINGS.CARD_DROPS) do
			if MY_BELONGINGS:IsCardAvailable(card) then
				Mod:Insert(cardList, card)
			end
		end
		local trinketList = {}
		for _, trinket in ipairs(MY_BELONGINGS.TRINKET_DROPS) do
			if MY_BELONGINGS:IsCardAvailable(trinket) then
				Mod:Insert(trinketList, trinket)
			end
		end
		local rng = player:GetCollectibleRNG(itemID)
		local card = cardList[rng:RandomInt(#cardList) + 1]
		Mod.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Mod.Room():FindFreePickupSpawnPosition(player.Position),
		Vector.Zero, player, card, rng:GetSeed())
		for _ = 1, 2 do
			local index = rng:RandomInt(#trinketList) + 1
			local trinket = trinketList[index]
			Mod.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET, Mod.Room():FindFreePickupSpawnPosition(player.Position),
			Vector.Zero, player, trinket, rng:GetSeed())
			table.remove(trinketList, index)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, MY_BELONGINGS.OnFirstPickup, MY_BELONGINGS.ID)