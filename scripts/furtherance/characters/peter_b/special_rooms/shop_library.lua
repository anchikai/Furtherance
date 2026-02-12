local Mod = Furtherance
local MUDDLED_CROSS = Mod.Item.MUDDLED_CROSS

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
		evenStoreUpgrades = evenStoreUpgrades + 1
	end
	if persistentGameData:Unlocked(Achievement.STORE_UPGRADE_LV4) then
		evenStoreUpgrades = evenStoreUpgrades + 1
	end

	local shopLevel = rng:RandomInt(oddStoreUpgrades) + rng:RandomInt(evenStoreUpgrades)
	if (rng:RandomInt(2) == 0 or not Mod.Game:IsHardMode()) then
		shopLevel = oddStoreUpgrades + evenStoreUpgrades --best unlocked shop level
	end

	return shopLevel
end

local SHOP_KEEPER_OFFSET = RoomSubType.SHOP_KEEPER_LEVEL_1

---@param rng RNG
---@return integer
function Furtherance.Item.MUDDLED_CROSS:GetShopSubtype(rng)
	local subTypeRNG = RNG(rng:GetSeed(), 19)
	local shopSubType = getShopLevel(subTypeRNG)
	local rareShopSeed = subTypeRNG:RandomInt(255)
	if (rareShopSeed == 0) then
		shopSubType = RoomSubType.SHOP_RARE_BAD
	elseif rareShopSeed == 1 and shopSubType > 1 then
		shopSubType = RoomSubType.SHOP_RARE_GOOD
	end

	if PlayerManager.AnyoneIsPlayerType(PlayerType.PLAYER_KEEPER_B)
		--Little directly inserted extra
		or MUDDLED_CROSS:CanUseUpgradedRoomFlip()
	then
		shopSubType = shopSubType + SHOP_KEEPER_OFFSET
	end

	return shopSubType
end

local function getShopRoomData(rng)
	return RoomConfigHolder.GetRandomRoom(rng:Next(), true, StbType.SPECIAL_ROOMS, RoomType.ROOM_SHOP,
		Mod.Room():GetRoomShape(), 0, -1, 1, 10, 0, MUDDLED_CROSS:GetShopSubtype(rng))
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

local function libraryRoomBackdrop()
	if not Mod.Game:IsGreedMode() then
		return MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_LIBRARY]
	end
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, libraryRoomBackdrop, RoomType.ROOM_SHOP)

local function shopRoomBackdrop()
	return MUDDLED_CROSS.SPECIAL_ROOM_FLIP.ROOM_BACKDROPS[RoomType.ROOM_SHOP]
end

Mod:AddCallback(Mod.ModCallbacks.GET_MUDDLED_CROSS_PUDDLE_BACKDROP, shopRoomBackdrop, RoomType.ROOM_LIBRARY)

function Furtherance.Item.MUDDLED_CROSS:GetLibrarySubtype(rng)
	local subTypeRNG = RNG(rng:GetSeed(), 19)
	local persistentGameData = Mod.PersistGameData
	local storeLevel = 0
	for i = Achievement.STORE_UPGRADE_LV1, Achievement.STORE_UPGRADE_LV4 do
		if persistentGameData:Unlocked(i) then
			storeLevel = storeLevel + 1
		end
	end
	return subTypeRNG:RandomInt(storeLevel + 1)
end

local function getLibraryRoomData(rng)
	return RoomConfigHolder.GetRandomRoom(rng:Next(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_LIBRARY,
		Mod.Room():GetRoomShape(), 0, -1, 1, 10, 0, MUDDLED_CROSS:GetLibrarySubtype(rng))
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

local function libraryShop()
	if MUDDLED_CROSS:CanUseUpgradedRoomFlip() then return end

	Mod.Foreach.Pickup(function (pickup, index)
		pickup:MakeShopItem(-1)
	end, PickupVariant.PICKUP_COLLECTIBLE)
end

Mod:AddCallback(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, libraryShop, RoomType.ROOM_LIBRARY)
