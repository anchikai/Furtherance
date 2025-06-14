local Mod = Furtherance

local HOLY_HEART = {}

Furtherance.Trinket.HOLY_HEART = HOLY_HEART

HOLY_HEART.ID = Isaac.GetTrinketIdByName("Holy Heart")

---@param pickup EntityPickup
---@param collider Entity
function HOLY_HEART:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and player:HasTrinket(HOLY_HEART.ID)
		and (
			Mod.HeartGroups.Soul[pickup.SubType]
			or Mod.HeartGroups.Black[pickup.SubType]
			or Mod.HeartGroups.Eternal[pickup.SubType]
		)
		and Mod:CanCollectHeart(player, pickup.SubType)
		and Mod:CanPlayerBuyShopItem(player, pickup)
	then
		local rng = player:GetTrinketRNG(HOLY_HEART.ID)
		local mantleChance = player:GetTrinketMultiplier(HOLY_HEART.ID) > 1 and 1 or math.max((Mod.HeartAmount[pickup.SubType] or 2) / 2)
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

---@param pickup EntityPickup
---@param player EntityPlayer
---@param chance number
function HOLY_HEART:BlendedHeart(pickup, player, chance)
	--Can only collect it
	if player:GetHearts() == (player:GetEffectiveMaxHearts() - 1) then
		chance = 0.5
	elseif player:CanPickRedHearts() then
		chance = 0
	end
	return chance
end

Mod:AddCallback(Mod.ModCallbacks.HOLY_HEART_GET_MANTLE_CHANCE, HOLY_HEART.BlendedHeart, HeartSubType.HEART_BLENDED)