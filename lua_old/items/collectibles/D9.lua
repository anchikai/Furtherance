local mod = Furtherance
local game = Game()

function mod:UseD9(_, _, player)
	local itemPool = game:GetItemPool()
	for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TRINKET)) do
		local trinket = itemPool:GetTrinket()
		entity:ToPickup():Morph(entity.Type, entity.Variant, trinket)
	end
	return true
end

mod:AddCallback(ModCallbacks.MC_USE_ITEM, mod.UseD9, CollectibleType.COLLECTIBLE_D9)
