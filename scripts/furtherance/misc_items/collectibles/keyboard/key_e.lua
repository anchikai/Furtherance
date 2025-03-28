local Mod = Furtherance

local E_KEY = {}

Furtherance.Item.KEY_E = E_KEY

E_KEY.ID = Isaac.GetItemIdByName("E Key")

---@param player EntityPlayer
function E_KEY:OnUse(_, _, player)
	local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, 0,
		player.Position, Vector.Zero, player):ToBomb()
	---@cast bomb EntityBomb
	bomb:AddTearFlags(player:GetBombFlags())
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, E_KEY.OnUse, E_KEY.ID)
