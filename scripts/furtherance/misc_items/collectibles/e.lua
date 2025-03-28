local Mod = Furtherance

---@param player EntityPlayer
function Mod:UseE(_, _, player)
	local bomb = Isaac.Spawn(EntityType.ENTITY_BOMB, BombVariant.BOMB_GIGA, 0, player.Position, Vector.Zero, player)
	:ToBomb()
	---@cast bomb EntityBomb
	bomb:AddTearFlags(player:GetBombFlags())
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, Mod.UseE, CollectibleType.COLLECTIBLE_E_KEY)
