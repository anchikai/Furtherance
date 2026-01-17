local Mod = Furtherance

local DUNGEON_KEY = {}

Furtherance.Trinket.DUNGEON_KEY = DUNGEON_KEY

DUNGEON_KEY.ID = Isaac.GetTrinketIdByName("Dungeon Key")

function DUNGEON_KEY:ForceDoorOpen()
	local room = Mod.Game:GetRoom()
	local player = PlayerManager.FirstTrinketOwner(DUNGEON_KEY.ID)
	local mult = PlayerManager.GetTotalTrinketMultiplier(DUNGEON_KEY.ID)
	Mod.Foreach.Door(function (door, doorSlot)
		if player
			and not door:IsOpen()
			and (door.TargetRoomType == RoomType.ROOM_CHALLENGE and room:IsClear()
				or room:GetType() == RoomType.ROOM_CHALLENGE and mult >= 2
			)
		then
			local unlocked = door:TryUnlock(player, true)
			if unlocked then
				Mod.SFXMan:Stop(SoundEffect.SOUND_UNLOCK00)
			end
		end
	end)
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, DUNGEON_KEY.ForceDoorOpen)

function DUNGEON_KEY:ForceOpenBossRush()
	local mult = PlayerManager.GetTotalTrinketMultiplier(DUNGEON_KEY.ID)
	if mult < 2 then return end
	local level = Mod.Level()
	local room = Mod.Room()
	if (level:GetStage() == LevelStage.STAGE3_2
		or level:GetStage() == LevelStage.STAGE3_1 and Mod:HasBitFlags(level:GetCurses(), LevelCurse.CURSE_OF_LABYRINTH))
		and level:GetCurrentRoomDesc().ListIndex == level:GetLastBossRoomListIndex()
		and Mod.Game.TimeCounter >= Mod.Game.BossRushParTime
	then
		for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
			local door = room:GetDoor(i)
			if not door and room:TrySpawnBossRushDoor(true) then
				return
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, DUNGEON_KEY.ForceOpenBossRush)
Mod:AddCallback(ModCallbacks.MC_POST_ROOM_TRIGGER_CLEAR, DUNGEON_KEY.ForceOpenBossRush)

function DUNGEON_KEY:SoulOfCain()
	local mult = PlayerManager.GetTotalTrinketMultiplier(DUNGEON_KEY.ID)

	if mult >= 3 and Mod.Room():GetType() == RoomType.ROOM_CHALLENGE then
		local player = PlayerManager.FirstTrinketOwner(DUNGEON_KEY.ID)
		---@cast player EntityPlayer
		player:UseCard(Card.CARD_SOUL_CAIN, UseFlag.USE_NOANIM | UseFlag.USE_NOANNOUNCER)
		player:AnimateTrinket(DUNGEON_KEY.ID, "UseItem", "PlayerPickupSparkle")
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, CallbackPriority.LATE, DUNGEON_KEY.SoulOfCain)