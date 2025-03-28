local Mod = Furtherance

function Mod:UseKeyCard(card, player, useflags)
	Isaac.GridSpawn(GridEntityType.GRID_STAIRS, 2, player.Position, true)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseKeyCard, CARD_KEY)
