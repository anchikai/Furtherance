local Mod = Furtherance

local COSMIC_OMNIBUS = {}

Furtherance.Item.COSMIC_OMNIBUS = COSMIC_OMNIBUS

COSMIC_OMNIBUS.ID = Isaac.GetItemIdByName("Cosmic Omnibus")

COSMIC_OMNIBUS.UNDESIRED_ROOM_TYPES = Mod:Set({
	RoomType.ROOM_DEFAULT,
	RoomType.ROOM_ULTRASECRET,
	RoomType.ROOM_GREED_EXIT,
	RoomType.ROOM_BLACK_MARKET,
	RoomType.ROOM_TELEPORTER,
	RoomType.ROOM_TELEPORTER_EXIT,
	RoomType.ROOM_SECRET_EXIT,
	RoomType.ROOM_ERROR,
	RoomType.ROOM_DUNGEON
})

---@param rng RNG
---@param player EntityPlayer
function COSMIC_OMNIBUS:UseOmnibus(_, rng, player)
	local level = Mod.Level()
	local roomsList = level:GetRooms()
	local floor_save = Mod:FloorSave()
	local nonNormalRooms = {}

	for i = 0, #roomsList - 1 do
		local roomDesc = roomsList:Get(i)
		if not COSMIC_OMNIBUS.UNDESIRED_ROOM_TYPES[roomDesc.Data.Type]
			and roomDesc.VisitedCount == (floor_save.CosmicOmnibusPlanetariumVisited and 1 or 0)
		then
			Mod:Insert(nonNormalRooms, roomDesc)
		end
	end

	if #nonNormalRooms > 0 then -- teleport to a random non-normal room
		local choice = rng:RandomInt(#nonNormalRooms) + 1
		local chosenRoom = nonNormalRooms[choice]
		level.LeaveDoor = -1
		Mod.Game:StartRoomTransition(chosenRoom.GridIndex, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player, -1)
	elseif not floor_save.CosmicOmnibusPlanetariumVisited then
		floor_save.CosmicOmnibusPlanetariumVisited = true
		local planetarium = RoomConfigHolder.GetRandomRoom(rng:GetSeed(), false, StbType.SPECIAL_ROOMS, RoomType.ROOM_PLANETARIUM, RoomShape.ROOMSHAPE_1x1,
			-1, -1, 0, 10, 1, -1, Mod:GetRoomMode())
		rng:Next()
		Isaac.ExecuteCommand("goto s.planetarium." .. planetarium.Variant)
		level.LeaveDoor = -1
		Mod.Game:StartRoomTransition(GridRooms.ROOM_DEBUG_IDX, Direction.NO_DIRECTION, RoomTransitionAnim.TELEPORT, player)
	end

	return true
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, COSMIC_OMNIBUS.UseOmnibus, COSMIC_OMNIBUS.ID)
