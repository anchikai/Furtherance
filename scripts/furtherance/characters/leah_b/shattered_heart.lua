local Mod = Furtherance

function Mod:UseHeartRen(_, _, player, flags)
	if player:GetBrokenHearts() > 0 then
		SFXManager():Play(SoundEffect.SOUND_HEARTBEAT)
		player:AddBrokenHearts(-1)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseHeartRen, CollectibleType.COLLECTIBLE_SHATTERED_HEART)
