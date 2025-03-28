local Mod = Furtherance

function Mod:GetOphiuchus(player, flag)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_OPHIUCHUS) then
		if flag == CacheFlag.CACHE_TEARFLAG then
			player.TearFlags = player.TearFlags | TearFlags.TEAR_WIGGLE | TearFlags.TEAR_SPECTRAL
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage +
			(0.3 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_OPHIUCHUS, false))
		end
		if flag == CacheFlag.CACHE_FIREDELAY then
			player.MaxFireDelay = player.MaxFireDelay + player.FireDelay
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.GetOphiuchus)
