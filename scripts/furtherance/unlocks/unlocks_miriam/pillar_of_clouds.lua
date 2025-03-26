local Mod = Furtherance

local PILLAR_OF_CLOUDS = {}

Furtherance.Item.PILLAR_OF_CLOUDS = PILLAR_OF_CLOUDS

PILLAR_OF_CLOUDS.ID = Isaac.GetItemIdByName("Pillar of Clouds")
PILLAR_OF_CLOUDS.ROOM_SKIP_CHANCE = 0.1

--TODO: Technically works but is a bit jarring. Was gonna try using MC_PRE_CHANGE_ROOM but it doesn't appear to be working accurately?

function PILLAR_OF_CLOUDS:RoomSkip()
	local room = Mod.Game:GetRoom()
	if not PlayerManager.AnyoneHasCollectible(PILLAR_OF_CLOUDS.ID)
		or not room:IsFirstVisit()
		or room:IsClear()
		or RoomTransition.GetTransitionMode() ~= 3
	then
		return
	end
	local level = Mod.Game:GetLevel()
	local rng = PlayerManager.FirstCollectibleOwner(PILLAR_OF_CLOUDS.ID):GetCollectibleRNG(PILLAR_OF_CLOUDS.ID)
	local roomIndex

	if rng:RandomFloat() <= PILLAR_OF_CLOUDS.ROOM_SKIP_CHANCE * PlayerManager.GetNumCollectibles(PILLAR_OF_CLOUDS.ID) then
		local leaveDoor = room:GetDoor(level.LeaveDoor)
		local enterDoor = room:GetDoor(level.EnterDoor)
		local oppositeDoorSlot = (enterDoor.Slot - 2) % 4
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
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PILLAR_OF_CLOUDS.RoomSkip)
