--#region Variables

local Mod = Furtherance

local ESCORT_BEGGAR = {}

Furtherance.Slot.ESCORT_BEGGAR = ESCORT_BEGGAR

ESCORT_BEGGAR.SLOT = Isaac.GetEntityVariantByName("Escort Beggar (Slot)")
ESCORT_BEGGAR.FAMILIAR = Isaac.GetEntityVariantByName("Escort Beggar (Familiar)")
ESCORT_BEGGAR.ITEM_POOL = Isaac.GetPoolIdByName("escortBeggar")

ESCORT_BEGGAR.REPLACE_CHANCE = 0.05

--You can blame Warhamm for these
ESCORT_BEGGAR.ANIM_RAISE_HANDS = "GdezheVashiRuchkiNuGdezheVashiRuchki"
ESCORT_BEGGAR.ANIM_HANDS_LOOP =
"WaitingForTheeToSpillAFractionOfPityAtLongLastCOMMAWithAHopeForRequestToBeFinallyFulfilledAndItsDestinyToBeConcludedPERIOD"

ESCORT_BEGGAR.ROOM_TYPES = {
	RoomType.ROOM_SECRET,
	RoomType.ROOM_SUPERSECRET,
	RoomType.ROOM_CURSE,
	RoomType.ROOM_ISAACS,
	RoomType.ROOM_TREASURE,
	RoomType.ROOM_SHOP,
	RoomType.ROOM_SACRIFICE,
	RoomType.ROOM_BARREN,
	RoomType.ROOM_ARCADE,
	RoomType.ROOM_LIBRARY,
	RoomType.ROOM_DICE,
	RoomType.ROOM_CHEST
}
ESCORT_BEGGAR.ROOM_TYPES_MAP = {
	[RoomType.ROOM_SECRET] = "IconSecretRoom",
	[RoomType.ROOM_SUPERSECRET] = "IconSuperSecretRoom",
	[RoomType.ROOM_CURSE] = "IconCurseRoom",
	[RoomType.ROOM_ISAACS] = "IconIsaacsRoom",
	[RoomType.ROOM_TREASURE] = "IconTreasure",
	[RoomType.ROOM_SHOP] = "IconShop",
	[RoomType.ROOM_SACRIFICE] = "IconSacrificeRoom",
	[RoomType.ROOM_BARREN] = "IconBarrenRoom",
	[RoomType.ROOM_ARCADE] = "IconArcade",
	[RoomType.ROOM_LIBRARY] = "IconLibrary",
	[RoomType.ROOM_DICE] = "IconDiceRoom",
	[RoomType.ROOM_CHEST] = "IconChestRoom",
}

local BEGGAR_POSITION_OFFSET = Vector(0, 8)
ESCORT_BEGGAR.THROW_OFFSET = Vector(0, -32)

ESCORT_BEGGAR.SLOW_DOWN = -0.5
ESCORT_BEGGAR.ABANDONED_COUNTDOWN = 30 * 5

--#endregion

--#region Helpers

function ESCORT_BEGGAR:FindFarthestSpecialRoom()
	local roomDesc = Mod.Level():GetCurrentRoomDesc()
	if roomDesc.GridIndex < 0 then
		return
	end
	local roomQueue = { roomDesc }
	local checkedRooms = { [roomDesc.GridIndex] = 0 }
	local farthestRoom
	while #roomQueue > 0 do
		local curRoomDesc = roomQueue[1]
		local neighbors = curRoomDesc:GetNeighboringRooms()
		for _, neighbor in pairs(neighbors) do
			if not checkedRooms[neighbor.GridIndex] then
				Mod.Insert(roomQueue, neighbor)
				local distance = checkedRooms[curRoomDesc.GridIndex] + 1
				checkedRooms[neighbor.GridIndex] = distance
				if ESCORT_BEGGAR.ROOM_TYPES_MAP[neighbor.Data.Type] and (not farthestRoom or distance > farthestRoom.Distance) then
					farthestRoom = { Distance = distance, RoomType = neighbor.Data.Type }
				end
			end
		end
		table.remove(roomQueue, 1)
	end
	if farthestRoom then
		Mod:DebugLog("Farthest valid special room is type", Mod:Invert(RoomType)[farthestRoom.RoomType] .. ",",
			farthestRoom.Distance, "rooms away")
		return farthestRoom.RoomType
	else
		Mod:DebugLog("No valid special rooms found")
	end
end

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:IsBeingThrown(familiar)
	return Mod:GetData(familiar).EscortBeingThrown
end

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:IsHeldByPlayer(familiar)
	return Mod:GetData(familiar).EscortHeldByPlayer
end

---@param player EntityPlayer
function ESCORT_BEGGAR:IsHoldingBeggar(player)
	local heldEnt = player:GetHeldEntity()
	return heldEnt and heldEnt:ToFamiliar() and heldEnt.Variant == ESCORT_BEGGAR.FAMILIAR
end

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:IsGrounded(familiar)
	return not ESCORT_BEGGAR:IsBeingThrown(familiar) and not ESCORT_BEGGAR:IsHeldByPlayer(familiar)
end

--#endregion

--#region Slot

---@param slot EntitySlot
function ESCORT_BEGGAR:OnSlotInit(slot)
	local room_save = Mod:RoomSave(slot)

	slot.PositionOffset = Vector(0, 5)

	if slot.SpawnerType == EntityType.ENTITY_FAMILIAR and slot.SpawnerVariant == ESCORT_BEGGAR.FAMILIAR then
		return
	end

	--Don't spawn one if there's already one present
	if #Isaac.FindByType(EntityType.ENTITY_SLOT, ESCORT_BEGGAR.SLOT) > 0
		or #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ESCORT_BEGGAR.FAMILIAR) == #Mod:FilterList(PlayerManager.GetPlayers(),
			function(player)
				return player.Variant == PlayerVariant.PLAYER
			end)
		or Mod.Game:IsGreedMode()
	then
		slot:Remove()
		Mod.Spawn.Slot(SlotVariant.BEGGAR, slot.Position, slot.SpawnerEntity)
		return
	end
	if not room_save.EscortRoom then
		local escortRoom = ESCORT_BEGGAR:FindFarthestSpecialRoom()
		if escortRoom then
			room_save.EscortRoom = escortRoom
		else
			slot:Remove()
			Mod.Spawn.Slot(SlotVariant.BEGGAR, slot.Position, slot.SpawnerEntity)
			return
		end
	end

	local data = Mod:GetData(slot)
	local roomFrame
	for i, roomType in ipairs(ESCORT_BEGGAR.ROOM_TYPES) do
		if room_save.EscortRoom == roomType then
			roomFrame = i - 1
		end
	end
	if not roomFrame then return end
	local sprite = Sprite(slot:GetSprite():GetFilename(), true)
	sprite:SetFrame("Signs", roomFrame)
	data.RoomSign = sprite
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_INIT, ESCORT_BEGGAR.OnSlotInit, ESCORT_BEGGAR.SLOT)

---@param slot EntitySlot
function ESCORT_BEGGAR:OnSlotUpdate(slot)
	local sprite = slot:GetSprite()

	if sprite:IsEventTriggered("Happy") then
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSUP)
	elseif sprite:IsEventTriggered("SpawnFamiliar") then
		local floor_save = Mod:FloorSave()
		floor_save.EscortBeggars = (floor_save.EscortBeggars or 0) + 1
		ESCORT_BEGGAR:GetFirstAlivePlayer():AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
	elseif slot:GetState() == Mod.SlotState.BOMBED and not slot:IsDead() then
		ESCORT_BEGGAR:DeathParticles(slot.Position)
		Mod.Level():SetStateFlag(LevelStateFlag.STATE_BUM_KILLED, true)
		slot:Remove()
	elseif slot:GetState() == Mod.SlotState.PAYOUT then
		if sprite:IsEventTriggered("Prize") then
			Mod.SFXMan:Play(SoundEffect.SOUND_SLOTSPAWN)
			local itemID = Mod.Game:GetItemPool():GetCollectible(ESCORT_BEGGAR.ITEM_POOL, true, slot.InitSeed)
			local pos = Mod.Room():FindFreePickupSpawnPosition(slot.Position, 40, true, false)
			Mod.Spawn.Pickup(PickupVariant.PICKUP_COLLECTIBLE, itemID, pos, nil, slot, slot.InitSeed)
		elseif sprite:IsFinished("Prize") then
			sprite:Play("Teleport")
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_UPDATE, ESCORT_BEGGAR.OnSlotUpdate, ESCORT_BEGGAR.SLOT)

---@param slot EntitySlot
---@param offset Vector
function ESCORT_BEGGAR:OnSlotRender(slot, offset)
	local data = Mod:GetData(slot)
	---@type Sprite
	local roomSign = data.RoomSign
	if roomSign then
		local sprite = slot:GetSprite()
		local frame = sprite:GetNullFrame("Sign")
		if frame and frame:IsVisible() then
			local renderPos
			if Mod.Room():GetRenderMode() == RenderMode.RENDER_WATER_REFLECT then
				renderPos = Isaac.WorldToRenderPosition(slot.Position + slot.PositionOffset) + offset
			else
				renderPos = Isaac.WorldToScreen(slot.Position + slot.PositionOffset) + offset
			end
			roomSign:Render(renderPos + frame:GetPos())
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_RENDER, ESCORT_BEGGAR.OnSlotRender, ESCORT_BEGGAR.SLOT)

---@param slot EntitySlot
---@param collider Entity
function ESCORT_BEGGAR:OnSlotCollision(slot, collider)
	local player = collider:ToPlayer()
	if not player then return end
	local sprite = slot:GetSprite()
	if slot:GetState() == Mod.SlotState.IDLE and not sprite:IsPlaying("Touch") then
		slot:GetSprite():Play("Touch")
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_SLOT_COLLISION, ESCORT_BEGGAR.OnSlotCollision, ESCORT_BEGGAR.SLOT)

--#endregion

--#region Spawning beggar

function ESCORT_BEGGAR:GetFirstAlivePlayer()
	return Mod.Foreach.Player(function(player, index)
		if not player:IsCoopGhost() and not player:IsDead() and player.Variant == PlayerVariant.PLAYER then
			return player
		end
	end)
end

---@param player EntityPlayer
function ESCORT_BEGGAR:OnFamiliarCache(player)
	local firstAlivePlayer = ESCORT_BEGGAR:GetFirstAlivePlayer()
	if GetPtrHash(player) ~= GetPtrHash(firstAlivePlayer) then return end
	local numBeggars = Mod:FloorSave().EscortBeggars or 0
	local familiars = player:CheckFamiliarEx(ESCORT_BEGGAR.FAMILIAR, numBeggars, RNG())

	for _, familiar in ipairs(familiars) do
		local slot = Isaac.FindByType(EntityType.ENTITY_SLOT, ESCORT_BEGGAR.SLOT)[1]
		if slot then
			familiar.Position = slot.Position
			familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			familiar.Visible = true
			Mod:FloorSave(familiar).EscortRoom = Mod:RoomSave(slot).EscortRoom
			slot:Remove()
		end
		familiar:GetSprite():Play(ESCORT_BEGGAR.ANIM_RAISE_HANDS)
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ESCORT_BEGGAR.OnFamiliarCache, CacheFlag.CACHE_FAMILIARS)

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:OnFamiliarInit(familiar)
	familiar.PositionOffset = BEGGAR_POSITION_OFFSET
	familiar.SpriteOffset = Vector(0, -1.5)
	local initAnim = ESCORT_BEGGAR.ANIM_RAISE_HANDS
	local room_save = Mod:RoomSave()
	if room_save.AbandonedFamiliarEscorts then
		initAnim = "IdleSit"
	end
	familiar:GetSprite():Play(initAnim)
	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, ESCORT_BEGGAR.OnFamiliarInit, ESCORT_BEGGAR.FAMILIAR)

--#endregion

--#region Holding and throwing beggar

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:OnLand(familiar)
	local data = Mod:GetData(familiar)
	Mod.Spawn.DustClouds(familiar.Position, 1, familiar.Velocity:Resized(5), familiar)
	Mod.SFXMan:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
	familiar.Velocity = familiar.Velocity:Resized(2)
	data.EscortBeingThrown = nil
	data.EscortThrowLifetime = 0
	local gridEnt = Mod.Room():GetGridEntityFromPos(familiar.Position)
	if gridEnt and (gridEnt:ToRock() and gridEnt:IsBreakableRock() or gridEnt:ToPoop()) then
		gridEnt:Destroy()
	end
	for _, ent in ipairs(Isaac.FindInRadius(familiar.Position, familiar.Size, EntityPartition.ENEMY)) do
		if (ent.Type == EntityType.ENTITY_FIREPLACE and ent.Variant <= 1
				or ent.Type == EntityType.ENTITY_POOP)
			and not ent:IsDead()
		then
			ent:Die()
		end
	end
	familiar.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_GROUND
end

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:SlowDownAfterLand(familiar)
	if familiar.Velocity:Length() > 0.01 then
		local vel = familiar.Velocity
		vel:Lerp(Vector.Zero, 0.2)
		familiar.Velocity = vel
	elseif familiar.Velocity:Length() ~= 0 then
		familiar.Velocity = Vector.Zero
	end
end

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:ThrowUpdate(familiar)
	local sprite = familiar:GetSprite()
	local data = Mod:GetData(familiar)
	local offset = familiar.PositionOffset.Y

	if data.IFrames and data.IFrames > 0 and not sprite:IsPlaying("Death") then
		data.IFrames = data.IFrames - 1
	end
	if not ESCORT_BEGGAR:IsBeingThrown(familiar) then
		ESCORT_BEGGAR:SlowDownAfterLand(familiar)
	elseif offset < BEGGAR_POSITION_OFFSET.Y then
		--Yes this is a quadratic equation. Necessary? Probably not. Did I wanna do it anyways? Yeah
		data.EscortThrowLifetime = data.EscortThrowLifetime + 1
		familiar.PositionOffset.Y = math.min(BEGGAR_POSITION_OFFSET.Y, (1 / 3) * data.EscortThrowLifetime ^ 2 - 40)
		--The player can catch the beggar mid-air which resets the position offset for some reason?
	elseif not ESCORT_BEGGAR:IsHeldByPlayer(familiar) then
		ESCORT_BEGGAR:OnLand(familiar)
	end
end

---@param familiar EntityFamiliar
---@param collider Entity
function ESCORT_BEGGAR:OnFamiliarPlayerPickup(familiar, collider)
	local player = collider:ToPlayer()
	if not player then return end
	local sprite = familiar:GetSprite()
	if (sprite:IsPlaying(ESCORT_BEGGAR.ANIM_HANDS_LOOP)
			or sprite:IsPlaying("IdleSit"))
		and not player:IsHoldingItem()
		and player:CanPickupItem()
	then
		local oldVar = familiar.Variant
		familiar.Variant = FamiliarVariant.CUBE_BABY
		local holdSuccess = player:TryHoldEntity(familiar)
		familiar.Variant = oldVar
		if holdSuccess then
			familiar:GetSprite():Play("IdleSit")
			Mod.SFXMan:Play(SoundEffect.SOUND_FETUS_JUMP)
			Mod:GetData(familiar).EscortHeldByPlayer = true
			player:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_COLLISION, ESCORT_BEGGAR.OnFamiliarPlayerPickup, ESCORT_BEGGAR.FAMILIAR)

---@param player EntityPlayer
---@param heldEnt? Entity
---@param vel Vector
function ESCORT_BEGGAR:OnBeggarThrow(player, heldEnt, vel)
	if heldEnt
		and heldEnt:ToFamiliar()
		and heldEnt.Variant == ESCORT_BEGGAR.FAMILIAR
	then
		heldEnt:AddVelocity(vel)
		if vel:Length() > 2 then
			Mod.SFXMan:Play(SoundEffect.SOUND_SHELLGAME)
		end
		heldEnt.PositionOffset = ESCORT_BEGGAR.THROW_OFFSET
		local data = Mod:GetData(heldEnt)
		data.EscortThrowLifetime = 0
		data.EscortBeingThrown = true
		data.EscortHeldByPlayer = nil
		heldEnt.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_WALLS
		player:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_THROW, ESCORT_BEGGAR.OnBeggarThrow)

---@param familiar EntityFamiliar
---@param collider Entity
---@param low boolean
function ESCORT_BEGGAR:KnockBackEnemies(familiar, collider, low)
	if low and collider:IsActiveEnemy(false) and ESCORT_BEGGAR:IsBeingThrown(familiar) then
		local source = EntityRef(familiar)
		collider:TakeDamage(5, 0, source, 0)
		collider:AddKnockback(EntityRef(familiar), familiar.Velocity, 10, true)
		Mod.SFXMan:Play(SoundEffect.SOUND_MEATY_DEATHS)
		familiar.Velocity = familiar.Velocity:Rotated(180):Resized(5)
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_COLLISION, ESCORT_BEGGAR.KnockBackEnemies, ESCORT_BEGGAR.FAMILIAR)

---@param player EntityPlayer
function ESCORT_BEGGAR:CheckForSlow(player)
	local data = Mod:GetData(player)
	local hasBeggar = ESCORT_BEGGAR:IsHoldingBeggar(player)

	if data.EscortHeldByPlayer ~= hasBeggar then
		data.EscortHeldByPlayer = hasBeggar
		player:AddCacheFlags(CacheFlag.CACHE_SPEED, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, ESCORT_BEGGAR.CheckForSlow)

---@param player EntityPlayer
function ESCORT_BEGGAR:SlowWhileHolding(player)
	local heldEnt = player:GetHeldEntity()
	if heldEnt and heldEnt:ToFamiliar() and heldEnt.Variant == ESCORT_BEGGAR.FAMILIAR then
		player.MoveSpeed = player.MoveSpeed + ESCORT_BEGGAR.SLOW_DOWN
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, ESCORT_BEGGAR.SlowWhileHolding, CacheFlag.CACHE_SPEED)

--#endregion

--#region Leaving beggars in rooms

---@param newLevel boolean
function ESCORT_BEGGAR:AbandonBeggars(_, newLevel)
	if newLevel then return end
	local floor_save = Mod:FloorSave()
	local noBitches = (floor_save.EscortBeggars or 0) == 0
	local room_save = Mod:RoomSave()
	local room = Mod.Room()
	local abandonedBeggars = false

	Mod.Foreach.Familiar(function(familiar, index)
		if not ESCORT_BEGGAR:IsHeldByPlayer(familiar) or newLevel then
			if noBitches then return true end

			room_save.AbandonedFamiliarEscorts = room_save.AbandonedFamiliarEscorts or {}
			local position = familiar.Position
			local playerPos = Mod.Room():FindFreeTilePosition(familiar.Player.Position, 40)
			if not room:CheckLine(playerPos, position, LineCheckMode.ENTITY, 3000, true) then
				position = room:FindFreeTilePosition(familiar.Player.Position, 80)
			end
			Mod.Insert(room_save.AbandonedFamiliarEscorts,
				{ Position = { X = position.X, Y = position.Y }, EscortRoom = Mod:FloorSave(familiar).EscortRoom })
			floor_save.TotalAbandonedEscorts = (floor_save.TotalAbandonedEscorts or 0) + 1
			floor_save.EscortBeggars = floor_save.EscortBeggars - 1
			abandonedBeggars = true
		end
	end, ESCORT_BEGGAR.FAMILIAR)

	local numSlotBeggars = #Isaac.FindByType(EntityType.ENTITY_SLOT, ESCORT_BEGGAR.SLOT)
	if numSlotBeggars > 0 then
		floor_save.TotalAbandonedEscorts = (floor_save.TotalAbandonedEscorts or 0) + numSlotBeggars
		abandonedBeggars = true
	end

	if abandonedBeggars then
		room_save.AbandonedEscortCountdown = ESCORT_BEGGAR.ABANDONED_COUNTDOWN
	end

	if noBitches and not newLevel then return end

	local player = ESCORT_BEGGAR:GetFirstAlivePlayer()
	player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
	--To update MinimapAPI
	Mod.Game:Render()
end

Mod:AddCallback(ModCallbacks.MC_PRE_ROOM_EXIT, ESCORT_BEGGAR.AbandonBeggars)

function ESCORT_BEGGAR:AbandonedEscortCountdown()
	local floor_save = Mod.SaveManager.TryGetFloorSave()
	if floor_save and (floor_save.TotalAbandonedEscorts or 0) > 0 then
		local all_room_saves = Mod.SaveManager.GetEntireSave().game.room
		for listIndex, full_room_save in pairs(all_room_saves) do
			local room_save = full_room_save["GLOBAL"]
			if (room_save.AbandonedEscortCountdown or 0) > 0 then
				room_save.AbandonedEscortCountdown = room_save.AbandonedEscortCountdown - 1
				print(room_save.AbandonedEscortCountdown)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, ESCORT_BEGGAR.AbandonedEscortCountdown)

function ESCORT_BEGGAR:ResetOnNewFloor()
	local floor_save = Mod:FloorSave()
	if #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, ESCORT_BEGGAR.FAMILIAR) > 0 then
		floor_save.EscortBeggars = nil
		local player = ESCORT_BEGGAR:GetFirstAlivePlayer()
		player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
	end
end

Mod:AddCallback(Mod.SaveManager.SaveCallbacks.PRE_FLOOR_DATA_RESET, ESCORT_BEGGAR.ResetOnNewFloor)

function ESCORT_BEGGAR:SpawnBigHornHand(ent)
	local hand = Mod.Spawn.Effect(EffectVariant.BIG_HORN_HAND, 0, ent.Position, Vector.Zero, ent)
	local sprite = hand:GetSprite()
	sprite:Play("SmallHoleOpen")
	ent.EntityCollisionClass = EntityCollisionClass.ENTCOLL_NONE
	hand.Target = ent
end

---@param effect EntityEffect
function ESCORT_BEGGAR:BigHornHand(effect)
	if (effect.SpawnerType == EntityType.ENTITY_SLOT
			and effect.SpawnerVariant == ESCORT_BEGGAR.SLOT)
		or (effect.SpawnerType == EntityType.ENTITY_FAMILIAR
			and effect.SpawnerVariant == ESCORT_BEGGAR.FAMILIAR)
	then
		local sprite = effect:GetSprite()
		if sprite:IsFinished("SmallHoleOpen") then
			sprite:Play("HandGrab")
		elseif sprite:IsEventTriggered("Slam") and effect.SpawnerEntity then
			ESCORT_BEGGAR:DeathParticles(effect.SpawnerEntity.Position)
			effect.SpawnerEntity:Remove()
			Mod.SFXMan:Play(SoundEffect.SOUND_ISAACDIES, 1, 2, false, 1.5)
		elseif sprite:IsFinished("HandGrab") then
			sprite:Play("SmallHoleClose")
		elseif sprite:IsFinished("SmallHoleClose") then
			effect:Remove()
		end
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_EFFECT_UPDATE, ESCORT_BEGGAR.BigHornHand, EffectVariant.BIG_HORN_HAND)

function ESCORT_BEGGAR:RespawnBeggarOnEntry()
	local room_save = Mod:RoomSave()
	local floor_save = Mod:FloorSave()
	local shouldKill = (room_save.AbandonedEscortCountdown or 1) == 0

	if room_save.AbandonedFamiliarEscorts then
		local player = ESCORT_BEGGAR:GetFirstAlivePlayer()
		for _, abandoned_beggar in ipairs(room_save.AbandonedFamiliarEscorts) do
			local spawnPos = Vector(abandoned_beggar.Position.X, abandoned_beggar.Position.Y)
			local familiar = Isaac.Spawn(EntityType.ENTITY_FAMILIAR, ESCORT_BEGGAR.FAMILIAR, 0, spawnPos, Vector.Zero,
				player)
			Mod:FloorSave(familiar).EscortRoom = (abandoned_beggar.EscortRoom)
			familiar:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
			familiar.Visible = true
			ESCORT_BEGGAR:SpawnBigHornHand(familiar)
			if not shouldKill then
				familiar:GetSprite():Play("StartSleep")
			end
		end
		if not shouldKill then
			floor_save.EscortBeggars = (floor_save.EscortBeggars or 0) + #room_save.AbandonedFamiliarEscorts
		end
		floor_save.TotalAbandonedEscorts = floor_save.TotalAbandonedEscorts - #room_save.AbandonedFamiliarEscorts
		room_save.AbandonedFamiliarEscorts = nil
	end

	Mod.Foreach.Slot(function(slot, index)
		ESCORT_BEGGAR:SpawnBigHornHand(slot)
		floor_save.TotalAbandonedEscorts = floor_save.TotalAbandonedEscorts - 1
	end, ESCORT_BEGGAR.SLOT)

	if not shouldKill then
		room_save.AbandonedEscortCountdown = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ESCORT_BEGGAR.RespawnBeggarOnEntry)

function ESCORT_BEGGAR:ComfortOnRoomClear()
	Mod.Foreach.Familiar(function(familiar, index)
		if ESCORT_BEGGAR:IsGrounded(familiar) then
			familiar:GetSprite():Play("StartSleep")
		end
	end, ESCORT_BEGGAR.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_PRE_SPAWN_CLEAN_AWARD, ESCORT_BEGGAR.ComfortOnRoomClear)

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:HappyToSeeYou(familiar)
	local sprite = familiar:GetSprite()
	if sprite:GetAnimation() == "StartSleep" or sprite:GetAnimation() == "IdleSleep" then
		local nearbyPlayer = #Isaac.FindInRadius(familiar.Position, 40, EntityPartition.PLAYER) > 0
		if nearbyPlayer then
			sprite:Play("WakeUp")
		end
	end
end

--#endregion

--#region Damage/death handling

---@param ent Entity
function ESCORT_BEGGAR:LowerDamage(ent, amount, flags, source, countdown)
	if ent.Variant == ESCORT_BEGGAR.FAMILIAR and amount > 0 then
		---@cast ent EntityFamiliar
		local newAmount = Mod.Level():GetStage() >= LevelStage.STAGE4_2 and 2 or 1
		if ESCORT_BEGGAR:IsBeingThrown(ent) then
			newAmount = 0
		end
		return { Damage = newAmount }
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, ESCORT_BEGGAR.LowerDamage, EntityType.ENTITY_FAMILIAR)

---@param ent Entity
function ESCORT_BEGGAR:OnTakeDamage(ent, amount, flags, source, countdown)
	if ent.Variant == ESCORT_BEGGAR.FAMILIAR and not ent:HasMortalDamage() and amount > 0 then
		ent:GetSprite():Play("Damage")
		Mod:GetData(ent).IFrames = 30
		Mod.SFXMan:Play(SoundEffect.SOUND_ISAAC_HURT_GRUNT, 1, 2, false, 1.5)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_TAKE_DMG, ESCORT_BEGGAR.OnTakeDamage, EntityType.ENTITY_FAMILIAR)

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:DamageFlash(familiar)
	local data = Mod:GetData(familiar)
	if data.IFrames and data.IFrames > 0 and data.IFrames % 2 == 0 and data.IFrames < 30 then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_FAMILIAR_RENDER, ESCORT_BEGGAR.DamageFlash, ESCORT_BEGGAR.FAMILIAR)

---@param ent Entity
function ESCORT_BEGGAR:OnFamiliarDeath(ent)
	if ent.Variant == ESCORT_BEGGAR.FAMILIAR then
		local deathAnim = Mod.Spawn.Poof01(0, ent.Position, ent, ent.InitSeed)
		local sprite = deathAnim:GetSprite()
		sprite.Offset = ent.SpriteOffset
		sprite:Load(ent:GetSprite():GetFilename(), true)
		sprite:Play("Death")
		Mod.SFXMan:Play(SoundEffect.SOUND_ISAACDIES, 1, 2, false, 1.5)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_KILL, ESCORT_BEGGAR.OnFamiliarDeath, EntityType.ENTITY_FAMILIAR)

function ESCORT_BEGGAR:DeathParticles(pos)
	Mod.Spawn.DustClouds(pos)
	for _ = 1, 4 do
		local rock = Mod.Spawn.Effect(EffectVariant.ROCK_PARTICLE, 0, pos,
			RandomVector():Resized(Mod:RandomNum(1, 5) + Mod:RandomNum()))
		local sprite = rock:GetSprite()
		Mod:DelayOneFrame(function()
			sprite:ReplaceSpritesheet(0, "gfx/grid/escort_beggar_rubble.png", true)
		end)
	end
	Mod.SFXMan:Play(SoundEffect.SOUND_ROCK_CRUMBLE)
end

---@param effect EntityEffect
function ESCORT_BEGGAR:OnDeathAnim(effect)
	if effect.SpawnerType == EntityType.ENTITY_FAMILIAR
		and effect.SpawnerVariant == ESCORT_BEGGAR.FAMILIAR
	then
		local sprite = effect:GetSprite()
		if sprite:IsFinished("Death") then
			ESCORT_BEGGAR:DeathParticles(effect.Position)
		elseif not sprite:WasEventTriggered("StopCrumble") then
			local data = Mod:GetData(effect)
			if not data.RandomCrumbleTimes or data.RandomCrumbleTimes == effect.FrameCount then
				data.RandomCrumbleTimes = effect.FrameCount + Mod:RandomNum(3, 5)
				local rock = Mod.Spawn.Effect(EffectVariant.TOOTH_PARTICLE, 1, effect.Position, RandomVector():Resized(2))
				rock.Color = Color(0.5, 0.5, 0.5)
				Mod.SFXMan:Play(SoundEffect.SOUND_ROCK_CRUMBLE, 1, 2, false, 1.2)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, ESCORT_BEGGAR.OnDeathAnim, EffectVariant.POOF01)

--#endregion

--#region Deliver beggar to room

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:RenderRoom(familiar, offset)
	local familiar_floor_save = Mod:FloorSave(familiar)
	local sprite = familiar:GetSprite()
	if familiar_floor_save.EscortRoom and sprite:GetAnimation() == "StartSleep" or sprite:GetAnimation() == "IdleSleep" then
		local nullFrame = sprite:GetNullFrame("Sign")
		if nullFrame and nullFrame:IsVisible() then
			local data = Mod:GetData(familiar)
			local renderPos = Mod:GetEntityRenderPosition(familiar, offset)
			if not data.DreamRoomIcon then
				local roomSprite = Sprite(Mod:GetMinimapPath(), true)
				local anim = ESCORT_BEGGAR.ROOM_TYPES_MAP[familiar_floor_save.EscortRoom]
				if anim then
					roomSprite:SetFrame(anim, 0)
				end
				data.DreamRoomIcon = roomSprite
			end
			renderPos = renderPos + nullFrame:GetPos()

			data.DreamRoomIcon.Color = nullFrame:GetColor()
			data.DreamRoomIcon:Render(renderPos)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FAMILIAR_RENDER, ESCORT_BEGGAR.RenderRoom, ESCORT_BEGGAR.FAMILIAR)

function ESCORT_BEGGAR:EnterDestinationRoom()
	local floor_save = Mod:FloorSave()
	if floor_save.EscortBeggars == 0 then return end
	local room = Mod.Room()
	local player = ESCORT_BEGGAR:GetFirstAlivePlayer()

	Mod.Foreach.Familiar(function(familiar, index)
		local familiar_floor_save = Mod:FloorSave(familiar)
		if room:GetType() == (familiar_floor_save.EscortRoom or 0) then
			floor_save.EscortBeggars = floor_save.EscortBeggars - 1
			local slot = Mod.Spawn.Slot(ESCORT_BEGGAR.SLOT, room:FindFreePickupSpawnPosition(familiar.Position, 40, true),
				familiar, familiar.InitSeed)
			slot:SetState(Mod.SlotState.PAYOUT)
			slot:GetSprite():Play("Prize")
			familiar:Remove()
		end
	end, ESCORT_BEGGAR.FAMILIAR)

	player:AddCacheFlags(CacheFlag.CACHE_FAMILIARS, true)
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, ESCORT_BEGGAR.EnterDestinationRoom)

--#endregion

--#region Basic familiar callbacks

---@param familiar EntityFamiliar
function ESCORT_BEGGAR:Animations(familiar)
	local sprite = familiar:GetSprite()
	if sprite:IsFinished("WakeUp") then
		sprite:Play(ESCORT_BEGGAR.ANIM_RAISE_HANDS)
	elseif sprite:IsFinished(ESCORT_BEGGAR.ANIM_RAISE_HANDS) then
		sprite:Play(ESCORT_BEGGAR.ANIM_HANDS_LOOP)
	elseif sprite:IsFinished("Damage") then
		sprite:Play("IdleSit")
	elseif sprite:IsFinished("StartSleep") then
		sprite:Play("IdleSleep")
	elseif sprite:IsEventTriggered("Happy") then
		Mod.SFXMan:Play(SoundEffect.SOUND_THUMBSUP)
	end
end

function ESCORT_BEGGAR:OnFamiliarUpdate(familiar)
	ESCORT_BEGGAR:Animations(familiar)
	ESCORT_BEGGAR:ThrowUpdate(familiar)
	ESCORT_BEGGAR:HappyToSeeYou(familiar)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, ESCORT_BEGGAR.OnFamiliarUpdate, ESCORT_BEGGAR.FAMILIAR)

--#endregion
