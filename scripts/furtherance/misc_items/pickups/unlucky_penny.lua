local Mod = Furtherance

local UNLUCKY_PENNY = {}

Furtherance.Pickup.UNLUCKY_PENNY = UNLUCKY_PENNY

UNLUCKY_PENNY.ID = Isaac.GetEntitySubTypeByName("Unlucky Penny")

UNLUCKY_PENNY.REPLACE_CHANCE = 0.5

---@param entType EntityType
---@param variant PickupVariant
---@param subtype integer
---@param spawner Entity
---@param seed integer
function UNLUCKY_PENNY:SpawnChargedBomb(entType, variant, subtype, _, _, spawner, seed)
	if entType == EntityType.ENTITY_PICKUP
		and variant == PickupVariant.PICKUP_COIN
		and subtype == CoinSubType.COIN_LUCKYPENNY
	then
		local rng = RNG(seed)
		if rng:RandomFloat() <= UNLUCKY_PENNY.REPLACE_CHANCE then
			return { entType, variant, UNLUCKY_PENNY.ID, seed }
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_ENTITY_SPAWN, UNLUCKY_PENNY.SpawnChargedBomb)

---@param pickup EntityPickup
---@param collider Entity
function UNLUCKY_PENNY:UnluckyPenny(pickup, collider)
	local player = collider:ToPlayer()
	if player and pickup.SubType == UNLUCKY_PENNY.ID then
		local player_run_save = Mod:RunSave(player)
		Mod.SFXMan:Play(SoundEffect.SOUND_LUCKYPICKUP, 1, 2, false, 0.8)
		player_run_save.UnluckyPennyStat = (player_run_save.UnluckyPennyStat or 0) + 1
		player:AddCacheFlags(CacheFlag.CACHE_DAMAGE)
		player:AddCacheFlags(CacheFlag.CACHE_LUCK)
		player:EvaluateItems()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_COLLISION, UNLUCKY_PENNY.UnluckyPenny, PickupVariant.PICKUP_COIN)

---@param pickup EntityPickup
function UNLUCKY_PENNY:PickupSound(pickup)
	if pickup.SubType == UNLUCKY_PENNY.ID and pickup:GetSprite():IsEventTriggered("DropSound") then
		Mod.SFXMan:Play(SoundEffect.SOUND_PENNYDROP)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, UNLUCKY_PENNY.PickupSound, PickupVariant.PICKUP_COIN)

---@param player EntityPlayer
---@param flag CacheFlag
function UNLUCKY_PENNY:Lucknt(player, flag)
	local player_run_save = Mod:RunSave(player)
	if not player_run_save.UnluckyPennyStat then return end

	if flag == CacheFlag.CACHE_DAMAGE then
		player.Damage = player.Damage + (player_run_save.UnluckyPennyStat / 2)
	end
	if flag == CacheFlag.CACHE_LUCK then
		player.Luck = player.Luck - player_run_save.UnluckyPennyStat
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, UNLUCKY_PENNY.Lucknt, CacheFlag.CACHE_DAMAGE)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, UNLUCKY_PENNY.Lucknt, CacheFlag.CACHE_LUCK)
