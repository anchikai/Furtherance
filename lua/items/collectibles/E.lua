local mod = Furtherance

---@param player EntityPlayer
function mod:UseE(_, _, player)
	local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, 0, player.Position, Vector.Zero, player):ToBomb()
	---@cast bomb EntityBomb
	bomb:AddTearFlags(player:GetBombFlags())
	return true
end
mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseE, CollectibleType.COLLECTIBLE_E_KEY)