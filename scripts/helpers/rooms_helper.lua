local floor = Furtherance.math.floor

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
	local halfStageSeed = floor(stageSeed / 2)

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
			Furtherance.Insert(collectedRooms, room)
		end
	end
	return collectedRooms
end

---@param count integer
---@param rng RNG
---@param cond? fun(room: RoomDescriptor): boolean
---@return RoomDescriptor[]
function Furtherance:GetRandomRoomsOnFloor(count, rng, cond)
	local roomIndexes = Furtherance:GetAllRooms(cond)
	local randomRooms = {}
	for _ = 1, count do
		local randomRoomDesc = Furtherance:GetDifferentRandomValue(randomRooms, roomIndexes, rng)
		Furtherance.Insert(randomRooms, randomRoomDesc)
	end
	return randomRooms
end

---@param roomDesc RoomDescriptor
function Furtherance:GetRequiredDoors(roomDesc)
	local doors = roomDesc.Data.Doors
	local requiredDoors = 0
	for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		if Furtherance:HasBitFlags(doors, 1 << i) then
			requiredDoors = requiredDoors + 1
		end
	end
	return requiredDoors
end

---Returns if the provided `roomConfigRoom` should be allowed to replace the current `roomDesc`
---
---RoomDescriptor.AllowedDoors contains all present doors, while RoomConfigRoom contains the doors it allows.
---If there's a mismatch, it could potentially lead to a softlock
---@param roomDesc RoomDescriptor
---@param roomConfigRoom RoomConfigRoom
function Furtherance:CanReplaceRoom(roomDesc, roomConfigRoom)
	for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		if Furtherance:HasBitFlags(roomDesc.AllowedDoors, 1 << doorSlot)
			and not Furtherance:HasBitFlags(roomConfigRoom.Doors, 1 << doorSlot)
		then
			return false
		end
	end

	return true
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
