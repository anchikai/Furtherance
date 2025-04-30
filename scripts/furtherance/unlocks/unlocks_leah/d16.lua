local Mod = Furtherance

local D16 = {}

Furtherance.Item.D16 = D16

D16.ID = Isaac.GetItemIdByName("D16")

function D16:OnUse()
	Mod.Foreach.Pickup(function (pickup, index)
		if not Mod.Card.ACE_OF_SHIELDS.BlacklistedPickupVariants[pickup.Variant] then
			pickup:Morph(pickup.Type, PickupVariant.PICKUP_HEART, NullPickupSubType.ANY)
		end
	end)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, D16.OnUse, D16.ID)