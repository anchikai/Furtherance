local Mod = Furtherance

local PILLAR_OF_CLOUDS = {}

Furtherance.Item.PILLAR_OF_CLOUDS = PILLAR_OF_CLOUDS

PILLAR_OF_CLOUDS.ID = Isaac.GetItemIdByName("Pillar of Clouds")
PILLAR_OF_CLOUDS.ROOM_SKIP_CHANCE = 0.1

--TODO: Technically works but is a bit jarring. Was gonna try using MC_PRE_CHANGE_ROOM but it doesn't appear to be working accurately?

--left/right = -1, +1
--up/down = -13, +13

--Relative to top left grid. (x, y)
local doorCoords = {
	[DoorSlot.LEFT0] = {0, 0},
	[DoorSlot.UP0] = {0, 0},
	[DoorSlot.RIGHT0] = {1, 0},
	[DoorSlot.DOWN0] = {0, 13},
	[DoorSlot.LEFT1] = {0, 13},
	[DoorSlot.UP1] = {1, 0},
	[DoorSlot.RIGHT1] = {1, 13},
	[DoorSlot.DOWN1] = {1, 13},
}

--Use this offset instead with specific shapes
local shapeOffsets = {
	[RoomShape.ROOMSHAPE_1x2] = {
		[DoorSlot.LEFT1] = {0, 13},
		[DoorSlot.DOWN0] = {0, 13},
		[DoorSlot.RIGHT1] = {0, 13},
	},
	[RoomShape.ROOMSHAPE_IIV] = {
		[DoorSlot.LEFT1] = {0, 13},
		[DoorSlot.DOWN0] = {0, 13},
		[DoorSlot.RIGHT1] = {0, 13},
	},
	[RoomShape.ROOMSHAPE_2x1] = {
		[DoorSlot.UP1] = {0, 1},
		[DoorSlot.DOWN1] = {0, 1},
		[DoorSlot.RIGHT1] = {0, 1},
	},
	[RoomShape.ROOMSHAPE_IIH] = {
		[DoorSlot.UP1] = {0, 1},
		[DoorSlot.DOWN1] = {0, 1},
		[DoorSlot.RIGHT1] = {0, 1},
	},
	[RoomShape.ROOMSHAPE_LTL] = {
		[DoorSlot.LEFT0] = {1, 0},
		[DoorSlot.UP0] = {1, 13}
	},
	[RoomShape.ROOMSHAPE_LTR] = {
		[DoorSlot.RIGHT0] = {0, 0},
		[DoorSlot.UP1] = {1, 13}
	},
	[RoomShape.ROOMSHAPE_LBL] = {
		[DoorSlot.LEFT1] = {1, 13},
		[DoorSlot.DOWN0] = {0, 0}
	},
	[RoomShape.ROOMSHAPE_LBR] = {
		[DoorSlot.RIGHT1] = {0, 13},
		[DoorSlot.DOWN1] = {1, 0}
	},
}

function PILLAR_OF_CLOUDS:RoomSkip(idx, dim)
	local room = Mod.Game:GetRoom()
	local level = Mod.Game:GetLevel()
	if not PlayerManager.AnyoneHasCollectible(PILLAR_OF_CLOUDS.ID)
		--or not room:IsFirstVisit()
		--or room:IsClear()
		or RoomTransition.GetTransitionMode() ~= 3
		or level.LeaveDoor == -1
	then
		return
	end
	--[[ local rng = PlayerManager.FirstCollectibleOwner(PILLAR_OF_CLOUDS.ID):GetCollectibleRNG(PILLAR_OF_CLOUDS.ID)
	local leaveDoor = level.LeaveDoor
	local currentRoomDesc = level:GetCurrentRoomDesc()
	local gridIndex = currentRoomDesc.GridIndex
	local roomShape = currentRoomDesc.Data.Shape
	local shapeOffset = shapeOffsets[roomShape]
	local doorGridOffset = shapeOffset and shapeOffset[leaveDoor] or doorCoords[leaveDoor]
	--We exited from an unknown grid index in a large room. Find where we are using the door we're leaving from
	Mod:DebugLog("Expected offset:", doorGridOffset[1], doorGridOffset[2])
	if roomShape >= RoomShape.ROOMSHAPE_1x2 and roomShape <= RoomShape.ROOMSHAPE_IIH and shapeOffset[roomShape][leaveDoor] then
		gridIndex = gridIndex + doorGridOffset[1] + doorGridOffset[2]
	elseif roomShape >= RoomShape.ROOMSHAPE_LTL and roomShape <= RoomShape.ROOMSHAPE_LBR then
		gridIndex = gridIndex + doorGridOffset[1] + doorGridOffset[2]
	end
	Mod:DebugLog("Top Left:", currentRoomDesc.GridIndex, "Updated:", gridIndex)
	local nextRoomDesc = level:GetRoomByIdx(idx, dim)
	local doors = nextRoomDesc.Doors
	local allowedDoors = nextRoomDesc.AllowedDoors
	local nextEnterDoor
	Mod:DebugLog("Next room's connected grid indexes:")
	for doorSlot = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local connectedGridIndex = doors[doorSlot]
		if Mod:HasBitFlags(allowedDoors, 1 << doorSlot) and connectedGridIndex ~= -1 then
			Mod:DebugLog("Present:", connectedGridIndex)
		elseif connectedGridIndex ~= -1 then
			Mod:DebugLog("N/A:", connectedGridIndex)
		end
		if connectedGridIndex == gridIndex then
			nextEnterDoor = doorSlot
			Mod:DebugLog("New DoorSlot is", doorSlot, "-", Mod:Invert(DoorSlot)[doorSlot])
			break
		end
	end ]]
	--if not nextEnterDoor then return end
	--[[ local roomIndex
	local oppositeDoorSlot = (nextEnterDoor.Slot - 2) % 4 ]]

	--print(oppositeDoorSlot, level.LeaveDoor, level.EnterDoor)
	--[[ if Mod:HasBitFlags(allowedDoors, oppositeDoorSlot) then
		local doors = roomDesc.Doors
		if doors[oppositeDoorSlot] then
			roomIndex = doors[oppositeDoorSlot]
		end
	end ]]
	--print(roomIndex)
	--[[ if rng:RandomFloat() <= PILLAR_OF_CLOUDS.ROOM_SKIP_CHANCE * PlayerManager.GetNumCollectibles(PILLAR_OF_CLOUDS.ID) then
		local leaveDoor = room:GetDoor(level.LeaveDoor)
		local enterDoor = room:GetDoor(level.EnterDoor)
		if leaveDoor ~= nil and not leaveDoor:IsLocked() then
			roomIndex = leaveDoor.TargetRoomIndex
		elseif room:IsDoorSlotAllowed(oppositeDoorSlot) then
			local success = level:MakeRedRoomDoor(level:GetCurrentRoomIndex(), oppositeDoorSlot)
			if success then
				roomIndex = room:GetDoor(oppositeDoorSlot).TargetRoomIndex
			end
		end
	end
	if roomIndex then
		Mod.Game:StartRoomTransition(roomIndex, Direction.NO_DIRECTION, RoomTransitionAnim.WALK)
	end ]]
end

Mod:AddCallback(ModCallbacks.MC_PRE_CHANGE_ROOM, PILLAR_OF_CLOUDS.RoomSkip)
