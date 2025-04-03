local Mod = Furtherance

local DADS_WALLET = {}

Furtherance.Item.DADS_WALLET = DADS_WALLET

DADS_WALLET.ID = Isaac.GetItemIdByName("Dad's Wallet")

DADS_WALLET.DEFAULT_UNLOCK_BACKUP = {
	Card.CARD_EMERGENCY_CONTACT,
	Card.CARD_DICE_SHARD,
}

DADS_WALLET.CARD_DROPS = {
	Card.CARD_CREDIT,
	Card.CARD_HUMANITY,
	Card.CARD_GET_OUT_OF_JAIL,
	Card.CARD_HOLY,
	Card.CARD_WILD,
	Card.CARD_EMERGENCY_CONTACT,
	Card.CARD_DICE_SHARD,
	Card.CARD_CRACKED_KEY
}

---@param itemID CollectibleType
---@param firstTime boolean
---@param player EntityPlayer
function DADS_WALLET:OnFirstPickup(itemID, _, firstTime, _, _, player)
	if firstTime then
		local rng = player:GetCollectibleRNG(itemID)
		for _ = 1, 2 do
			local card = DADS_WALLET.CARD_DROPS[rng:RandomInt(#DADS_WALLET.CARD_DROPS) + 1]
			local cardConfig = Mod.ItemConfig:GetCard(card)
			if not Mod.PersistGameData:Unlocked(cardConfig.AchievementID) then
				card = DADS_WALLET.DEFAULT_UNLOCK_BACKUP[rng:RandomInt(#DADS_WALLET.DEFAULT_UNLOCK_BACKUP) + 1]
			end
			Mod.Game:Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TAROTCARD, Mod.Room():FindFreePickupSpawnPosition(player.Position),
			Vector.Zero, player, card, rng:GetSeed())
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ADD_COLLECTIBLE, DADS_WALLET.OnFirstPickup, DADS_WALLET.ID)