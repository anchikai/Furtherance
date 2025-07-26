local Mod = Furtherance

local EXSANGUINATION = {}

Furtherance.Item.EXSANGUINATION = EXSANGUINATION

EXSANGUINATION.ID = Isaac.GetItemIdByName("Exsanguination")

EXSANGUINATION.DAMAGE_UP = 0.05
EXSANGUINATION.HEART_REMOVAL_CHANCE = 0.5

---@param heart EntityPickup
---@param collider Entity
function EXSANGUINATION:PickupHeart(heart, collider)
	local player = collider:ToPlayer()
	if not player or not player:HasCollectible(EXSANGUINATION.ID) then return end

	if heart:IsDead() then
		player:GetEffects():AddCollectibleEffect(EXSANGUINATION.ID)
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, EXSANGUINATION.PickupHeart, PickupVariant.PICKUP_HEART)

---@param player EntityPlayer
function EXSANGUINATION:DamageUp(player)
	if player:HasCollectible(EXSANGUINATION.ID) then
		local num = player:GetEffects():GetCollectibleEffectNum(EXSANGUINATION.ID)
		player.Damage = player.Damage + (num * EXSANGUINATION.DAMAGE_UP) * Mod:GetPlayerDamageMultiplier(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, EXSANGUINATION.DamageUp, CacheFlag.CACHE_DAMAGE)

---@param pickup EntityPickup
function EXSANGUINATION:OnHeartInit(pickup)
	if PlayerManager.AnyoneHasCollectible(EXSANGUINATION.ID)
		and pickup.FrameCount == 1
		--Making sure its not already disappearing
		and pickup.Timeout == -1
		and pickup:GetSprite():IsPlaying("Appear")
		and not (pickup.SpawnerEntity and pickup.SpawnerEntity:ToPlayer())
	then
		local rng = PlayerManager.FirstCollectibleOwner(EXSANGUINATION.ID):GetCollectibleRNG(EXSANGUINATION.ID)
		if rng:RandomFloat() <= EXSANGUINATION.HEART_REMOVAL_CHANCE then
			pickup.Timeout = 60
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, EXSANGUINATION.OnHeartInit, PickupVariant.PICKUP_HEART)