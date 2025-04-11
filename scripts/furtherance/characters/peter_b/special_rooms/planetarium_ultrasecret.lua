local Mod = Furtherance

local function planetariumFlip()
	local roomConfigRoom
	--10 attempts
	for _ = 1, 10 do
		roomConfigRoom = RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_ULTRASECRET, Mod.Room():GetRoomShape(), -1, -1, 1, 10, 1)
		--Means there are literally no rooms that match. Abort!
		if not roomConfigRoom then return end
		if Mod:CanReplaceRoom(Mod.Level():GetCurrentRoomDesc(), roomConfigRoom) then
			return roomConfigRoom
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, planetariumFlip, RoomType.ROOM_PLANETARIUM)

local function ultraSecretFlip()
	local roomConfigRoom
	--10 attempts
	for _ = 1, 10 do
		roomConfigRoom = RoomConfigHolder.GetRandomRoom(Mod.GENERIC_RNG:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_PLANETARIUM, Mod.Room():GetRoomShape(), -1, -1, 1, 10, 1)
		--Means there are literally no rooms that match. Abort!
		if not roomConfigRoom then return end
		if Mod:CanReplaceRoom(Mod.Level():GetCurrentRoomDesc(), roomConfigRoom) then
			return roomConfigRoom
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, ultraSecretFlip, RoomType.ROOM_ULTRASECRET)

local function planetariumBackdrop()
	return Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_PLANETARIUM]
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, planetariumBackdrop, RoomType.ROOM_ULTRASECRET)

local function ultraSecretBackdrop()
	return Mod.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_ULTRASECRET]
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, ultraSecretBackdrop, RoomType.ROOM_PLANETARIUM)

local function postUltraSecretRoomFlip()
	if PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then return end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE)) do
		local pickup = ent:ToPickup()
		---@cast pickup EntityPickup
		Mod.Trinket.ALMAGEST_SCRAP:TurnToAlmagestShopItem(pickup)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, postUltraSecretRoomFlip, RoomType.ROOM_ULTRASECRET)