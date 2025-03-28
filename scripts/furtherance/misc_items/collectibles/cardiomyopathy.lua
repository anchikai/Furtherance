local Mod = Furtherance

Mod.CardiomypathyHeartVariants = {
	[HeartSubType.HEART_HALF] = true,
	[HeartSubType.HEART_FULL] = true,
	[HeartSubType.HEART_DOUBLEPACK] = true,
	[HeartSubType.HEART_SCARED] = true,
}

---@param pickup EntityPickup
---@param collider Entity
function Mod:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player then
		local data = Mod:GetData(player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CARDIOMYOPATHY)
			and player:CanPickRedHearts()
			and Mod.CardiomypathyHeartVariants[pickup.SubType]
		then
			player:SetMinDamageCooldown(30)
			local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CARDIOMYOPATHY)
			if rng:RandomFloat() <= Mod:Clamp(player.Luck / 20, 0.05, 0.25) then
				player:AddMaxHearts(2)
			end
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, Mod.CollectHeart,
PickupVariant.PICKUP_HEART)

function Mod:UpdateHP(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CARDIOMYOPATHY) and player:GetBoneHearts() > 0 then
		player:AddBoneHearts(-player:GetBoneHearts())
		player:AddMaxHearts(player:GetBoneHearts() * 2, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.UpdateHP)
