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
