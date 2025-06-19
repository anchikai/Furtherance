local Mod = Furtherance

local EPITAPH = {}

Furtherance.Item.EPITAPH = EPITAPH

EPITAPH.ID = Isaac.GetItemIdByName("Epitaph")

EPITAPH.TOMBSTONE_GRID_VARIANT = 349
EPITAPH.TOMBSTONE_MAX_HITS = 3

EPITAPH.NPC_REVIVE_CHANCE = 0.1

EPITAPH.TOMBSTONE_JINGLE = Isaac.GetSoundIdByName("Tombstone Jingle")
EPITAPH.JINGLE_DISTANCE_THRESHOLD = 400
EPITAPH.JINGLE_MIN_VOLUME_DISTANCE = 75 ^ 2
EPITAPH.JINGLE_CHANCE = 0.1
EPITAPH.PLAY_JINGLE = false

local reviveLocations = {}

--#region Track items on death

---No active items, no trinkets, no starting items
---@param historyItem HistoryItem
function EPITAPH:IsValidPassive(historyItem)
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
			if EPITAPH:IsValidPassive(historyItem) then
				firstItem = historyItem:GetItemID()
			end
		end
		for i = #history, 1, -1 do
			local historyItem = history[i]
			if (not firstItem or historyItem:GetItemID() ~= firstItem)
				and EPITAPH:IsValidPassive(historyItem)
			then
				lastItem = historyItem:GetItemID()
			end
		end
		if firstItem then
			Mod.Insert(inv.Collectibles, firstItem)
			Mod:DebugLog("Added", Mod:TryGetTranslatedString("Items", (Mod.ItemConfig:GetCollectible(firstItem).Name)),
				"as first collected item")
		end
		if lastItem then
			Mod.Insert(inv.Collectibles, lastItem)
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
		Mod.Foreach.Player(function(player)
			local player_run_save = Mod:RunSave(player)
			if player_run_save.EpitaphInventory then
				game_save.EpitaphTombstones = game_save.EpitaphTombstones or {}
				Mod.Insert(game_save.EpitaphTombstones, player_run_save.EpitaphInventory)
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
	for index = #(run_save.EpitaphTombstones or {}), 1, -1 do
		local tombstoneData = run_save.EpitaphTombstones[index]
		if stage == tombstoneData.LevelStage then
			Mod:DebugLog("Reached Epitaph Tombestone floor!")
			Mod.Insert(tombstones, tombstoneData)
			table.remove(run_save.EpitaphTombstones, index)
		end
	end
	local rooms = Mod:GetRandomRoomsOnFloor(#tombstones, Mod.GENERIC_RNG, function(room)
		return room.Data.Type == RoomType.ROOM_DEFAULT
	end)
	for i, roomDesc in ipairs(rooms) do
		floor_save.EpitaphTombstoneToSpawn = floor_save.EpitaphTombstoneToSpawn or {}
		floor_save.EpitaphTombstoneToSpawn[tostring(roomDesc.ListIndex)] = tombstones[i]
		Mod:DebugLog("Epitaph Tombestone to spawn in the following room:", "\nList Index:", roomDesc.ListIndex, "\nRoom Type:", roomDesc.Data.Type, "\nGridIndex:", roomDesc.GridIndex)
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
			Mod:DebugLog("Tombstone spawned successfully at grid index", gridEnt:GetGridIndex())
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
	sprite:Load("gfx/grid/grid_epitaph_tombstone.anm2", true)
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
	local hasTombstone = false

	Mod.Foreach.Grid(function(gridEnt, gridIndex)
		EPITAPH:UpdateSprite(gridEnt, gridEnt:GetSaveState().VarData)
		hasTombstone = true
	end, GridEntityType.GRID_ROCKB, EPITAPH.TOMBSTONE_GRID_VARIANT)

	if hasTombstone and not Mod.Room():IsFirstVisit() then
		EPITAPH.PLAY_JINGLE = Mod.GENERIC_RNG:RandomFloat() <= EPITAPH.JINGLE_CHANCE
	else
		EPITAPH.PLAY_JINGLE = false
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EPITAPH.UpdateTombstoneOnNewRoom)

---@return GridEntity?
function EPITAPH:SpawnTombstone()
	local room = Mod.Room()
	local gridIndex = room:GetRandomTileIndex(Mod.GENERIC_RNG:Next())
	local gridSpawned = room:SpawnGridEntity(gridIndex, GridEntityType.GRID_ROCKB, EPITAPH.TOMBSTONE_GRID_VARIANT,
		Mod.GENERIC_RNG:Next())
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

	Mod.Foreach.Effect(function(effect, index)
		local dist = effect.Position:DistanceSquared(gridEnt.Position)
		if dist <= (120 * effect.SpriteScale.X) ^ 2 and effect.FrameCount == 1 then
			EPITAPH:DamageTombstone(gridEnt)
		end
	end, EffectVariant.BOMB_EXPLOSION)

	Mod.Foreach.Effect(function(effect, index)
		local dist = effect.Position:DistanceSquared(gridEnt.Position)
		if dist <= effect.Scale ^ 2 then
			EPITAPH:DestroyTombstone(gridEnt)
		end
	end, EffectVariant.MAMA_MEGA_EXPLOSION)

	if EPITAPH.PLAY_JINGLE then
		EPITAPH:DistanceBasedJingle(gridEnt.Position)
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

--#region Passive Book of the Dead-like effect

--Shoutout to the wiki for the exact specifications of what enemy can spawn from Book of the Dead

---@param npc EntityNPC
function EPITAPH:TryMarkReviveLocation(npc)
	if PlayerManager.AnyoneHasCollectible(EPITAPH.ID) then
		local rng = PlayerManager.FirstCollectibleOwner(EPITAPH.ID):GetCollectibleRNG(EPITAPH.ID)
		if rng:RandomFloat() <= EPITAPH.NPC_REVIVE_CHANCE then
			Mod.Insert(reviveLocations, npc)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NPC_DEATH, EPITAPH.TryMarkReviveLocation)

local ENEMY_CHANCE = 0.2
local MAX_ENEMIES = 8
local BLACK_BONY_CHANCE = 0.25
local BIG_BONY_CHANCE = 0.25
local BONE_FLY_CHANCE = 0.25
local REVENANT_CHANCE = 0.01
local min = math.min

---@param npc EntityNPC
local function canBecomeBigBony(npc)
	local entityConfig = npc:GetEntityConfigEntity()
	local floor = Mod.Level():GetStage()
	local baseHP = entityConfig:GetBaseHP()
	local stageHP = entityConfig:GetStageHP()
	return baseHP + floor * stageHP * min(floor, 10) * 0.8 > 18 + floor * 3 * min(floor, 10) * 0.8
end

local function getRevenantBonusChance()
	local level = Mod.Level()
	local stage = level:GetStage()
	local stageType = level:GetStageType()
	--Sheol, Dark Room, Mausoleum, or Gehenna
	if stage == LevelStage.STAGE5 and stageType == StageType.STAGETYPE_ORIGINAL
		or stage == LevelStage.STAGE6 and stageType == StageType.STAGETYPE_ORIGINAL
		or (stage == LevelStage.STAGE3_1 or stage == LevelStage.STAGE3_2)
		and stageType >= StageType.STAGETYPE_REPENTANCE
	then
		return 8.33
	end
	return 0
end

function EPITAPH:ReviveEnemies()
	if PlayerManager.AnyoneHasCollectible(EPITAPH.ID) then
		local rng = PlayerManager.FirstCollectibleOwner(EPITAPH.ID):GetCollectibleRNG(EPITAPH.ID)
		local numEnemies = 0
		for _, npc in ipairs(reviveLocations) do
			local randomPlayer = PlayerManager.FirstCollectibleOwner(EPITAPH.ID)
			---@cast randomPlayer EntityPlayer
			if rng:RandomFloat() <= ENEMY_CHANCE and numEnemies < MAX_ENEMIES then
				local newType = EntityType.ENTITY_BONY
				local newVariant = 0
				numEnemies = numEnemies + 1
				if rng:RandomFloat() <= BLACK_BONY_CHANCE then
					newType = EntityType.ENTITY_BLACK_BONY
				end
				if canBecomeBigBony(npc) and rng:RandomFloat() <= BIG_BONY_CHANCE then
					newType = EntityType.ENTITY_BIG_BONY
				end
				if rng:RandomFloat() <= BONE_FLY_CHANCE then
					newType = EntityType.ENTITY_BOOMFLY
					newVariant = 4
				end
				if rng:RandomFloat() <= REVENANT_CHANCE + getRevenantBonusChance() then
					newType = EntityType.ENTITY_REVENANT
					newVariant = 0
				end
				local newNPC = Isaac.Spawn(newType, newVariant, 0, npc.Position, Vector.Zero, randomPlayer)
				newNPC:AddCharmed(EntityRef(randomPlayer), -1)
			else
				randomPlayer:AddBoneOrbital(npc.Position)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, EPITAPH.ReviveEnemies)

function EPITAPH:ResetReviveLocationsOnNewRoom()
	Mod:ClearTable(reviveLocations, true)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EPITAPH.ResetReviveLocationsOnNewRoom)

--#endregion

--#region Funny Jingle

function EPITAPH:DistanceBasedJingle(pos)
	if Mod.Room():GetFrameCount() == 0 then return end
	local player, distance = Mod:GetClosestEntity(pos, EPITAPH.JINGLE_DISTANCE_THRESHOLD, EntityPartition.PLAYER)
	if player and distance then
		if not Mod.SFXMan:IsPlaying(EPITAPH.TOMBSTONE_JINGLE) then
			Mod.SFXMan:Play(EPITAPH.TOMBSTONE_JINGLE, 1, 2, true, 1, 0)
		end
		local distanceRange = (distance - EPITAPH.JINGLE_MIN_VOLUME_DISTANCE) /
			((EPITAPH.JINGLE_DISTANCE_THRESHOLD ^ 2) - EPITAPH.JINGLE_MIN_VOLUME_DISTANCE)
		local oppositeDistance = 1 - distanceRange
		local volume = Mod:Clamp(oppositeDistance, 0, 1)
		local musicVolume = Mod:Clamp(distanceRange, 0, 1)
		Mod.SFXMan:AdjustVolume(EPITAPH.TOMBSTONE_JINGLE, volume)
		Mod.MusicMan:VolumeSlide(musicVolume, 1)
	end
end

function EPITAPH:StopJingle()
	if Mod.SFXMan:IsPlaying(EPITAPH.TOMBSTONE_JINGLE) then
		Mod.SFXMan:Stop(EPITAPH.TOMBSTONE_JINGLE)
		Mod.MusicMan:UpdateVolume()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, EPITAPH.StopJingle)

--#endregion

--#region Commands

Mod.ConsoleCommandHelper:Create("epitaphtombstone-queue", "Queues an Epitaph tombstone to spawn on the first floor when next entered.", {}, function ()
	local save = Isaac.IsInGame() and Mod:RunSave() or Mod:GameSave()
	save.EpitaphTombstones = {
		{LevelStage = LevelStage.STAGE1_1, Collectibles = {1, 2}}
	}
end)
Mod.ConsoleCommandHelper:SetParent("epitaphtombstone-queue", "debug")
Mod.ConsoleCommandHelper:Create("epitaphtombstone-spawn", "Spawns an Epitaph tombstone in the room.",
	{
		Mod.ConsoleCommandHelper:MakeArgument("item1", "E", Mod.ConsoleCommandHelper.ArgumentTypes.Number, true),
		Mod.ConsoleCommandHelper:MakeArgument("item2", "A", Mod.ConsoleCommandHelper.ArgumentTypes.Number, true),
	},
function(arguments)
	local gridEnt = EPITAPH:SpawnTombstone()
	if gridEnt then
		if arguments[1] and arguments[2] then
			local grid_save = Mod:RoomSave(gridEnt:GetGridIndex())
			local items = {arguments[1] and arguments[2]}
			grid_save.TombstoneCollectibles = items
		end
		return "[Furtherance] Tombstone spawned successfully at grid index " .. gridEnt:GetGridIndex()
	else
		return "[Furtherance] Epitaph Tombstone failed to spawn!"
	end
end)
Mod.ConsoleCommandHelper:SetParent("epitaphtombstone-spawn", "debug")

--#endregion