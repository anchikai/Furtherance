local Mod = Furtherance

local SPECIAL_ROOM_FLIP = {}

Furtherance.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP = SPECIAL_ROOM_FLIP

local roomPath = "scripts.furtherance.characters.peter_b.special_rooms"

local specialRooms = {
	"treasure_deviltreasure",
	"shop_library",
	"devil_angel",
	"planetarium_ultrasecret"
}

Mod.LoopInclude(specialRooms, roomPath)

SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS = Mod:Set({
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_SHOP,
	RoomType.ROOM_LIBRARY,
	RoomType.ROOM_DEVIL,
	RoomType.ROOM_ANGEL,
	RoomType.ROOM_PLANETARIUM,
	RoomType.ROOM_ULTRASECRET,
})
SPECIAL_ROOM_FLIP.TEMP_KEEP_DOORS_SHUT_DURATION = 45
local tempCloseDoors = 0

---@param idx integer
function SPECIAL_ROOM_FLIP:IsFlippedRoom(idx)
	local room_save = Mod:RoomSave()
	return room_save.MuddledCrossFlippedRoom
		and room_save.MuddledCrossFlippedRoom[tostring(idx)]
end

local roomToLoad

function SPECIAL_ROOM_FLIP:TryFlipSpecialRoom()
	local room = Mod.Room()
	local roomType = room:GetType()
	local curIndex = Mod.Level():GetCurrentRoomIndex()
	local roomConfigRoom = Isaac.RunCallbackWithParam(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, roomType)
	if not roomConfigRoom then return false end
	---@cast roomConfigRoom RoomConfigRoom
	Mod:DebugLog("Room Flip: RoomType:", roomType, "replacing with RoomType", roomConfigRoom.Type, "Variant", roomConfigRoom.Variant, "Subtype", roomConfigRoom.Subtype)
	local room_save = Mod:RoomSave()
	if curIndex ~= GridRooms.ROOM_DEBUG_IDX then
		room_save.MuddledCrossFlippedRoom = room_save.MuddledCrossFlippedRoom or {}
		room_save.MuddledCrossFlippedRoom[tostring(curIndex)] = true
	end
	--Replace current room's data with newly received blank room, if applicable
	if type(roomConfigRoom) ~= "boolean" then
		roomToLoad = roomConfigRoom
	end

	return true
end

local GRID_ID_TO_TYPE = {
	[1000] = GridEntityType.GRID_ROCK,
	[1001] = GridEntityType.GRID_ROCK_BOMB,
	[1002] = GridEntityType.GRID_ROCK_ALT,
	[1003] = GridEntityType.GRID_ROCKT,
	[1008] = GridEntityType.GRID_ROCK_ALT2,
	[1010] = GridEntityType.GRID_ROCK_SPIKED,
	[1011] = GridEntityType.GRID_ROCK_GOLD,
	[1300] = GridEntityType.GRID_TNT,
	[1900] = GridEntityType.GRID_ROCKB,
	[1901] = GridEntityType.GRID_PILLAR,
	[1930] = GridEntityType.GRID_SPIKES,
	[1931] = GridEntityType.GRID_SPIKES_ONOFF,
	[1940] = GridEntityType.GRID_SPIDERWEB,
	[1999] = GridEntityType.GRID_WALL,
	[3000] = GridEntityType.GRID_PIT,
	[4000] = GridEntityType.GRID_LOCK,
	[4500] = GridEntityType.GRID_PRESSURE_PLATE,
	[6100] = GridEntityType.GRID_TELEPORTER,
	[9000] = GridEntityType.GRID_TRAPDOOR,
	[9100] = GridEntityType.GRID_STAIRS
}
local GRID_ID_TO_POOP_VARIANT = {
	[1490] = GridPoopVariant.RED,
	[1495] = GridPoopVariant.CORN,
	[1496] = GridPoopVariant.GOLDEN,
	[1494] = GridPoopVariant.RAINBOW,
	[1497] = GridPoopVariant.BLACK,
	[1498] = GridPoopVariant.HOLY,
	[1500] = GridPoopVariant.NORMAL,
	[1501] = GridPoopVariant.CHARMING
}
local GRID_ID_TO_ENTITY = {
	[1400] = {EntityType.ENTITY_FIREPLACE, 0},
	[1410] = {EntityType.ENTITY_FIREPLACE, 1},
	[5000] = {EntityType.ENTITY_EFFECT, EffectVariant.DEVIL},
	[5001] = {EntityType.ENTITY_EFFECT, EffectVariant.ANGEL}
}

---When overriding one room with another, it cannot overwrite any existing "RoomConfigSpawn"s from the previous room, and thus do not spawn even if the entity that was there is removed
---
---So we have to manage spawning every entity in ourselves, IF there isn't already an entity there. Grid entities have no problem spawning in, at least
---@param oldRoomConfigRoom RoomConfigRoom
---@param newRoomConfigRoom RoomConfigRoom
function SPECIAL_ROOM_FLIP:RespawnRoomContents(oldRoomConfigRoom, newRoomConfigRoom)
	local oldSpawns = oldRoomConfigRoom.Spawns
	local newSpawns = newRoomConfigRoom.Spawns
	local room = Mod.Room()
	local rng = RNG(room:GetSpawnSeed())
	local occupiedSpawns = {}
	for i = 0, #oldSpawns - 1 do
		local spawn = oldSpawns:Get(i)
		occupiedSpawns[tostring(spawn.X) .. tostring(spawn.Y)] = true
	end
	Mod:DebugLog("Room Flip: Attempting to locate overlapping spawns")
	for i = 0, #newSpawns - 1 do
		local spawn = newSpawns:Get(i)
		if occupiedSpawns[tostring(spawn.X) .. tostring(spawn.Y)] then
			--We do +1 because nothing is allowed to spawn on the walls, and thus they are ignored
			--The true top left starts from tile 1,1
			local gridIndex = room:GetGridIndexByTile(spawn.X + 1, spawn.Y + 1)
			local spawnEntry = spawn:PickEntry(Mod.GENERIC_RNG:RandomFloat())
			--Grid spawn IDs and maybe mods that are stupid can cause an invalid spawn. Do NOT
			local pos = room:GetGridPosition(gridIndex)
			local entType, var, subtype = spawnEntry.Type, spawnEntry.Variant, spawnEntry.Subtype
			if entType >= 1000 then
				local gridID = GRID_ID_TO_TYPE[entType]
				local poopID = GRID_ID_TO_POOP_VARIANT[entType]
				local entID = GRID_ID_TO_ENTITY[entType]
				if gridID then
					Mod:DebugLog("Spawned Grid Entity", gridID, "at index", gridIndex)
					room:SpawnGridEntity(gridIndex, gridID, var, rng:Next(), subtype)
				elseif poopID then
					Mod:DebugLog("Spawned Grid Entity", gridID, "at index", gridIndex)
					room:SpawnGridEntity(gridIndex, GridEntityType.GRID_POOP, var, rng:Next(), subtype)
				elseif entID then
					Mod.Game:Spawn(entID[1], entID[2], pos, Vector.Zero, nil, subtype, rng:Next())
					Mod:DebugLog("Spawned entity", entID[1], entID[2], subtype, "at index", gridIndex)
				end
			elseif EntityConfig.GetEntity(entType, var, subtype) then
				Mod.Game:Spawn(entType, var, pos, Vector.Zero, nil, subtype, rng:Next())
				Mod:DebugLog("Spawned entity", entType, var, subtype, "at index", gridIndex)
			elseif entType == 6000 then
				room:SetRail(gridIndex, var)
				Mod:DebugLog("Spawned Rail", entType, var, subtype, "at index", gridIndex)
			else
				Mod:DebugLog("Failed to spawn entity", entType, var, subtype, "at index", gridIndex)
			end
		end
	end
	Mod:DebugLog("Room Flip: Entity search complete")
end

function SPECIAL_ROOM_FLIP:UpdateRoom()
	local level = Mod.Level()
	local curIndex = level:GetCurrentRoomIndex()
	local room = Mod.Room()
	local roomType = room:GetType()

	if roomToLoad then
		local oldRoom = level:GetCurrentRoomDesc().Data
		for index = room:GetGridSize() - 1, 0, -1 do
			local gridEnt = room:GetGridEntity(index)
			if gridEnt then
				room:RemoveGridEntityImmediate(index, 0, false)
			end
		end
		--GetEntitiesSaveState():Clear() only works if you're outside the room you're changing
		Mod.Game:ChangeRoom(84)
		local startingRoom = Mod.Level():GetRoomByIdx(curIndex)
		--Shh we were never here
		startingRoom.VisitedCount = startingRoom.VisitedCount - 1
		local currentRoom = Mod.Level():GetRoomByIdx(curIndex)
		currentRoom:GetEntitiesSaveState():Clear()
		currentRoom.Data = roomToLoad
		currentRoom.OverrideData = roomToLoad
		currentRoom.VisitedCount = 0
		Mod.Game:ChangeRoom(curIndex)
		SPECIAL_ROOM_FLIP:RespawnRoomContents(oldRoom, roomToLoad)
		roomToLoad = nil
	else
		Mod.Game:ChangeRoom(curIndex)
	end

	Mod.Room():PlayMusic()
	Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, roomType, room:GetType())
	tempCloseDoors = SPECIAL_ROOM_FLIP.TEMP_KEEP_DOORS_SHUT_DURATION
end

---Keeping doors shut for a second so you don't accidentally walk out from disorientation
function SPECIAL_ROOM_FLIP:TempCloseDoors()
	local room = Mod.Room()
	if tempCloseDoors > 0 then
		tempCloseDoors = tempCloseDoors - 1
		for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
			local door = room:GetDoor(doorSlot)
			if door and not door:IsOpen() and tempCloseDoors == 0 then
				door:TryUnlock(Isaac.GetPlayer(), true)
				Mod.SFXMan:Stop(SoundEffect.SOUND_UNLOCK00)
				door:GetSprite():Play(door.OpenAnimation, true)
			elseif door
				and door:IsOpen()
				and door:GetSprite():GetAnimation() ~= door.CloseAnimation
				and tempCloseDoors > 0
			then
				door:Close()
				door:GetSprite():Play(door.CloseAnimation, true)
				door:GetSprite():SetLastFrame()
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, SPECIAL_ROOM_FLIP.TempCloseDoors)

local function resetDoorsNewRoom()
	tempCloseDoors = 0
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, resetDoorsNewRoom)