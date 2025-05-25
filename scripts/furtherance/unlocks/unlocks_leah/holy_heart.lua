local Mod = Furtherance

local HOLY_HEART = {}

Furtherance.Trinket.HOLY_HEART = HOLY_HEART

HOLY_HEART.ID = Isaac.GetTrinketIdByName("Holy Heart")

HOLY_HEART.HeartMantleChance = {
	[HeartSubType.HEART_ETERNAL] = 1,
	[HeartSubType.HEART_SOUL] = 1,
	[HeartSubType.HEART_BLACK] = 1,
	[HeartSubType.HEART_BLENDED] = 0.5,
	[HeartSubType.HEART_HALF_SOUL] = 0.5,
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
		local mantleChance = HOLY_HEART.HeartMantleChance[pickup.SubType]
		local result = Isaac.RunCallbackWithParam(Mod.ModCallbacks.HOLY_HEART_GET_MANTLE_CHANCE, pickup.SubType, pickup, player, mantleChance)
		if result and type(result) == "number" then
			mantleChance = result
		end
		if rng:RandomFloat() <= mantleChance then
			player:UseCard(Card.CARD_HOLY, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, HOLY_HEART.CollectHeart)

function HOLY_HEART:BlendedHeart(pickup, player, chance)
	--Can only collect it
	if player:GetHearts() == (player:GetEffectiveMaxHearts() - 1) then
		chance = 0.05
	end
	return chance
end

Mod:AddCallback(Mod.ModCallbacks.HOLY_HEART_GET_MANTLE_CHANCE, HOLY_HEART.BlendedHeart, HeartSubType.HEART_BLENDED)