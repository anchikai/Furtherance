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
			and door
			and not door:IsOpen()
		then
			local mult = PlayerManager.GetTotalTrinketMultiplier(DUNGEON_KEY.ID)
			local roomType = room:GetType()
			if (mult >= 2 or room:IsClear()) and (
				(door.TargetRoomType == RoomType.ROOM_CHALLENGE or roomType == RoomType.ROOM_CHALLENGE)
				or mult >= 2
				and (door.TargetRoomType == RoomType.ROOM_BOSS or roomType == RoomType.ROOM_BOSS)
			) then
				local unlocked = door:TryUnlock(player, true)
				if unlocked then
					Mod.SFXMan:Stop(SoundEffect.SOUND_UNLOCK00)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, DUNGEON_KEY.ForceDoorOpen)

function DUNGEON_KEY:SoulOfCain()
	local mult = PlayerManager.GetTotalTrinketMultiplier(DUNGEON_KEY.ID)
	if mult >= 3 and Mod.Room():GetType() == RoomType.ROOM_CHALLENGE then
		local player = PlayerManager.FirstTrinketOwner(DUNGEON_KEY.ID)
		---@cast player EntityPlayer
		player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM)
		player:AnimateTrinket(DUNGEON_KEY.ID, "UseItem", "PlayerPickupSparkle")
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, DUNGEON_KEY.SoulOfCain)