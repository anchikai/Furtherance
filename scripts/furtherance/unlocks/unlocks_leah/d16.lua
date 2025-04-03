local Mod = Furtherance

local D16 = {}

Furtherance.Item.D16 = D16

D16.ID = Isaac.GetItemIdByName("D16")

function D16:OnUse(itemID, rng, player, flags, slot)
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
		if not Mod.Card.ACE_OF_SHIELDS.BlacklistedPickupVariants[ent.Variant] then
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			pickup:Morph(ent.Type, PickupVariant.PICKUP_HEART, NullPickupSubType.ANY)
		end
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, D16.OnUse, D16.ID)