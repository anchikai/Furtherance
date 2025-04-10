local Mod = Furtherance

-- HUUUUUUUUUUGE credit to Guantol for creating this logic in C++, which was converted to Lua

local function getShopLevel(rng)
	local persistentGameData = Mod.PersistGameData

	local oddStoreUpgrades = 0
	if persistentGameData:Unlocked(Achievement.STORE_UPGRADE_LV1) then
		oddStoreUpgrades = oddStoreUpgrades + 1
	end
	if persistentGameData:Unlocked(Achievement.STORE_UPGRADE_LV3) then
		oddStoreUpgrades = oddStoreUpgrades + 1
	end
	local evenStoreUpgrades = 0
	if persistentGameData:Unlocked(Achievement.STORE_UPGRADE_LV2) then
		oddStoreUpgrades = oddStoreUpgrades + 1
	end
	if persistentGameData:Unlocked(Achievement.STORE_UPGRADE_LV4) then
		oddStoreUpgrades = oddStoreUpgrades + 1
	end

	local shopLevel = rng:RandomInt(oddStoreUpgrades) + rng:RandomInt(evenStoreUpgrades);
	if (rng:RandomInt(2) == 0 or not Mod.Game:IsHardMode()) then
		shopLevel = oddStoreUpgrades + evenStoreUpgrades --best unlocked shop level
	end

	return shopLevel
end

local SHOP_KEEPER_OFFSET = 7

local function getShopSubtype(rng)
	local shopSubType = getShopLevel(rng)
	local rareShopSeed = rng:RandomInt(255)
	if (rareShopSeed == 0) then
		shopSubType = RoomSubType.SHOP_RARE_BAD
	elseif rareShopSeed == 1 and shopSubType > 1 then
		shopSubType = RoomSubType.SHOP_RARE_GOOD
	end

	if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B)
		--Little directly inserted extra
		or PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B)
	then
		shopSubType = shopSubType + SHOP_KEEPER_OFFSET
	end

	return shopSubType
end

local function getShopRoomData(rng)
	local subTypeRNG = RNG(rng:GetSeed(), 19)
	return RoomConfigHolder.GetRandomRoom(rng:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_SHOP,
		Mod.Room():GetRoomShape(), 0, -1, 1, 10, 0, getShopSubtype(subTypeRNG))
end

local function libraryRoomFlip()
	local roomConfigRoom
	--10 attempts
	for _ = 1, 10 do
		roomConfigRoom = getShopRoomData(Mod.GENERIC_RNG)
		--Means there are literally no rooms that match. Abort!
		if not roomConfigRoom then return end
		if Mod:CanReplaceRoom(Mod.Level():GetCurrentRoomDesc(), roomConfigRoom) then
			return roomConfigRoom
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, libraryRoomFlip, RoomType.ROOM_LIBRARY)

local function getLibraryRoomData(rng)
	local persistentGameData = Mod.PersistGameData
	local storeLevel = 0
	for i = Achievement.STORE_UPGRADE_LV1, Achievement.STORE_UPGRADE_LV4 do
		if persistentGameData:Unlocked(i) then
			storeLevel = storeLevel + 1
		end
	end
	local roomSubType = rng:RandomInt(storeLevel + 1)

	return RoomConfigHolder.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_LIBRARY,
		Mod.Room():GetRoomShape(), 0, -1, 1, 10, 0, roomSubType);
end

local function shopRoomFlip()
	local roomConfigRoom
	--10 attempts
	for _ = 1, 10 do
		roomConfigRoom = getLibraryRoomData(Mod.GENERIC_RNG)
		--Means there are literally no rooms that match. Abort!
		if not roomConfigRoom then return end
		if Mod:CanReplaceRoom(Mod.Level():GetCurrentRoomDesc(), roomConfigRoom) then
			return roomConfigRoom
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, shopRoomFlip, RoomType.ROOM_SHOP)

local function libraryShop(_, newRoomType)
	if PlayerManager.AnyPlayerTypeHasBirthright(Mod.PlayerType.PETER_B) then return end
	if newRoomType == RoomType.ROOM_LIBRARY then
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_PICKUP)) do
			local pickup = ent:ToPickup()
			---@cast pickup EntityPickup
			pickup:MakeShopItem(-1)
		end
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, libraryShop, RoomType.ROOM_SHOP)
