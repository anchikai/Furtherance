local Mod = Furtherance

function Mod:GetVesta(player, flag)
	if player:HasCollectible(CollectibleType.COLLECTIBLE_VESTA) then
		local rng = player:GetCollectibleRNG(CollectibleType.COLLECTIBLE_VESTA)
		if rng:RandomInt(100) + 1 <= player.Luck * 10 + 10 then
			if flag == CacheFlag.CACHE_TEARFLAG then
				player.TearFlags = player.TearFlags | TearFlags.TEAR_SPECTRAL | TearFlags.TEAR_QUADSPLIT
			end
		end
		if flag == CacheFlag.CACHE_DAMAGE then
			player.Damage = player.Damage * 1.5
		end
		if flag == CacheFlag.CACHE_TEARCOLOR then
			player.TearColor = Color(1, 1, 1, 0.8, 0, 0, 0)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, Mod.GetVesta)

function Mod:tearSize(tear)
	local player = tear.Parent:ToPlayer()
	if player:HasCollectible(CollectibleType.COLLECTIBLE_VESTA) then
		if player:HasTrinket(TrinketType.TRINKET_PULSE_WORM) then
			tear.Scale = tear.Scale * 0.22
		else
			local sprite = tear:GetSprite()
			tear.Scale = tear.Scale * 0
			sprite:Load("gfx/tear_vesta.anm2", true)
			sprite:Play("Rotate0", true)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.tearSize)
