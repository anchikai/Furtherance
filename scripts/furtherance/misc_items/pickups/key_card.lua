local Mod = Furtherance

local KEY_CARD = {}

Furtherance.Card.KEY_CARD = KEY_CARD

KEY_CARD.ID = Isaac.GetCardIdByName("Key Card")

function KEY_CARD:OnUse(_, player, _)
	Isaac.GridSpawn(GridEntityType.GRID_STAIRS, 2, player.Position, true)
end

Mod:AddCallback(ModCallbacks.MC_USE_CARD, KEY_CARD.OnUse, KEY_CARD.ID)
