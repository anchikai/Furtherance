local Mod = Furtherance

local DUNGEON_KEY = {}

Furtherance.Trinket.DUNGEON_KEY = DUNGEON_KEY

DUNGEON_KEY.ID = Isaac.GetTrinketIdByName("Dungeon Key")

function DUNGEON_KEY:ForceDoorOpen()
	local room = Mod.Game:GetRoom()
	for doorSlot = DoorSlot.LEFT0, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(doorSlot)
		local player = PlayerManager.FirstTrinketOwner(DUNGEON_KEY.ID)
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

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, DUNGEON_KEY.ForceDoorOpen)
