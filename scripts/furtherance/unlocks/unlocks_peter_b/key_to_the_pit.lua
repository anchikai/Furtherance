local Mod = Furtherance

local KEY_TO_THE_PIT = {}

Furtherance.Trinket.KEY_TO_THE_PIT = KEY_TO_THE_PIT

KEY_TO_THE_PIT.ID = Isaac.GetTrinketIdByName("Key to the Pit")

function KEY_TO_THE_PIT:ForceDoorOpen()
	local room = Mod.Game:GetRoom()
	for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(doorSlot)
		local player = PlayerManager.FirstTrinketOwner(KEY_TO_THE_PIT.ID)
		if player
			and room:IsClear()
			and door
			and door.TargetRoomType == RoomType.ROOM_CHALLENGE
			and not door:IsOpen()
		then
			local unlocked = door:TryUnlock(player, true)
			if unlocked then
				Mod.SFXMan:Stop(SoundEffect.SOUND_UNLOCK00)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, KEY_TO_THE_PIT.ForceDoorOpen)
