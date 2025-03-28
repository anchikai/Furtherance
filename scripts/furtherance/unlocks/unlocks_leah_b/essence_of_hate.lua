local Mod = Furtherance

function Mod:UseEssenceOfHate(card, player, flag)
	local BrokenHearts = 11 - player:GetBrokenHearts()
	player:AddBrokenHearts(11 - player:GetBrokenHearts())
	for i = 1, BrokenHearts do
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_NULL, 0,
			Isaac.GetFreeNearPosition(player.Position, 40), Vector.Zero, player)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseEssenceOfHate, RUNE_ESSENCE_OF_HATE)
