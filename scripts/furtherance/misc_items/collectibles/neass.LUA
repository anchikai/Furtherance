local MOD = Furtherance

local PLUG_N_PLAY = {}

Furtherance.Item.PLUG_N_PLAY = PLUG_N_PLAY

PLUG_N_PLAY.ID = Isaac.GetItemIdByName("Plug N' Play")

---@param PLAYER EntityPlayer
function PLUG_N_PLAY:USEPLUGNPLAY(_, _, PLAYER)
	local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, Isaac.GetFreeNearPosition(PLAYER.Position, 40), Vector.Zero, PLAYER)
	pickup:AddEntityFlags(EntityFlag.FLAG_GLITCH)
	return true
end
MOD:AddCallback(ModCallbacks.MC_USE_ITEM, PLUG_N_PLAY.USEPLUGNPLAY, PLUG_N_PLAY.ID)