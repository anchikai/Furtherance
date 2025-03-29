local Mod = Furtherance

local CARDIOMYOPATHY = {}

Furtherance.Item.CARDIOMYOPATHY = CARDIOMYOPATHY

CARDIOMYOPATHY.ID = Isaac.GetItemIdByName("Cardiomypathy")

CARDIOMYOPATHY.HeartVariants = {
	[HeartSubType.HEART_HALF] = true,
	[HeartSubType.HEART_FULL] = true,
	[HeartSubType.HEART_DOUBLEPACK] = true,
	[HeartSubType.HEART_SCARED] = true,
}

---@param pickup EntityPickup
---@param collider Entity
function CARDIOMYOPATHY:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and player:HasCollectible(CARDIOMYOPATHY.ID)
		and player:CanPickRedHearts()
		and CARDIOMYOPATHY.HeartVariants[pickup.SubType]
	then
		player:SetMinDamageCooldown(30)
		local rng = player:GetCollectibleRNG(CARDIOMYOPATHY.ID)
		if rng:RandomFloat() <= Mod:Clamp(player.Luck / 20, 0.05, 0.25) then
			player:AddMaxHearts(2)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, CARDIOMYOPATHY.CollectHeart, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
---@param amount integer
function CARDIOMYOPATHY:ConvertBoneHearts(player, amount)
	if amount > 0 and player:HasCollectible(CARDIOMYOPATHY.ID) and player:GetHealthType() ~= HealthType.BONE then
		player:AddMaxHearts(amount * 2)
		return 0
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_ADD_HEARTS, CARDIOMYOPATHY.ConvertBoneHearts, AddHealthType.BONE)

---@param player EntityPlayer
function CARDIOMYOPATHY:ReplaceBoneHearts(player)
	local numBoneHearts = player:GetBoneHearts()
	if player:HasCollectible(CARDIOMYOPATHY.ID) and numBoneHearts > 0 then
		player:AddBoneHearts(-numBoneHearts)
		player:AddMaxHearts(numBoneHearts * 2, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CARDIOMYOPATHY.ReplaceBoneHearts)
