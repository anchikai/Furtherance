local Mod = Furtherance

function Mod:HeartacheUp(pill, player, flags)
	player:AddBrokenHearts(1)
	player:AnimateSad()
end

Mod:AddCallback(ModCallbacks.MC_USE_PILL, Mod.HeartacheUp, PILLEFFECT_HEARTACHE_UP)

function Mod:HeartacheDown(pill, player, flags)
	player:AddBrokenHearts(-1)
	player:AnimateHappy()
end

Mod:AddCallback(ModCallbacks.MC_USE_PILL, Mod.HeartacheDown, PILLEFFECT_HEARTACHE_DOWN)
