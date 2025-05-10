---@diagnostic disable: param-type-mismatch, inject-field
local game = Game()

local Foreach = {}

---@param ent Entity
local function doCast(ent)
	if ent.Type == EntityType.ENTITY_PLAYER then
		return ent:ToPlayer()
	elseif ent.Type == EntityType.ENTITY_TEAR then
		return ent:ToTear()
	elseif ent.Type == EntityType.ENTITY_FAMILIAR then
		return ent:ToFamiliar()
	elseif ent.Type == EntityType.ENTITY_BOMB then
		return ent:ToBomb()
	elseif ent.Type == EntityType.ENTITY_PICKUP then
		return ent:ToPickup()
	elseif ent.Type == EntityType.ENTITY_SLOT then
		return ent:ToSlot()
	elseif ent.Type == EntityType.ENTITY_LASER then
		return ent:ToLaser()
	elseif ent.Type == EntityType.ENTITY_KNIFE then
		return ent:ToKnife()
	elseif ent.Type == EntityType.ENTITY_PROJECTILE then
		return ent:ToProjectile()
	elseif ent.Type == EntityType.ENTITY_EFFECT then
		return ent:ToEffect()
	else
		return ent:ToNPC()
	end
end

---@class SearchParams
---@field Inverse boolean?
---@field ShouldCache boolean?

---@class DebugSearchParams
---@field NPCOnly boolean?
---@field EntityOnly boolean?

---@class AllowEnemySearchParams: SearchParams
---@field UseEnemySearchParams boolean?
---@field Dead boolean?
---@field Friendly boolean?
---@field NoCollision boolean?
---@field CantShutDoors boolean?
---@field Invincible boolean?

---@param ent Entity?
---@param searchParams AllowEnemySearchParams
local function isValidEnemyTarget(ent, searchParams)
	return ent
	and ent:ToNPC()
	and ent:IsActiveEnemy(searchParams and searchParams.Dead or false)
	and (ent:IsVulnerableEnemy() or searchParams and searchParams.Invincible)
	and (not ent:HasEntityFlags(EntityFlag.FLAG_FRIENDLY) or searchParams and searchParams.Friendly)
	and (ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE or searchParams and searchParams.NoCollision)
	and (ent:ToNPC().CanShutDoors or ent.Type == EntityType.ENTITY_DUMMY or searchParams and searchParams.CantShutDoors)
end

local function varSubtypeCheck(ent, variant, subtype)
	local entSubtype = ent:ToPlayer() and ent:ToPlayer():GetPlayerType() or ent.SubType
	return (not variant or ent.Variant == variant) and (not subtype or entSubtype == subtype)
end

local function forEach(ent, i, func, searchParams, variant, subtype)
	if varSubtypeCheck(ent, variant, subtype) then
		local castEnt = searchParams and searchParams.EntityOnly and ent or doCast(ent)
		if searchParams and searchParams.NPCOnly and not ent:ToNPC() then
			castEnt = nil
		end
		if castEnt and (not searchParams or not searchParams.UseEnemySearchParams or isValidEnemyTarget(castEnt, searchParams)) then
			local index = REPENTOGON and castEnt:ToPlayer() and castEnt:GetPlayerIndex() or i
			local result = func(castEnt, index)
			if result ~= nil then
				return result
			end
		end
	end
end

local function inverseiforeach(loopTable, func, searchParams, variant, subtype)
	for i = #loopTable, 1, -1 do
		local ent = loopTable[i]
		local result = forEach(ent, i, func, searchParams, variant, subtype)
		if result ~= nil then
			return result
		end
	end
end

local function iforeach(loopTable, func, searchParams, variant, subtype)
	for i, ent in ipairs(loopTable) do
		local result = forEach(ent, i, func, searchParams, variant, subtype)
		if result ~= nil then
			return result
		end
	end
end

---@param func fun(ent: Entity, index: integer): any
---@param entType? EntityType
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams | AllowEnemySearchParams | DebugSearchParams
local function startForEachType(func, entType, variant, subtype, searchParams)
	local loopTable
	if REPENTOGON and entType == EntityType.ENTITY_PLAYER then
		loopTable = PlayerManager.GetPlayers()
	elseif entType then
		loopTable = Isaac.FindByType(entType, variant, subtype, searchParams and searchParams.ShouldCache or false, searchParams and searchParams.Friendly or false)
	else
		loopTable = Isaac.GetRoomEntities()
	end

	if searchParams and searchParams.Inverse then
		return inverseiforeach(loopTable, func, searchParams)
	else
		return iforeach(loopTable, func, searchParams)
	end
end

---@param func fun(ent: Entity, index: integer): any
---@param partition? EntityPartition | EntityType
---@param pos Vector | Entity
---@param radius number
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams | AllowEnemySearchParams | DebugSearchParams
---@param noPartition? boolean @default: `false`
local function startForEachPartition(func, partition, pos, radius, variant, subtype, searchParams, noPartition)
	local loopTable
	local isVector = getmetatable(pos).__type == "Vector"
	if not isVector then
		pos = pos.Position
	end
	if not partition then
		loopTable = Isaac.GetRoomEntities()
	elseif not noPartition then
		--Automatically accounts for collision spheres
		---@cast partition EntityPartition
		---@cast pos Vector
		loopTable = Isaac.FindInRadius(pos, radius, partition)
	else
		---@cast partition EntityType
		loopTable = {}
		local posCompare
		if isVector then
			posCompare = 0
		else
			posCompare = pos.Size
		end
		local byType = Isaac.FindByType(partition, variant, subtype, true, searchParams and searchParams.Friendly or false)
		for _, ent in ipairs(byType) do
			if ent.Position:DistanceSquared(pos) <= (ent.Size + posCompare) ^ 2 then
				loopTable[#loopTable + 1] = ent
			end
		end
	end

	if searchParams and searchParams.Inverse then
		return inverseiforeach(loopTable, func, searchParams, variant, subtype)
	else
		return iforeach(loopTable, func, searchParams, variant, subtype)
	end
end

---@generic V
---@param func fun(player: EntityPlayer, index: integer): V? --With REPENTOGON enabled, `index` is specifically obtained from `EntityPlayer:GetPlayerIndex()` rather than the table's index
---@param variant? PlayerVariant @default: `-1`
---@param playerType? PlayerType @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Player(func, variant, playerType, searchParams)
	return startForEachType(func, EntityType.ENTITY_PLAYER, variant, playerType, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(player: EntityPlayer, index: integer): V? --With REPENTOGON enabled, `index` is specifically obtained from `EntityPlayer:GetPlayerIndex()` rather than the table's index
---@param variant? PlayerVariant @default: `-1`
---@param playerType? PlayerType @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.PlayerInRadius(pos, radius, func, variant, playerType, searchParams)
	return startForEachPartition(func, EntityPartition.PLAYER, pos, radius, variant, playerType, searchParams)
end

---@generic V
---@param func fun(tear: EntityTear, index: integer): V?
---@param variant? TearVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Tear(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_TEAR, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(tear: EntityTear, index: integer): V?
---@param variant? TearVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.TearInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityPartition.TEAR, pos, radius, variant, subtype, searchParams)
end

---@generic V
---@param func fun(familiar: EntityFamiliar, index: integer): V?
---@param variant? FamiliarVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Familiar(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_FAMILIAR, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(familiar: EntityFamiliar, index: integer): V?
---@param variant? FamiliarVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.FamiliarInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityPartition.FAMILIAR, pos, radius, variant, subtype, searchParams)
end

---@generic V
---@param func fun(bomb: EntityBomb, index: integer): V?
---@param variant? BombVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Bomb(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_BOMB, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector | Entity @As Bombs lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(bomb: EntityBomb, index: integer): V?
---@param variant? BombVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.BombInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityType.ENTITY_BOMB, pos, radius, variant, subtype, searchParams, true)
end

---@generic V
---@param func fun(pickup: EntityPickup, index: integer): V?
---@param variant? PickupVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Pickup(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_PICKUP, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(pickup: EntityPickup, index: integer): V?
---@param variant? PickupVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.PickupInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityPartition.PICKUP, pos, radius, variant, subtype, searchParams)
end

---@generic V
---@param func fun(slot: EntitySlot, index: integer): V?
---@param variant? SlotVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Slot(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_SLOT, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector | Entity @As Slots lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(slot: EntitySlot, index: integer): V?
---@param variant? SlotVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.SlotInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityType.ENTITY_SLOT, pos, radius, variant, subtype, searchParams, true)
end

---@generic V
---@param func fun(laser: EntityLaser, index: integer): V?
---@param variant? LaserVariant @default: `-1`
---@param subtype? LaserSubType @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Laser(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_LASER, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector | Entity @As Lasers lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(laser: EntityLaser, index: integer): V?
---@param variant? LaserVariant @default: `-1`
---@param subtype? LaserSubType @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.LaserInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityType.ENTITY_LASER, pos, radius, variant, subtype, searchParams, true)
end

---@generic V
---@param func fun(knife: EntityKnife, index: integer): V?
---@param variant? KnifeVariant @default: `-1`
---@param subtype? KnifeSubType @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Knife(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_KNIFE, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector | Entity @As Knifes lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(knife: EntityKnife, index: integer): V?
---@param variant? KnifeVariant @default: `-1`
---@param subtype? KnifeSubType @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.KnifeInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityType.ENTITY_KNIFE, pos, radius, variant, subtype, searchParams, true)
end

---@generic V
---@param func fun(projectile: EntityProjectile, index: integer): V?
---@param variant? ProjectileVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Projectile(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_PROJECTILE, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(projectile: EntityProjectile, index: integer): V?
---@param variant? ProjectileVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.ProjectileInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityPartition.BULLET, pos, radius, variant, subtype, searchParams)
end

---@generic V
---@param func fun(npc: EntityNPC, index: integer): V?
---@param entType? EntityType @default: `-1`
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? AllowEnemySearchParams @Extended list of search parameters catered towards enemies. If given a table, will go through the default list of requirements for a valid enemy target. Use the table's parameters to adjust the specifics of the search
---@return V?
function Foreach.NPC(func, entType, variant, subtype, searchParams)
	searchParams = searchParams or {}
	searchParams.NPCOnly = true
	return startForEachType(func, entType, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(npc: EntityNPC, index: integer): V?
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? AllowEnemySearchParams @Extended list of search parameters catered towards enemies. If given a table, will go through the default list of requirements for a valid enemy target. Use the table's parameters to adjust the specifics of the search
---@return V?
function Foreach.NPCInRadius(pos, radius, func, variant, subtype, searchParams)
	return startForEachPartition(func, EntityPartition.ENEMY, pos, radius, variant, subtype, searchParams)
end

---@generic V
---@param func fun(effect: EntityEffect, index: integer): V?
---@param variant? EffectVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@return V?
function Foreach.Effect(func, variant, subtype, searchParams)
	return startForEachType(func, EntityType.ENTITY_EFFECT, variant, subtype, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(effect: EntityEffect, index: integer): V?
---@param variant? EffectVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param searchParams? SearchParams
---@param collisionOnly? boolean @By  default, effects don't inherently don't have collision, but REPENTOGON fixes Isaac.FindInRadius's EntityPartition.EFFECT by allowing it to show if it has a set collision type. Set to true to use this, otherwise it'll use the manual FindByType + DistanceSquared method
---@return V?
function Foreach.EffectInRadius(pos, radius, func, variant, subtype, searchParams, collisionOnly)
	return startForEachPartition(func, REPENTOGON and collisionOnly and EntityPartition.EFFECT or EntityType.ENTITY_EFFECT, pos, radius, variant, subtype, searchParams, not REPENTOGON or not collisionOnly)
end

---@generic V
---@param func fun(gridEnt: GridEntity, gridIndex: integer): V?
---@param gridType? GridEntityType
---@param gridVariant? integer
---@return V?
function Foreach.Grid(func, gridType, gridVariant)
	local room = game:GetRoom()
	for i = 0, room:GetGridSize() - 1 do
		local grid = room:GetGridEntity(i)
		if grid
			and (not gridType or grid:GetType() == gridType)
			and (not gridVariant or grid:GetVariant() == gridVariant)
		then
			local result = func(grid, i)
			if result ~= nil then
				return result
			end
		end
	end
end

---@generic V
---@param func fun(door: GridEntityDoor, doorSlot: DoorSlot): V?
---@return V?
function Foreach.Door(func)
	local room = game:GetRoom()
	for i = DoorSlot.NO_DOOR_SLOT + 1, DoorSlot.NUM_DOOR_SLOTS - 1 do
		local door = room:GetDoor(i)
		if door then
			local result = func(door, i)
			if result ~= nil then
				return result
			end
		end
	end
end

---@generic V
---@param func fun(entity: Entity, index: integer): V?
---@param searchParams? SearchParams
---@return V?
function Foreach.Entity(func, searchParams)
	searchParams = searchParams or {}
	searchParams.EntityOnly = true
	return startForEachType(func, nil, nil, nil, searchParams)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(entity: Entity, index: integer): V?
---@param searchParams? SearchParams
---@return V?
function Foreach.EntityInRadius(pos, radius, func, searchParams)
	searchParams = searchParams or {}
	searchParams.EntityOnly = true
	return startForEachPartition(func, nil, pos, radius, nil, nil, searchParams)
end

--Will move DOWN the chain from the provided entity. Provide the parent if you want to loop through the whole line of enemies
---@param npc Entity
---@param func fun(npc: Entity)
function Foreach.Segment(npc, func)
	local entitiesSearch = {}
	local curHash = GetPtrHash(npc)
	entitiesSearch[curHash] = true
	local currentEnt = npc.Child
	if currentEnt.Parent
		and currentEnt.Parent:ToNPC()
		and currentEnt.Parent.Child
		and GetPtrHash(currentEnt) == GetPtrHash(currentEnt.Parent.Child)
		and not entitiesSearch[curHash]
	then
		entitiesSearch[curHash] = true
		func(npc)
		currentEnt = currentEnt.Child
		curHash = GetPtrHash(currentEnt)
	end
end

return Foreach