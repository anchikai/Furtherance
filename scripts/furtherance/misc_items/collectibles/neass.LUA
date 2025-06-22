local Mod = Furtherance

local PLUG_N_PLAY = {}

Furtherance.Item.PLUG_N_PLAY = PLUG_N_PLAY

PLUG_N_PLAY.ID = Isaac.GetItemIdByName("Plug N' Play")

---@param player EntityPlayer
function PLUG_N_PLAY:USEPLUGNPLAY(_, _, player)
	local pickup = Mod.Spawn.Collectible(NullPickupSubType.ANY, Mod.Room():FindFreePickupSpawnPosition(player.Position, 40, true), player)
	pickup:AddEntityFlags(EntityFlag.FLAG_GLITCH)
	return true
end
Mod:AddCallback(ModCallbacks.MC_USE_ITEM, PLUG_N_PLAY.USEPLUGNPLAY, PLUG_N_PLAY.ID)