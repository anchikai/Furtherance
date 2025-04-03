local Mod = Furtherance

local PETER = {}

Furtherance.Character.PETER = PETER

---@param player EntityPlayer
function PETER:OnInit(player)
	player:SetPocketActiveItem(Mod.Item.KEYS_TO_THE_KINGDOM.ID)
	player:AddTrinket(Mod.Trinket.ALABASTER_SCRAP.ID)
end

Mod:AddCallback(ModCallbacks.MC_PLAYER_INIT_POST_LEVEL_INIT_STATS, PETER.OnInit, Mod.PlayerType.PETER)