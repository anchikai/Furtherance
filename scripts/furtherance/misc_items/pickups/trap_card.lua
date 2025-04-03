local Mod = Furtherance

local TRAP_CARD = {}

Furtherance.Card.TRAP_CARD = TRAP_CARD

TRAP_CARD.ID = Isaac.GetCardIdByName("Trap Card")

function TRAP_CARD:UseTrapCard(_, player, _)
	player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, UseFlag.USE_NOANIM, -1)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, TRAP_CARD.UseTrapCard, TRAP_CARD.ID)
