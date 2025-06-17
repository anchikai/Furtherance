local Mod = Furtherance

local PILLAR_OF_CLOUDS = {}

Furtherance.Item.PILLAR_OF_CLOUDS = PILLAR_OF_CLOUDS

PILLAR_OF_CLOUDS.ID = Isaac.GetItemIdByName("Pillar of Clouds")

PILLAR_OF_CLOUDS.FLIGHT_OFFSET = Vector(0, -80)

local attackerInputs = Mod:Set({
	ButtonAction.ACTION_SHOOTDOWN,
	ButtonAction.ACTION_SHOOTLEFT,
	ButtonAction.ACTION_SHOOTRIGHT,
	ButtonAction.ACTION_SHOOTUP,
})

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:IsCloudActive(player)
	return player:GetEffects():HasCollectibleEffect(PILLAR_OF_CLOUDS.ID)
end

function PILLAR_OF_CLOUDS:SpawnCloudTrail(player)
	local trail = Mod.Spawn.Trail(player, 0.1)
	trail.Position = player.Position + PILLAR_OF_CLOUDS.FLIGHT_OFFSET + Vector(0, -10 * player.SpriteScale.Y)
	Mod:GetData(player).CloudTrail = EntityPtr(trail)
end

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:OnUse(_, _, player)
	player.PositionOffset = PILLAR_OF_CLOUDS.FLIGHT_OFFSET
	player:SetCanShoot(false)
	if not Mod:GetData(player).CloudTrail then
		PILLAR_OF_CLOUDS:SpawnCloudTrail(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_USE_ITEM, PILLAR_OF_CLOUDS.OnUse, PILLAR_OF_CLOUDS.ID)

---@param effect EntityEffect
function PILLAR_OF_CLOUDS:TrailUpdate(effect)
	local player = effect.SpawnerEntity and effect.SpawnerEntity:ToPlayer()
	if player and PILLAR_OF_CLOUDS:IsCloudActive(player) then
		effect.Position = player.Position + PILLAR_OF_CLOUDS.FLIGHT_OFFSET + Vector(0, -10 * player.SpriteScale.Y)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, PILLAR_OF_CLOUDS.TrailUpdate, EffectVariant.SPRITE_TRAIL)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:Transparent(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		local c = player:GetSprite().Color
		local cz = c:GetColorize()
		player:SetColor(Color(c.R, c.G, c.B, 0.5, c.RO, c.BO, c.GO, cz.R, cz.G, cz.B, cz.A), 2, 100, false, true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PILLAR_OF_CLOUDS.Transparent)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:RaisePlayer(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		player.PositionOffset = PILLAR_OF_CLOUDS.FLIGHT_OFFSET
		local effects = player:GetEffects()
		local cooldown = effects:GetCollectibleEffect(PILLAR_OF_CLOUDS.ID).Cooldown
		if cooldown <= 30 then
			local sprite = Mod:GetCostumeSpriteFromLayer(player, PlayerSpriteLayer.SPRITE_TOP0)
			if not sprite then return end
			local layer = sprite:GetLayer("top0")
			if not layer then return end
			layer:SetVisible(cooldown % 2 == 0)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_RENDER, PILLAR_OF_CLOUDS.RaisePlayer)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:GrantFlight(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		player.CanFly = true
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, PILLAR_OF_CLOUDS.GrantFlight, CacheFlag.CACHE_FLYING)

function PILLAR_OF_CLOUDS:NoAttacking(ent, hook, button)
	local player = ent and ent:ToPlayer()
	if player and PILLAR_OF_CLOUDS:IsCloudActive(player) and attackerInputs[button] then
		return 0
	end
end

Mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, PILLAR_OF_CLOUDS.NoAttacking, InputHook.GET_ACTION_VALUE)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:NoPlayerEntCollision(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_COLLISION, CallbackPriority.EARLY,
	PILLAR_OF_CLOUDS.NoPlayerEntCollision)

---@param collider Entity
function PILLAR_OF_CLOUDS:NoPlayerEntCollision2(ent, collider)
	local player = collider:ToPlayer()
	if player and PILLAR_OF_CLOUDS:IsCloudActive(player) then
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_NPC_COLLISION, CallbackPriority.EARLY, PILLAR_OF_CLOUDS
.NoPlayerEntCollision2)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, CallbackPriority.EARLY,
	PILLAR_OF_CLOUDS.NoPlayerEntCollision2)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_SLOT_COLLISION, CallbackPriority.EARLY,
	PILLAR_OF_CLOUDS.NoPlayerEntCollision2)
Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PICKUP_COLLISION, CallbackPriority.EARLY,
	PILLAR_OF_CLOUDS.NoPlayerEntCollision2)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:NoDamage(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		return false
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PLAYER_TAKE_DMG, PILLAR_OF_CLOUDS.NoDamage)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:NoPlayerGridCollision(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		player.GridCollisionClass = EntityGridCollisionClass.GRIDCOLL_NONE
		return true
	end
end

Mod:AddPriorityCallback(ModCallbacks.MC_PRE_PLAYER_GRID_COLLISION, CallbackPriority.EARLY,
	PILLAR_OF_CLOUDS.NoPlayerGridCollision, PlayerVariant.PLAYER)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:OnEffectRemove(player)
	player.PositionOffset = Vector.Zero
	player:SetCanShoot(true)
	local data = Mod:GetData(player)
	if data.CloudTrail and data.CloudTrail.Ref then
		data.CloudTrail.Ref:Remove()
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_TRIGGER_EFFECT_REMOVED, PILLAR_OF_CLOUDS.OnEffectRemove)

--#region Room changing

local RotationToDir = {}
RotationToDir[0] = Direction.UP
RotationToDir[90] = Direction.RIGHT
RotationToDir[180] = Direction.DOWN
RotationToDir[-90] = Direction.LEFT

local doorX = Mod:Set({
	DoorSlot.DOWN0,
	DoorSlot.DOWN1,
	DoorSlot.UP0,
	DoorSlot.UP1
})

local doorY = Mod:Set({
	DoorSlot.LEFT0,
	DoorSlot.LEFT1,
	DoorSlot.RIGHT0,
	DoorSlot.RIGHT1
})

local playerPos

--Credit to Car mod for getting the closest door
function PILLAR_OF_CLOUDS.FakeGentDoorFromStageApi(slot, force)
	if StageAPI and StageAPI.Loaded then
		local realfakedoors = Isaac.FindByType(1000, Isaac.GetEntityVariantByName("StageAPIDoor"), -1)
		for i, e in pairs(realfakedoors) do
			if (e:GetData().DoorGridData.Slot == slot) or force then
				local gent = {}
				gent.GetGridIndex = function() return Mod.Room():GetGridIndex(e.Position) end
				gent.GetSprite = function() return e:GetSprite() end
				gent.ToDoor = function(e) return e end
				gent.ToPit = function() return false end
				gent.ToSpikes = function() return false end
				gent.ToTNT = function() return false end
				gent.ToPoop = function() return false end
				gent.ToPreassurePlate = function() return false end
				gent.State = 1
				gent.Position = e.Position
				gent.Desc = {}
				gent.Desc.Type = GridEntityType.GRID_DOOR
				gent.Destroy = function() e:GetData().Opened = true end
				gent.Close = function() e:GetData().Opened = true end
				gent.Open = function(g) e:GetData().Opened = true end
				gent.IsRoomType = function(g) return false end
				gent.IsOpen = function(g) return e:GetData().Opened end
				gent.IsClosed = function(g) return not e:GetData().Opened end
				gent.IsLocked = function(g) return false end
				gent.SetLocked = function(g) e:GetData().Opened = true end
				gent.TryUnlock = function(g) e:GetData().Opened = true end
				gent.TryBlowOpen = function(g) e:GetData().Opened = true end
				gent.SpawnDust = function(g) return false end
				gent.Direction = RotationToDir[e:GetSprite().Rotation]
				gent.TargetRoomIndex = e:GetData().DoorGridData.LeadsTo
				gent.Slot = e:GetData().DoorGridData.Slot
				gent.IsStageAPI = true
				return gent
			end
		end
	end
end

---@param pos Vector
function PILLAR_OF_CLOUDS.GetNearDoor(pos)
	--Find the wall we're on
	local room = Mod.Room()
	local roomDir
	local topLeft = room:GetTopLeftPos()
	local bottomRight = room:GetBottomRightPos()
	local minDistWall = 99999
	local distances = {
		math.abs(topLeft.X - pos.X - 40),
		math.abs(topLeft.Y - pos.Y - 40),
		math.abs(bottomRight.X - pos.X + 40),
		math.abs(bottomRight.Y - pos.Y + 40)
	}
	local doorSlotInverse = Mod:Invert(DoorSlot)
	for i, dist in ipairs(distances) do
		if dist < minDistWall then
			minDistWall = dist
			roomDir = i - 1
		end
	end
	local roomDirString = string.sub(doorSlotInverse[roomDir], 1, -2)

	local slots = {
		DoorSlot[roomDirString .. "0"],
		DoorSlot[roomDirString .. "1"]
	}

	local nearDoor
	local minDistDoor = 99999
	for _, slot in ipairs(slots) do
		local door = Mod.Room():GetDoor(slot)
		if (not door) and StageAPI and StageAPI.Loaded then door = PILLAR_OF_CLOUDS.FakeGentDoorFromStageApi(slot) end
			if door then
			local newdist = door.Position:Distance(pos)
			if newdist < minDistDoor then
				minDistDoor = newdist
				nearDoor = door
			end
		end
		if (nearDoor and ((math.abs(nearDoor.Position.X - pos.X) > 180) or (math.abs(nearDoor.Position.Y - pos.Y) > 180)))then
			return
		end
	end
	return nearDoor
end

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:ChangeRooms(player)
	local room = Mod.Room()

	if PILLAR_OF_CLOUDS:IsCloudActive(player)
		and not room:IsPositionInRoom(player.Position, -40)
		and room:GetFrameCount() > 5
	then
		local door = PILLAR_OF_CLOUDS.GetNearDoor(player.Position)

		if door then
			Mod.Level().LeaveDoor = -1
			Mod.Game:StartRoomTransition(door.TargetRoomIndex, Direction.NO_DIRECTION)
			playerPos = {player, player.Position}
		else
			--Credit to FF for this clean code to push back the player
			local clampedPos = Mod.Room():GetClampedPosition(player.Position, -40)
			local distance = player.Position:Distance(clampedPos)
			player.Velocity = player.Velocity + (clampedPos - player.Position):Resized(math.min(10, distance))
			player.Position = clampedPos + (player.Position - clampedPos)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, PILLAR_OF_CLOUDS.ChangeRooms)

---@param player EntityPlayer
function PILLAR_OF_CLOUDS:RespawnCloudTrail(player)
	if PILLAR_OF_CLOUDS:IsCloudActive(player) then
		PILLAR_OF_CLOUDS:SpawnCloudTrail(player)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_PLAYER_NEW_ROOM_TEMP_EFFECTS, PILLAR_OF_CLOUDS.RespawnCloudTrail)

function PILLAR_OF_CLOUDS:AdjustPositionOnNewRoom()
	if playerPos then
		local player = playerPos[1]
		local pos = playerPos[2]
		local doorSlot = Mod.Level().EnterDoor
		local door = Mod.Room():GetDoor(doorSlot)
		if doorX[doorSlot] then
			player.Position = Vector(pos.X, door.Position.Y)
		elseif doorY[doorSlot] then
			player.Position = Vector(door.Position.X, pos.Y)
		end
		playerPos = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, PILLAR_OF_CLOUDS.AdjustPositionOnNewRoom)

--#endregion
