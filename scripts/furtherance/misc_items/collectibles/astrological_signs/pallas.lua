local Mod = Furtherance

local PALLAS = {}

Furtherance.Item.PALLAS = PALLAS

PALLAS.ID = Isaac.GetItemIdByName("Pallas?")

PALLAS.FLAT_STONE_DAMAGE_BONUS = 1.16
PALLAS.TEAR_SCALE = 1.2
PALLAS.FLAT_STONE_TEAR_SCALE = 2

---@param player EntityPlayer
---@param flag CacheFlag
function PALLAS:GetPallas(player, flag)
	if player:HasCollectible(PALLAS.ID) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HYDROBOUNCE | TearFlags.TEAR_POP
		end
		if (player and player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE))
			and flag == CacheFlag.CACHE_DAMAGE
		then
			player.Damage = player.Damage * PALLAS.FLAT_STONE_DAMAGE_BONUS
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PALLAS.GetPallas, CacheFlag.CACHE_DAMAGE)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PALLAS.GetPallas, CacheFlag.CACHE_TEARFLAG)

function PALLAS:TearSize(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(PALLAS.ID) then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
			tear.Scale = tear.Scale * PALLAS.FLAT_STONE_TEAR_SCALE
		else
			tear.Scale = tear.Scale * PALLAS.TEAR_SCALE
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, PALLAS.TearSize)
