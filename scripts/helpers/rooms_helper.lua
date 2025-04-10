function Furtherance:GetRoomDesc()
	return Furtherance.Level():GetCurrentRoomDesc()
end

function Furtherance:IsInStartingRoom(checkHasLeft)
	local level = Furtherance.Level()
	local roomIndex = level:GetCurrentRoomDesc().SafeGridIndex
	local startingRoomIndex = level:GetStartingRoomIndex()

	return roomIndex == startingRoomIndex
		and level:GetStage() == LevelStage.STAGE1_1
		and (not checkHasLeft or Furtherance.Room():IsFirstVisit())
end

---Helper function that calculates what the stage type should be for the provided stage.
---This emulates what the game's internal code does.
---
---Regretfully taken from IsaacScript
---@param stage LevelStage
function Furtherance:CalculateStageType(stage)
	local seeds = Furtherance.Game:GetSeeds()
	local stageSeed = seeds:GetStageSeed(stage)
	if stageSeed % 2 == 0 then
		return StageType.STAGETYPE_WOTL
	end
	if stageSeed % 3 == 0 then
		return StageType.STAGETYPE_AFTERBIRTH
	end
	return StageType.STAGETYPE_ORIGINAL
end

---Helper function that calculates what the Repentance stage type should be for the provided stage.
---This emulates what the game's internal code does.
---
---Regretfully taken from IsaacScript
---@param stage LevelStage
function Furtherance:CalculateStageTypeRepentance(stage)
	if stage == LevelStage.STAGE4_1 or stage == LevelStage.STAGE4_2 then
		return StageType.STAGETYPE_REPENTANCE
	end
	local seeds = Furtherance.Game:GetSeeds()
	local stageSeed = seeds:GetStageSeed(stage)
	local halfStageSeed = math.floor(stageSeed / 2)

	if halfStageSeed % 2 == 0 then
		return StageType.STAGETYPE_REPENTANCE_B
	end
	return StageType.STAGETYPE_REPENTANCE
end

---@param cond? fun(room: RoomDescriptor): boolean
---@return RoomDescriptor[]
function Furtherance:GetAllRooms(cond)
	local collectedRooms = {}
	local level = Furtherance.Level()
	local rooms = level:GetRooms()

	for i = 0, #rooms - 1 do
		local room = rooms:Get(i)
		if not cond or cond(room) then
			Furtherance:Insert(collectedRooms, room)
		end
	end
	return collectedRooms
end

---@param count integer
---@param rng RNG
---@param cond? fun(room: RoomDescriptor): boolean
---@return RoomDescriptor[]
function Furtherance:GetRandomRooms(count, rng, cond)
	local roomIndexes = Furtherance:GetAllRooms(cond)
	local randomRooms = {}
	for _ = 1, count do
		local randomRoomDesc = Furtherance:GetDifferentRandomValue(randomRooms, roomIndexes, rng)
		Furtherance:Insert(randomRooms, randomRoomDesc)
	end
	return randomRooms
end

local MAX_ATTEMPTS = 100
---I'll do this later if I feel like it lol. Supposed to manage getting a valid random room that doesn't take from rooms you shouldn't have
---
---Examples: Mines-unique Challenge Room, Variant 100 Devil and Angel Rooms as well as their Number 6/Stairway versions with SubType 1
--[[
---@param roomType RoomType
function Furtherance:GetRandomRoom(roomType, requiredDoors)
	local numAttempts = 0
	local roomConfigRoom
	local minDifficulty = -1
	local maxDifficulty = -1
	local minVariant = -1
	local maxVariant = -1

	if roomType == RoomType.ROOM_DEVIL


	repeat
		local seed = Furtherance:GetAndAdvanceGenericRNGSeed()
		roomConfigRoom = RoomConfigHolder.GetRandomRoom(seed, true, StbType.SPECIAL_ROOMS, roomType, Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, requiredDoors)

		numAttempts = numAttempts + 1
	until numAttempts >= MAX_ATTEMPTS
	return roomConfigRoom
end ]]

---Returns a RoomConfigRoom that should be able to replace the current room with the provided `roomType`
---@param roomType RoomType
function Furtherance:GenerateReplacementRoomConfig(roomType)
	local room = Furtherance.Room()
	local roomDesc = Furtherance.Level():GetCurrentRoomDesc()
	local seed = roomDesc.SpawnSeed
	local doors = roomDesc.Data.Doors
	local allowedDoors = roomDesc.AllowedDoors
	local requiredDoors = 0
	local presentDoors = {}
	for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		if Furtherance:HasBitFlags(doors, 1 << i) then
			requiredDoors = requiredDoors + 1
		end
		if Furtherance:HasBitFlags(allowedDoors, 1 << i) then
			presentDoors[i] = true
		end
	end
	local numAttempts = 0
	local roomConfigRoom
	---Even if the number of required doors match, we must ensure the specific doors in the current room are available in this new room
	repeat
		local failedDoorCheck = false
		roomConfigRoom = RoomConfigHolder.GetRandomRoom(seed, true, StbType.SPECIAL_ROOMS, roomType,
			Furtherance.Room():GetRoomShape(), -1, -1, 1, 10, requiredDoors)
		for doorSlot, _ in pairs(presentDoors) do
			if not Furtherance:HasBitFlags(roomConfigRoom.Doors, 1 << doorSlot) then
				failedDoorCheck = true
				break
			end
		end
		numAttempts = numAttempts + 1
	until not failedDoorCheck or numAttempts >= MAX_ATTEMPTS
	if numAttempts >= MAX_ATTEMPTS then
		Furtherance:Log("Could not find a suitable replacement for", room:GetType(), "with type", roomType,
			"after 100 attempts")
	end
	return roomConfigRoom
end

---@param secondFloorOnly boolean
function Furtherance:CheckValidPreWombChapter(secondFloorOnly)
	local level = Furtherance.Level()
	local stage = level:GetStage()
	return ((
			stage < LevelStage.STAGE4_1
			and (not secondFloorOnly and stage % 2 ~= 0 or stage % 2 == 0)
		)
		and not level:IsAscent()
		and not Furtherance.Game:IsGreedMode()
	)
end

-- For getting a speicifc group of rooms of the respective difficulty
function Furtherance:GetRoomMode()
	return Furtherance.Game:IsGreedMode() and 1 or 0
end

---@param func fun(doorSlot: GridEntityDoor)
function Furtherance:ForEachDoor(func)
	local room = Furtherance.Room()
	for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(doorSlot)
		if door then
			local result = func(door)
			if result then
				return true
			end
		end
	end
end
