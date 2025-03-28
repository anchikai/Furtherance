local MOD = Furtherance

function MOD:USEPLUGNPLAY(_, _, PLAYER)
	local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, 0, Isaac.GetFreeNearPosition(PLAYER.Position, 40), Vector.Zero, PLAYER)
	pickup:AddEntityFlags(EntityFlag.FLAG_GLITCH)
	return true
end
MOD:AddCallback(ModCallbacks.MC_USE_ITEM, MOD.USEPLUGNPLAY, CollectibleType.COLLECTIBLE_NEASS)