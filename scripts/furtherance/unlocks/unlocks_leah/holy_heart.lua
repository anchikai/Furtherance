local Mod = Furtherance

local HOLY_HEART = {}

Furtherance.Trinket.HOLY_HEART = HOLY_HEART

HOLY_HEART.ID = Isaac.GetTrinketIdByName("Holy Heart")

HOLY_HEART.HeartMantleChance = {
	[HeartSubType.HEART_ETERNAL] = 3,
	[HeartSubType.HEART_SOUL] = 20,
	[HeartSubType.HEART_BLENDED] = 20,
	[HeartSubType.HEART_HALF_SOUL] = 50,
}

---@param pickup EntityPickup
---@param collider Entity
function HOLY_HEART:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and player:HasTrinket(HOLY_HEART.ID)
		and (player:CanPickSoulHearts()
			or pickup.SubType == HeartSubType.HEART_ETERNAL
			or (pickup.SubType == HeartSubType.HEART_BLENDED
				and player:CanPickRedHearts())
		)
		and Mod:CanPlayerBuyShopItem(player, pickup)
		and HOLY_HEART.HeartMantleChance[pickup.SubType]
	then
		local rng = player:GetTrinketRNG(HOLY_HEART.ID)
		if rng:RandomInt(HOLY_HEART.HeartMantleChance[pickup.SubType]) == 0 then
			player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, HOLY_HEART.CollectHeart)
