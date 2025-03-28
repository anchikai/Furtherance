local Mod = Furtherance

function Mod:GetPallas(player, flag)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_PALLAS) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_HYDROBOUNCE | TearFlags.TEAR_POP
		end
		if (player and player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE)) then
			if flag == CacheFlag.CACHE_DAMAGE then
				player.Damage = player.Damage * 1.16
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.GetPallas)

function Mod:TearSize(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and player:HasCollectible(CollectibleType.COLLECTIBLE_PALLAS) then
		if player:HasCollectible(CollectibleType.COLLECTIBLE_FLAT_STONE) then
			tear.Scale = tear.Scale * 2
		else
			tear.Scale = tear.Scale * 1.2
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.TearSize, CollectibleType.COLLECTIBLE_PALLAS)
