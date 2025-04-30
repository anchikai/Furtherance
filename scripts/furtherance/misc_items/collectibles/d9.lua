local Mod = Furtherance

local D9 = {}

Furtherance.Item.D9 = D9

D9.ID = Isaac.GetItemIdByName("D9")

function D9:UseD9()
	Mod.Foreach.Pickup(function (pickup, index)
		pickup:Morph(pickup.Type, pickup.Variant, NullPickupSubType.ANY)
	end, PickupVariant.PICKUP_TRINKET)
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, D9.UseD9, D9.ID)
