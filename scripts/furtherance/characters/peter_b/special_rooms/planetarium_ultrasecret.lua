local Mod = Furtherance

local function planetariumFlip()
	return RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_ULTRASECRET, Mod.Room():GetRoomShape(), -1, -1, 1, 10, 1)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, planetariumFlip, RoomType.ROOM_PLANETARIUM)

local function ultraSecretFlip()
	return RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_PLANETARIUM, Mod.Room():GetRoomShape(), -1, -1, 1, 10, 1)
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, ultraSecretFlip, RoomType.ROOM_ULTRASECRET)

local function postUltraSecretRoomFlip()
	if PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then return end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
		local pickup = ent:ToPickup()
		---@cast pickup EntityPickup
		Mod.Trinket.ALMAGEST_SCRAP:TurnToAlmagestShopItem(pickup)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, postUltraSecretRoomFlip, RoomType.ROOM_ULTRASECRET)