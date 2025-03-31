local Mod = Furtherance

local HEARTACHE = {}

Furtherance.Pill.HEARTACHE = HEARTACHE

HEARTACHE.ID_UP = Isaac.GetPillEffectByName("Heartache Up")
HEARTACHE.ID_DOWN = Isaac.GetPillEffectByName("Heartache Down")

function HEARTACHE:HeartacheUp(pill, player, flags)
	player:AnimateSad()
	player:AddBrokenHearts(1)
end

Mod:AddCallback(ModCallbacks.MC_USE_PILL, HEARTACHE.HeartacheUp, HEARTACHE.ID_UP)

function HEARTACHE:HeartacheDown(pill, player, flags)
	player:AnimateHappy()
	player:AddBrokenHearts(-1)
end

Mod:AddCallback(ModCallbacks.MC_USE_PILL, HEARTACHE.HeartacheDown, HEARTACHE.ID_DOWN)
