local Mod = Furtherance

function Mod:UseTrapCard(card, player, useflags)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, UseFlag.USE_NOANIM, -1)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, Mod.UseTrapCard, CARD_TRAP)
