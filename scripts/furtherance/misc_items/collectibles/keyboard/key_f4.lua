local Mod = Furtherance

local F4_KEY = {}

Furtherance.Item.KEY_F4 = F4_KEY

F4_KEY.ID = Isaac.GetItemIdByName("F4 Key")

F4_KEY.ALLOWED_ROOMS = {
	Equal = Mod:Set({
		RoomType.ROOM_SUPERSECRET,
		RoomType.ROOM_ISAACS,
		RoomType.ROOM_BARREN,
		RoomType.ROOM_SECRET,
		RoomType.ROOM_SHOP,
		RoomType.ROOM_TREASURE,
		RoomType.ROOM_DICE,
		RoomType.ROOM_LIBRARY,
		RoomType.ROOM_CHEST,
		RoomType.ROOM_PLANETARIUM,
		RoomType.ROOM_ARCADE
	}),
	LeastCoins = Mod:Set({
		RoomType.ROOM_ARCADE
	}),
	LeastBombs = Mod:Set({
		RoomType.ROOM_SUPERSECRET,
		RoomType.ROOM_ISAACS,
		RoomType.ROOM_BARREN,
		RoomType.ROOM_SECRET
	}),
	LeastKeys = Mod:Set({
		RoomType.ROOM_SHOP,
		RoomType.ROOM_TREASURE,
		RoomType.ROOM_DICE,
		RoomType.ROOM_LIBRARY,
		RoomType.ROOM_CHEST,
		RoomType.ROOM_PLANETARIUM
	})
}
-- Thanks for solving this problem Connor!
---@param rng RNG
---@param player EntityPlayer
function F4_KEY:OnRegularUse(player, rng)
	local level = Mod.Level()
	local roomsList = level:GetRooms()
	local bombs = player:GetNumBombs()
	local coins = player:GetNumCoins()
	local keys = player:GetNumKeys()
	local allowedRooms

	if (coins == bombs) and (bombs == keys) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.Equal
	elseif (coins < bombs) and (coins < keys) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.LeastCoins
	elseif (bombs <= coins) and (bombs <= keys) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.LeastBombs
	elseif (keys <= coins) and (keys < bombs) then
		allowedRooms = F4_KEY.ALLOWED_ROOMS.LeastKeys
	end

	local unvisitedRooms = {}
	for i = 0, roomsList.Size - 1 do
		local roomDesc = roomsList:Get(i)
		if roomDesc.VisitedCount == 0 and allowedRooms[roomDesc.Data.Type] then
			table.insert(unvisitedRooms, roomDesc.GridIndex)
		end
	end

	if #unvisitedRooms > 0 then
		local choice = rng:RandomInt(#unvisitedRooms) + 1
		local roomIndex = unvisitedRooms[choice]
		Mod.Game:StartRoomTransition(roomIndex, Direction.NO_DIRECTION, 3)
		return true
	else
		player:AnimateSad()
		return false
	end
end

--TODO: Will do later
---@param player EntityPlayer
function F4_KEY:OnAltSynergyUse(player)
	local floor_save = Mod:FloorSave()
	floor_save.AltF4Shutdown = true
end

---@param rng RNG
---@param player EntityPlayer
function F4_KEY:OnUse(_, rng, player)
	if not player:HasCollectible(Mod.Item.KEY_ALT.ID) then
		return F4_KEY:OnRegularUse(player, rng)
	else -- Alt+F4 Synergy
		--F4_KEY:OnAltSynergyUse(player)
		--[[ local level = game:GetLevel()
		local room = game:GetRoom()
		local data = Mod:GetData(player)
		local stage = level:GetStage()
		local stageType = level:GetStageType()
		if room:IsCurrentRoomLastBoss() or (stage == LevelStage.STAGE4_3) or (stage == LevelStage.STAGE5) or (stage == LevelStage.STAGE6) or (stage == LevelStage.STAGE7) or (stage == LevelStage.STAGE8) or (stage == LevelStage.STAGE6_GREED) or (stage == LevelStage.STAGE7_GREED) or ((stage == LevelStage.STAGE4_2) and (stageType == StageType.STAGETYPE_REPENTANCE)) then
			Mod:playFailSound()
			player:AnimateSad()
		else
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_F4_KEY)
			player:RemoveCollectible(CollectibleType.COLLECTIBLE_ALT_KEY)
			MusicManager():Fadeout(0.01)
			player:AddNullCostume(NullItemID.ID_WAVY_CAP_3)
			data.Transition = 4
			data.AltF4 = true
		end ]]
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, F4_KEY.OnUse, F4_KEY.ID)
--[[
function Mod:RoomTransition(player)
	local data = Mod:GetData(player)
	local room = game:GetRoom()
	local level = game:GetLevel()
	if data.Transition == nil then
		data.Transition = 0
		data.AltF4 = false
		data.Boss = false
	elseif data.Transition < 0 then
		data.Transition = 0
	end
	if not (stage == LevelStage.STAGE4_3) or (stage == LevelStage.STAGE5) or (stage == LevelStage.STAGE6) or (stage == LevelStage.STAGE7) or (stage == LevelStage.STAGE8) or (stage == LevelStage.STAGE7_GREED) or ((stage == LevelStage.STAGE4_2) and (stageType == StageType.STAGETYPE_REPENTANCE)) then
		data.Transition = data.Transition - 1
		if data.AltF4 == true then
			SFXManager():Stop(SoundEffect.SOUND_DOOR_HEAVY_CLOSE)
			SFXManager():Stop(SoundEffect.SOUND_DOOR_HEAVY_OPEN)
			SFXManager():Stop(SoundEffect.SOUND_METAL_DOOR_CLOSE)
			SFXManager():Stop(SoundEffect.SOUND_METAL_DOOR_OPEN)
			for _, entity in pairs(Isaac.FindInRadius(player.Position, 9999, 95)) do
				entity:Remove()
			end
			for i = 1, room:GetGridSize() do
				local gridEntity2 = room:GetGridEntity(i)
				if gridEntity2 ~= nil then
					room:RemoveGridEntity(i, 0, false)
				end
			end
			if room:IsCurrentRoomLastBoss() and room:GetFrameCount() == 1 then
				data.AltF4 = false
				data.Boss = true
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, Mod.RoomTransition)

function Mod:UnJank()
	for i = 0, game:GetNumPlayers() - 1 do
		local player = Isaac.GetPlayer(i)
		local data = Mod:GetData(player)
		local level = game:GetLevel()
		local room = game:GetRoom()

		local stage = level:GetStage()
		local stageType = level:GetStageType()

		-- this "not" might be in the wrong spot, it only applies to the first stage condition...
		if not (stage == LevelStage.STAGE4_3) or (stage == LevelStage.STAGE5) or (stage == LevelStage.STAGE6) or (stage == LevelStage.STAGE7) or (stage == LevelStage.STAGE8) or (stage == LevelStage.STAGE7_GREED) or ((stage == LevelStage.STAGE4_2) and (stageType == StageType.STAGETYPE_REPENTANCE)) then
			if (data.Boss == true and room:IsCurrentRoomLastBoss()) or data.AltF4 == true then
				game:StartRoomTransition(level:GetCurrentRoomIndex(), Direction.NO_DIRECTION, RoomTransitionAnim.WALK,
					player, RoomTransitionAnim.WALK)
				data.Boss = false
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, Mod.UnJank)
 ]]