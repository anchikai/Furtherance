local Mod = Furtherance

local EPITAPH = {}

Furtherance.Item.EPITAPH = EPITAPH

EPITAPH.ID = Isaac.GetItemIdByName("Epitaph")

EPITAPH.TOMBSTONE_GRID_VARIANT = 349
EPITAPH.TOMBSTONE_MAX_HITS = 3

--#region Track items on death

---No active items, no trinkets, no starting items
---@param historyItem HistoryItem
function EPITAPH:IsValidItemToSave(historyItem)
	return historyItem:GetTime() > 1
		and not historyItem:IsTrinket()
		and Mod.ItemConfig:GetCollectible(historyItem:GetItemID()).Type ~= ItemType.ITEM_ACTIVE
		and historyItem:GetItemID() ~= EPITAPH.ID
end

---Triggers after certain death, as it doesn't run for vanilla revives and will be cancelled for modded revives
---@param player EntityPlayer
function EPITAPH:SavePlayerInventoryOnDeath(player)
	if player:HasCollectible(EPITAPH.ID) then
		Mod:DebugLog("Died with Epitaph! Checking inventory...")
		local player_run_save = Mod:RunSave(player)
		local inv = { LevelStage = Mod.Level():GetAbsoluteStage(), Collectibles = {} }
		local history = player:GetHistory():GetCollectiblesHistory()
		local firstItem
		local lastItem
		for _, historyItem in ipairs(history) do
			if EPITAPH:IsValidItemToSave(historyItem) then
				firstItem = historyItem:GetItemID()
			end
		end
		Furtherance:inverseiforeach(history, function(historyItem)
			if (not firstItem or historyItem:GetItemID() ~= firstItem)
				and EPITAPH:IsValidItemToSave(historyItem)
			then
				lastItem = historyItem:GetItemID()
			end
		end)
		if firstItem then
			Mod:Insert(inv.Collectibles, firstItem)
			Mod:DebugLog("Added", Mod:TryGetTranslatedString("Items", (Mod.ItemConfig:GetCollectible(firstItem).Name)),
				"as first collected item")
		end
		if lastItem then
			Mod:Insert(inv.Collectibles, lastItem)
			Mod:DebugLog("Added", Mod:TryGetTranslatedString("Items", (Mod.ItemConfig:GetCollectible(lastItem).Name)),
				"as last collected item")
		end
		if firstItem or lastItem then
			player_run_save.EpitaphInventory = inv
		end
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_TRIGGER_PLAYER_DEATH_POST_CHECK_REVIVES, CallbackPriority.LATE,
	EPITAPH.SavePlayerInventoryOnDeath)

---@param player EntityPlayer
function EPITAPH:PostRevive(player)
	if player:HasCollectible(EPITAPH.ID) then
		local player_run_save = Mod:RunSave(player)
		Mod:DelayOneFrame(function()
			print("ello")
			if player:IsCoopGhost() and player_run_save.EpitaphInventory then
				player_run_save.EpitaphCheckCoopGhostMorph = true
				Mod:DebugLog("Player is a Co-Op Ghost. Mark for tracking revival")
			else
				player_run_save.EpitaphInventory = nil
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_REVIVE, EPITAPH.PostRevive)

---Co-op ghosts technically count as a "revived player" and are morphed into a real player if "revived" later on
--
---Check if the player revives to see if Epitaph inventory should be invalidated or not
---@param player EntityPlayer
function EPITAPH:TrackCoopGhost(player)
	local player_run_save = Mod:RunSave(player)
	if player_run_save.EpitaphCheckCoopGhostMorph
		and not player:IsCoopGhost()
	then
		Mod:DebugLog("Co-Op Ghost revived! Epitaph saved inventory removed")
		player_run_save.EpitaphInventory = nil
		player_run_save.EpitaphCheckCoopGhostMorph = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, EPITAPH.TrackCoopGhost)

---Player has died. Transfer all run saves to a file save to keep for the next run
---@param isGameOver boolean
function EPITAPH:OnGameOver(isGameOver)
	if isGameOver then
		local game_save = Mod:GameSave()
		Mod:ForEachPlayer(function(player)
			print("yipee")
			local player_run_save = Mod:RunSave(player)
			if player_run_save.EpitaphInventory then
				game_save.EpitaphTombstones = game_save.EpitaphTombstones or {}
				Mod:Insert(game_save.EpitaphTombstones, player_run_save.EpitaphInventory)
				Mod:DebugLog("Added Tombstone to spawn on LevelStage", player_run_save.EpitaphInventory.LevelStage)
			end
		end)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GAME_END, EPITAPH.OnGameOver)


--#endregion

--#region Spawn Tombstones on proceeding run

function EPITAPH:OnGameStart()
	local game_save = Mod:GameSave()
	if game_save.EpitaphTombstones then
		Mod:DebugLog("Epitaph Tombstone file save detected! Converting to run save")
		local run_save = Mod:RunSave()
		run_save.EpitaphTombstones = game_save.EpitaphTombstones
		game_save.EpitaphTombstones = nil
	end
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.POST_GLOBAL_DATA_LOAD, EPITAPH.OnGameStart)

function EPITAPH:PostNewLevel()
	local run_save = Mod:RunSave()
	local stage = Mod.Level():GetAbsoluteStage()
	local floor_save = Mod:FloorSave()
	local tombstones = {}
	Furtherance:inverseiforeach(run_save.EpitaphTombstones or {}, function(tombstoneData, index)
		if stage == tombstoneData.LevelStage then
			Mod:DebugLog("Reached Epitaph Tombestone floor!")
			Mod:Insert(tombstones, tombstoneData)
			table.remove(run_save.EpitaphTombstones, index)
		end
	end)
	local rooms = Mod:GetRandomRooms(#tombstones, Mod.GENERIC_RNG, function(room)
		return room.Data.Type == RoomType.ROOM_DEFAULT
	end)
	for i, roomDesc in ipairs(rooms) do
		floor_save.EpitaphTombstoneToSpawn = floor_save.EpitaphTombstoneToSpawn or {}
		floor_save.EpitaphTombstoneToSpawn[tostring(roomDesc.ListIndex)] = tombstones[i]
		Mod:DebugLog("Epitaph Tombestone to spawn at ListIndex", roomDesc.ListIndex)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, EPITAPH.PostNewLevel)

function EPITAPH:PostNewRoom()
	local floor_save = Mod:FloorSave()
	if not floor_save.EpitaphTombstoneToSpawn then return end
	local listIndex = Mod.Level():GetCurrentRoomDesc().ListIndex
	local queued_tombestone = floor_save.EpitaphTombstoneToSpawn[tostring(listIndex)]
	if queued_tombestone then
		Mod:DebugLog("Room reached! Spawning Epitaph Tombstone")
		local gridEnt = EPITAPH:SpawnTombstone()
		if gridEnt then
			local grid_save = Mod:RoomSave(gridEnt:GetGridIndex())
			grid_save.TombstoneCollectibles = queued_tombestone.Collectibles
			Mod:DebugLog("Tombestone spawned successfully")
		else
			Mod:DebugLog("Epitaph Tombstone failed to spawn!")
		end
		floor_save.EpitaphTombstoneToSpawn[tostring(listIndex)] = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EPITAPH.PostNewRoom)

--#endregion

--#region The Tombstone

---@param gridEnt GridEntity
function EPITAPH:IsTombstone(gridEnt)
	return gridEnt:GetType() == GridEntityType.GRID_ROCKB and gridEnt:GetVariant() == EPITAPH.TOMBSTONE_GRID_VARIANT
end

---@param gridEnt GridEntity
---@param varData integer
function EPITAPH:UpdateSprite(gridEnt, varData)
	local sprite = gridEnt:GetSprite()
	sprite:Load("gfx/grid_epitaph_tombstone.anm2")
	local anim = "Normal"
	if varData > 0 and varData <= 2 then
		anim = "Damaged" .. varData
	elseif varData == 0 then
		anim = "Idle"
	else
		anim = "Destroyed"
	end
	sprite:Play(anim)
end

function EPITAPH:UpdateTombstoneOnNewRoom()
	local room = Mod.Room()
	for i = 0, room:GetGridSize() - 1 do
		local gridEnt = room:GetGridEntity(i)
		if gridEnt
			and gridEnt:GetType() == GridEntityType.GRID_ROCKB
			and gridEnt:GetVariant() == EPITAPH.TOMBSTONE_GRID_VARIANT
		then
			EPITAPH:UpdateSprite(gridEnt, gridEnt:GetSaveState().VarData)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EPITAPH.UpdateTombstoneOnNewRoom)

---@return GridEntity?
function EPITAPH:SpawnTombstone()
	local room = Mod.Room()
	local gridIndex = room:GetRandomTileIndex(Mod.GENERIC_RNG:GetSeed())
	Mod.GENERIC_RNG:Next()
	local gridSpawned = room:SpawnGridEntity(gridIndex, GridEntityType.GRID_ROCKB, EPITAPH.TOMBSTONE_GRID_VARIANT,
		Mod.GENERIC_RNG:GetSeed())
	Mod.GENERIC_RNG:Next()
	if gridSpawned then
		local gridEnt = room:GetGridEntity(gridIndex)
		--It reverts to a different random variant upon first spawning
		gridEnt:SetVariant(EPITAPH.TOMBSTONE_GRID_VARIANT)
		EPITAPH:UpdateSprite(gridEnt, 0)
		return gridEnt
	end
end

---@param gridEnt GridEntityRock
function EPITAPH:DamageTombstone(gridEnt)
	Mod:DebugLog("Tombstone damaged")
	local varData = gridEnt.VarData
	if varData < 3 then
		gridEnt.VarData = varData + 1
		varData = gridEnt.VarData
		Mod:DebugLog("Increasing Tombestone VarData by 1")
	end
	if varData == 3 then
		EPITAPH:DestroyTombstone(gridEnt)
		Mod:DebugLog("Spawning Tombstone rewards")
	end
	EPITAPH:UpdateSprite(gridEnt, varData)
end

---@param gridEnt GridEntityRock
function EPITAPH:TombstoneUpdate(gridEnt)
	if not EPITAPH:IsTombstone(gridEnt) or gridEnt.VarData >= 3 then
		return
	end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_EXPLOSION)) do
		local dist = ent.Position:DistanceSquared(gridEnt.Position)
		if dist <= (120 * ent.SpriteScale.X) ^ 2 and ent.FrameCount == 1 then
			EPITAPH:DamageTombstone(gridEnt)
		end
	end
	for _, ent in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.MAMA_MEGA_EXPLOSION)) do
		local effect = ent:ToEffect()
		---@cast effect EntityEffect
		local dist = ent.Position:DistanceSquared(gridEnt.Position)
		if dist <= effect.Scale ^ 2 then
			EPITAPH:DestroyTombstone(gridEnt)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_GRID_ENTITY_ROCK_UPDATE, EPITAPH.TombstoneUpdate, GridEntityType.GRID_ROCKB)

---@param gridEnt GridEntityRock
function EPITAPH:DestroyTombstone(gridEnt)
	local rng = gridEnt:GetRNG()
	rng:SetSeed(gridEnt:GetSaveState().SpawnSeed)
	local room = Mod.Room()
	local grid_save = Mod:RoomSave(gridEnt:GetGridIndex())
	local coinCount = rng:RandomInt(3) + 3

	for _ = 1, coinCount do
		local velocity = EntityPickup.GetRandomPickupVelocity(gridEnt.Position, rng)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COIN, CoinSubType.COIN_PENNY,
			gridEnt.Position, velocity, nil)
	end

	local keyCount = rng:RandomInt(2) + 2
	for _ = 1, keyCount do
		local velocity = EntityPickup.GetRandomPickupVelocity(gridEnt.Position, rng)
		Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_KEY, KeySubType.KEY_NORMAL, gridEnt.Position,
			velocity, nil)
	end

	if grid_save.TombstoneCollectibles then
		for _, itemID in ipairs(grid_save.TombstoneCollectibles) do
			Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, itemID,
				room:FindFreePickupSpawnPosition(gridEnt.Position, 40), Vector.Zero, nil)
		end
	end
	if gridEnt.VarData < 3 then
		gridEnt.VarData = 3
	end
	local sprite = gridEnt:GetSprite()
	sprite:Load("gfx/grid/grid_rock.anm2")
	sprite:Play("rubble")
	sprite:ReplaceSpritesheet(0, "gfx/grid/rocks_depths.png", true)
	gridEnt:SetType(1)
	gridEnt:Destroy(true)
end

--#endregion
