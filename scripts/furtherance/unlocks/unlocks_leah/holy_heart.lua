local Mod = Furtherance

local HOLY_HEART = {}

Furtherance.Trinket.HOLY_HEART = HOLY_HEART

HOLY_HEART.ID = Isaac.GetTrinketIdByName("Holy Heart")

HOLY_HEART.HeartMantleChance = {
	[HeartSubType.HEART_ETERNAL] = 0.33,
	[HeartSubType.HEART_SOUL] = 0.05,
	[HeartSubType.HEART_BLENDED] = 0.05,
	[HeartSubType.HEART_HALF_SOUL] = 0.02,
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
		if rng:RandomFloat() <= HOLY_HEART.HeartMantleChance[pickup.SubType] then
			player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, HOLY_HEART.CollectHeart)
