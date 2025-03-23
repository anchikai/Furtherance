local mod = Furtherance

mod.CardiomypathyHeartVariants = {
	[HeartSubType.HEART_HALF] = true,
	[HeartSubType.HEART_FULL] = true,
	[HeartSubType.HEART_DOUBLEPACK] = true,
	[HeartSubType.HEART_SCARED] = true,
}

---@param pickup EntityPickup
---@param collider Entity
function mod:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player then
		local data = mod:GetData(player)
		if player:HasCollectible(CollectibleType.COLLECTIBLE_CARDIOMYOPATHY)
			and player:CanPickRedHearts()
			and mod.CardiomypathyHeartVariants[pickup.SubType]
		then
			player:SetMinDamageCooldown(30)
			local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_CARDIOMYOPATHY)
			if rng:RandomFloat() <= mod:Clamp(player.Luck / 20, 0.05, 0.25) then
				player:AddMaxHearts(2)
			end
		end
	end
end

mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.LATE, mod.CollectHeart, PickupVariant.PICKUP_HEART)

function mod:UpdateHP(player)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_CARDIOMYOPATHY) and player:GetBoneHearts() > 0 then
		player:AddBoneHearts(-player:GetBoneHearts())
		player:AddMaxHearts(player:GetBoneHearts() * 2, true)
	end
end

mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.UpdateHP)
