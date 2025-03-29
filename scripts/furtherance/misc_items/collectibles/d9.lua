local Mod = Furtherance

local D9 = {}

Furtherance.Item.D9 = D9

D9.ID = Isaac.GetItemIdByName("D9")

--Accept defeat that there are no original dice anymore

function D9:UseD9()
	local itemPool = Mod.Game:GetItemPool()
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
		local trinket = itemPool:GetTrinket()
		entity:ToPickup():Morph(entity.Type, entity.Variant, trinket)
	end
	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, D9.UseD9, D9.ID)
