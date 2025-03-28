local Mod = Furtherance

function Mod:GetBrunch(player, flag)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_BRUNCH) then
		if flag == CacheFlag.CACHE_SHOTSPEED then
			player.ShotSpeed = player.ShotSpeed +
			(0.16 * player:GetCollectibleNum(CollectibleType.COLLECTIBLE_BRUNCH, false))
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.GetBrunch)
