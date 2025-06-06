local Mod = Furtherance

local CARDIOMYOPATHY = {}

Furtherance.Item.CARDIOMYOPATHY = CARDIOMYOPATHY

CARDIOMYOPATHY.ID = Isaac.GetItemIdByName("Cardiomyopathy")

CARDIOMYOPATHY.INVULNERABILITY_DURATION = 30
CARDIOMYOPATHY.SHIELD_CHANCE = 0.33
CARDIOMYOPATHY.MAX_LUCK = 20
CARDIOMYOPATHY.MIN_CHANCE = 0.01
CARDIOMYOPATHY.MAX_CHANCE = 0.20

---@param pickup EntityPickup
---@param collider Entity
function CARDIOMYOPATHY:CollectHeart(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and player:HasCollectible(CARDIOMYOPATHY.ID)
		and player:CanPickRedHearts()
		and Mod.Core.HEARTS.RedHearts[pickup.Variant]
	then
		local rng = player:GetCollectibleRNG(CARDIOMYOPATHY.ID)
		if rng:RandomFloat() <= CARDIOMYOPATHY.SHIELD_CHANCE then
			player:AddCollectibleEffect(CollectibleType.COLLECTIBLE_BOOK_OF_SHADOWS, true, CARDIOMYOPATHY.INVULNERABILITY_DURATION * Mod.Core.HEARTS.HeartAmount[pickup.Variant])
		end
		if rng:RandomFloat() <= Mod:Clamp(player.Luck / CARDIOMYOPATHY.MAX_LUCK, CARDIOMYOPATHY.MIN_CHANCE, CARDIOMYOPATHY.MAX_CHANCE) then
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
