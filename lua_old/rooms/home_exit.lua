local Mod = Furtherance
local game = Game()

Mod:SavePlayerData({
	SleptInMomsBed = false
})

function Mod.RoomGenerator(index, slot, newroom)
	local level = game:GetLevel()
	local OldStage, OldStageType, OldChallenge = level:GetStage(), level:GetStageType(), game.Challenge
	-- Set to Basement 1
	level:SetStage(LevelStage.STAGE1_1, StageType.STAGETYPE_ORIGINAL)
	game.Challenge = Challenge.CHALLENGE_RED_REDEMPTION

	-- Make the room
	level:MakeRedRoomDoor(index, slot)

	RedRoom = level:GetRoomByIdx(newroom, 0)
	RedRoom.Flags = 0
	RedRoom.DisplayFlags = 0

	-- Revert Back to normal
	level:SetStage(OldStage, OldStageType)
	game.Challenge = OldChallenge
	level:UpdateVisibility()
end

function Mod:MakeExit(entity, collider)
	local level = game:GetLevel()
	if collider:ToPlayer() then
		local player = collider:ToPlayer()
		local data = Mod:GetData(player)
		if level:GetStage() == LevelStage.STAGE8 then
			if entity.SubType == 10 and data.SleptInMomsBed ~= true then
				data.SleptInMomsBed = true
				Mod.RoomGenerator(109, DoorSlot.DOWN0, 135)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, Mod.MakeExit, PickupVariant.PICKUP_BED)

function Mod:BedData(player)
	if Mod.IsContinued then return end
	local data = Mod:GetData(player)
	data.SleptInMomsBed = false
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, Mod.BedData)

--[[function Mod:Finale()
    for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
        local data = Mod:GetData(player)
        local level = game:GetLevel()
        local room = game:GetRoom()
        if level:GetStage() == LevelStage.STAGE8 and data.SleptInMomsBed == true and level:GetCurrentRoomIndex() == 84 and level:GetPreviousRoomIndex() == -3 then
            data.SleptInMomsBed = false
            game:GetHUD():SetVisible(false)
            level:SetStage(LevelStage.NUM_STAGES, 0)
            room:RemoveDoor(DoorSlot.DOWN0)
            for _, entity in ipairs(Isaac.GetRoomEntities()) do
                if entity.Type == EntityType.ENTITY_PICKUP then
                    entity:Remove()
                elseif entity.Type == EntityType.ENTITY_EFFECT then
                    entity:Remove()
                end
            end
            Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_TROPHY, 0, room:GetCenterPos(), Vector.Zero, nil)
        end
    end
end
Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, Mod.Finale)]]

function Mod:ExitRoom(player)
	local level = game:GetLevel()
	local data = Mod:GetData(player)

	if data.SleptInMomsBed == true then
		if (level:GetCurrentRoomIndex() == 109 or level:GetCurrentRoomIndex() == 122) then
			if player.Position.Y > 712 then
				Isaac.ExecuteCommand("goto d.0")
				level.LeaveDoor = -1
				game:StartRoomTransition(-3, Direction.DOWN, RoomTransitionAnim.WALK, player, -1)
				if level:GetRoomByIdx(135, 0).Clear == false then
					level:GetRoomByIdx(135, 0).Clear = true
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.ExitRoom)

-- Stop snooping around ;)
