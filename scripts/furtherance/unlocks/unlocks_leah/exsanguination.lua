local Mod = Furtherance

local EXSANGUINATION = {}

Furtherance.Item.EXSANGUINATION = EXSANGUINATION

EXSANGUINATION.ID = Isaac.GetItemIdByName("Exsanguination")
EXSANGUINATION.DAMAGE_MULT = 0.1

---@param heart EntityPickup
---@param collider Entity
function EXSANGUINATION:PickupHeart(heart, collider)
	local player = collider:ToPlayer()
	if not player or not player:HasCollectible(EXSANGUINATION.ID) then return end

	local data = Mod:GetData(player)
	if Mod.Core.HEARTS:CanCollectHeart(player, heart.SubType) then
		player:GetEffects():AddCollectibleEffect(EXSANGUINATION.ID)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, EXSANGUINATION.PickupHeart, PickupVariant.PICKUP_HEART)

function EXSANGUINATION:DamageUp(player)
	if player:HasCollectible(EXSANGUINATION.ID) then
		player.Damage = player.Damage + (player:GetEffects():GetCollectibleEffectNum(EXSANGUINATION.ID) * EXSANGUINATION.DAMAGE_MULT)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EXSANGUINATION.DamageUp, CacheFlag.CACHE_DAMAGE)

---@param heart EntityPickup
function EXSANGUINATION:DecreaseHeartSpawns(heart)
	local player = PlayerManager.FirstCollectibleOwner(EXSANGUINATION.ID)
	if player then
		local rng = heart:GetDropRNG()
		if rng:RandomFloat() <= 0.5 then
			heart:Remove()
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_INIT, EXSANGUINATION.DecreaseHeartSpawns, PickupVariant.PICKUP_HEART)
