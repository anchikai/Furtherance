local Mod = Furtherance

local EXSANGUINATION = {}

Furtherance.Item.EXSANGUINATION = EXSANGUINATION

EXSANGUINATION.ID = Isaac.GetItemIdByName("Exsanguination")

EXSANGUINATION.DAMAGE_MULT = 0.1
EXSANGUINATION.HEART_REMOVAL_CHANCE = 0.5

---@param heart EntityPickup
---@param collider Entity
function EXSANGUINATION:PickupHeart(heart, collider)
	local player = collider:ToPlayer()
	if not player or not player:HasCollectible(EXSANGUINATION.ID) then return end

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

---@param entType EntityType
---@param variant PickupVariant
---@param spawner Entity
---@param seed integer
function EXSANGUINATION:PreHeartSpawn(entType, variant, _, _, _, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_HEART
		and PlayerManager.AnyoneHasCollectible(EXSANGUINATION.ID)
	then
		local floor_save = Mod:FloorSave()
		local key = tostring(seed)
		floor_save.ExsanguinationRoll = floor_save.ExsanguinationRoll or {}
		if floor_save.ExsanguinationRoll[key] then
			return
		end
		if spawner and spawner:ToPlayer() then
			floor_save.ExsanguinationRoll[key] = true
			return
		end
		local rng = RNG(seed)
		if rng:RandomFloat() <= EXSANGUINATION.HEART_REMOVAL_CHANCE then
			return {1000, Mod.REPLACER_EFFECT, 0, seed}
		else
			floor_save.ExsanguinationRoll[key] = true
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, CallbackPriority.IMPORTANT, EXSANGUINATION.PreHeartSpawn)
