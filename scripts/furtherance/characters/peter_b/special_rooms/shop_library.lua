local Mod = Furtherance

local function shopRoomFlip()
	return Mod:GenerateReplacementRoomConfig(RoomType.ROOM_LIBRARY)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, shopRoomFlip, RoomType.ROOM_SHOP)

local function libraryRoomFlip()
	return Mod:GenerateReplacementRoomConfig(RoomType.ROOM_SHOP)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, libraryRoomFlip, RoomType.ROOM_LIBRARY)

local function libraryShop(_, newRoomType)
	if PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then return end
	if newRoomType == RoomType.ROOM_LIBRARY then
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			pickup:MakeShopItem(-1)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, libraryShop, RoomType.ROOM_SHOP)
