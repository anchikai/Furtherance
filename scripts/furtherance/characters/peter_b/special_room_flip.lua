local Mod = Furtherance

local SPECIAL_ROOM_FLIP = {}

Furtherance.Item.MUDDLED_CROSS.SPECIAL_ROOM_FLIP = SPECIAL_ROOM_FLIP

local roomPath = "scripts.furtherance.characters.peter_b.special_rooms"
local backdropPath = "gfx/backdrop/"

local specialRooms = {
	"treasure_deviltreasure",
	"shop_library",
	"devil_angel",
	"planetarium_ultrasecret"
}

Mod.LoopInclude(specialRooms, roomPath)

SPECIAL_ROOM_FLIP.ROOM_BACKDROPS = {
	[RoomType.ROOM_SHOP] = backdropPath .. "0b_shop.png",
	[RoomType.ROOM_LIBRARY] = backdropPath .. "0a_library.png",
	[RoomType.ROOM_DEVIL] = backdropPath .. "09_sheol.png",
	[RoomType.ROOM_ANGEL] = backdropPath .. "10_cathedral.png",
	[RoomType.ROOM_PLANETARIUM] = backdropPath .. "planetarium_blue_base.png",
	[RoomType.ROOM_ULTRASECRET] = backdropPath .. "0fx_hallway.png",
}

SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS = Mod:Set({
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_SHOP,
	RoomType.ROOM_LIBRARY,
	RoomType.ROOM_DEVIL,
	RoomType.ROOM_ANGEL,
	RoomType.ROOM_PLANETARIUM,
	RoomType.ROOM_ULTRASECRET
})

SPECIAL_ROOM_FLIP.TEMP_KEEP_DOORS_SHUT_DURATION = 45
local tempCloseDoors = 0

function SPECIAL_ROOM_FLIP:CanFlipRoom()
	return SPECIAL_ROOM_FLIP.ALLOWED_SPECIAL_ROOMS[Mod.Room():GetType()]
		and not SPECIAL_ROOM_FLIP:IsFlippedRoom()
end

function SPECIAL_ROOM_FLIP:IsFlippedRoom()
	local room_save = Mod:RoomSave()
	return room_save.MuddledCrossFlippedRoom
end

local roomToLoad

function SPECIAL_ROOM_FLIP:TryFlipSpecialRoom()
	local room = Mod.Room()
	local roomType = room:GetType()
	local roomConfigRoom = Isaac.RunCallbackWithParam(Mod.ModCallbacks.MUDDLED_CROSS_ROOM_FLIP, roomType)
	if not roomConfigRoom then return false end
	---@cast roomConfigRoom RoomConfigRoom
	local room_save = Mod:RoomSave()
	room_save.MuddledCrossFlippedRoom = true
	--Replace current room's data with newly received blank room, if applicable
	if type(roomConfigRoom) ~= "boolean" then
		roomToLoad = roomConfigRoom
		Mod:DebugLog("Room Flip: RoomType:", roomType, "replacing with RoomType", roomConfigRoom.Type, "Variant", roomConfigRoom.Variant, "Subtype", roomConfigRoom.Subtype)
	else
		Mod:DebugLog("Room Flip: Flip successful, MUDDLED_CROSS_ROOM_FLIP returned boolean")
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
	--Don't need to be respawned even if they overlap I guess? Effects are likely a unique exception
	--[5000] = {EntityType.ENTITY_EFFECT, EffectVariant.DEVIL},
	--[5001] = {EntityType.ENTITY_EFFECT, EffectVariant.ANGEL}
}

local gridIndexes = {}

---When overriding one room with another, it cannot overwrite any existing "RoomConfigSpawn"s from the previous room, and thus do not spawn even if the entity that was there is removed
---
---So we have to manage spawning every entity in ourselves, IF there isn't already an entity there. Grid entities have no problem spawning in, at least
---@param occupiedSpawns table
---@param newRoomConfigRoom RoomConfigRoom
function SPECIAL_ROOM_FLIP:RespawnRoomContents(occupiedSpawns, newRoomConfigRoom)
	local newSpawns = newRoomConfigRoom.Spawns
	local room = Mod.Room()
	local rng = RNG(room:GetSpawnSeed())
	Mod:DebugLog("Room Flip: Attempting to locate overlapping spawns")
	for i = 0, #newSpawns - 1 do
		local spawn = newSpawns:Get(i)
		if occupiedSpawns[tostring(spawn.X) .. tostring(spawn.Y)] then
			--We do +1 because nothing is allowed to spawn on the walls, and thus they are ignored
			--The true top left starts from tile 1,1
			local gridIndex = room:GetGridIndexByTile(spawn.X + 1, spawn.Y + 1)
			--The room is actually completely fine with spawning an entity if a grid entity occupied that space. Skip needing to respawn it
			if gridIndexes[gridIndex] then
				goto skipSpawn
			end
			local spawnEntry = spawn:PickEntry(Mod.GENERIC_RNG:RandomFloat())
			--If a grid entity was in the spot, the room will actually be fine with spawning entities there.
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
		::skipSpawn::
	end
	Mod:DebugLog("Room Flip: Entity search complete")
end

function SPECIAL_ROOM_FLIP:UpdateRoom()
	local level = Mod.Level()
	local curIndex = level:GetCurrentRoomIndex()
	local room = Mod.Room()
	local roomType = room:GetType()
	local spawnPos
	local puddle = Isaac.FindByType(EntityType.ENTITY_EFFECT, Mod.Item.MUDDLED_CROSS.PUDDLE)[1]
	if puddle then
		spawnPos = puddle.Position
	end

	if roomToLoad then
		for index = 0, room:GetGridSize() - 1 do
			local gridEnt = room:GetGridEntity(index)
			if gridEnt then
				gridIndexes[index] = true
				room:RemoveGridEntityImmediate(index, 0, false)
			end
		end
		Mod:inverseiforeach(Isaac.GetRoomEntities(), function (ent, key)
			if not ent:ToPlayer() and not ent:ToFamiliar() then
				ent:Remove()
			end
		end)
		local oldSpawns = level:GetCurrentRoomDesc().Data.Spawns
		local occupiedSpawns = {}
		for i = 0, #oldSpawns - 1 do
			local spawn = oldSpawns:Get(i)
			occupiedSpawns[tostring(spawn.X) .. tostring(spawn.Y)] = {}
		end
		--GetEntitiesSaveState():Clear() only works if you're outside the room you're changing
		level.LeaveDoor = -1
		Mod.Game:ChangeRoom(84)
		local startingRoom = Mod.Level():GetRoomByIdx(84)
		--Shh we were never here
		startingRoom.VisitedCount = startingRoom.VisitedCount - 1
		local currentRoom = Mod.Level():GetRoomByIdx(curIndex)
		currentRoom:GetEntitiesSaveState():Clear()
		currentRoom.Data = roomToLoad
		currentRoom.OverrideData = roomToLoad
		currentRoom.VisitedCount = 0
		level.LeaveDoor = -1
		Mod.Game:ChangeRoom(curIndex)
		SPECIAL_ROOM_FLIP:RespawnRoomContents(occupiedSpawns, roomToLoad)
		gridIndexes = {}
		--In case something goes wrong at the entrance
		local spawnGrid = Mod.Room():GetGridEntityFromPos(Isaac.GetPlayer().Position)
		if spawnGrid then
			room:RemoveGridEntityImmediate(spawnGrid:GetGridIndex(), 0, false)
		end
		roomToLoad = nil
	else
		level.LeaveDoor = -1
		Mod.Game:ChangeRoom(curIndex)
	end
	if spawnPos then
		Mod:ForEachPlayer(function (player)
			player.Position = spawnPos
		end)
	end
	Mod.Room():PlayMusic()
	Isaac.RunCallbackWithParam(Mod.ModCallbacks.POST_MUDDLED_CROSS_ROOM_FLIP, room:GetType(), roomType)
	tempCloseDoors = SPECIAL_ROOM_FLIP.TEMP_KEEP_DOORS_SHUT_DURATION
end

---Keeping doors shut for a second so you don't accidentally walk out from disorientation
function SPECIAL_ROOM_FLIP:TempCloseDoors()
	local room = Mod.Room()
	if tempCloseDoors > 0 then
		tempCloseDoors = tempCloseDoors - 1
		local door = room:GetDoor(Mod.Level().EnterDoor)
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

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, SPECIAL_ROOM_FLIP.TempCloseDoors)

---@param pickup EntityPickup
---@param collider Entity
function SPECIAL_ROOM_FLIP:InvalidateFlip(pickup, collider)
	local player = collider:ToPlayer()
	if player
		and Mod:CanPlayerBuyShopItem(player, pickup)
		and SPECIAL_ROOM_FLIP:CanFlipRoom()
	then
		Mod:KillDevilPedestals(pickup)
		local room_save = Mod:RoomSave()
		room_save.MuddledCrossFlippedRoom = true
		for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, Mod.Item.MUDDLED_CROSS.PUDDLE)) do
			ent:ToEffect().Timeout = 4
			if ent.SubType == 0 then
				Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.POOF01, 2, ent.Position, Vector.Zero, nil)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, SPECIAL_ROOM_FLIP.InvalidateFlip, PickupVariant.PICKUP_COLLECTIBLE)

local function resetDoorsNewRoom()
	tempCloseDoors = 0
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, resetDoorsNewRoom)
