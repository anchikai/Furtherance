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

local function varSubtypeCheck(ent, variant, subtype)
	local entSubtype = ent:ToPlayer() and ent:GetPlayerType() or ent.SubType
	return ent.Variant == (variant or ent.Variant) and entSubtype == (subtype or entSubtype)
end

local function forEach(ent, i, func, variant, subtype)
	if varSubtypeCheck(ent, variant, subtype) then
		local castEnt = doCast(ent)
		if castEnt then
			local index = REPENTOGON and castEnt:ToPlayer() and castEnt:GetPlayerIndex() or i
			local result = func(ent, index)
			if result ~= nil then
				return result
			end
		end
	end
end

local function inverseiforeach(loopTable, func, variant, subtype)
	for i = #loopTable, 1, -1 do
		local ent = loopTable[i]
		local result = forEach(ent, i, func, variant, subtype)
		if result ~= nil then
			return result
		end
	end
end

local function iforeach(loopTable, func, variant, subtype)
	for i, ent in ipairs(loopTable) do
		local result = forEach(ent, i, func, variant, subtype)
		if result ~= nil then
			return result
		end
	end
end

---@param func fun(ent: Entity, index: integer): any
---@param entType EntityType
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@param ignoreFriendly? boolean @default: `false`
local function startForEachType(func, entType, variant, subtype, inverse, shouldCache, ignoreFriendly)
	local loopTable
	if REPENTOGON and entType == EntityType.ENTITY_PLAYER then
		loopTable = PlayerManager.GetPlayers()
	else
		loopTable = Isaac.FindByType(entType, variant, subtype, shouldCache, ignoreFriendly)
	end

	if inverse then
		return inverseiforeach(loopTable, func)
	else
		return iforeach(loopTable, func)
	end
end

---@param func fun(ent: Entity, index: integer): any
---@param partition EntityPartition | EntityType
---@param pos Vector | Entity
---@param radius number
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param noPartition? boolean @default: `false`
local function startForEachPartition(func, partition, pos, radius, variant, subtype, inverse, noPartition)
	local loopTable
	local isVector = getmetatable(pos).__type == "Vector"
	if not noPartition then
		--Automatically accounts for collision spheres
		---@cast partition EntityPartition
		if not isVector then
			pos = pos.Position
		end
		---@cast pos Vector
		loopTable = Isaac.FindInRadius(pos, radius, partition)
	else
		---@cast partition EntityType
		loopTable = {}
		local posCompare
		if isVector then
			posCompare = Vector.Zero
		else
			posCompare = pos.Size
		end
		local byType = Isaac.FindByType(partition, variant, subtype, true)
		for _, ent in ipairs(byType) do
			if ent.Position:DistanceSquared(pos.Position) <= (ent.Size + posCompare) ^ 2 then
				table[#loopTable + 1] = ent
			end
		end
	end

	if inverse then
		return inverseiforeach(loopTable, func, variant, subtype)
	else
		return iforeach(loopTable, func, variant, subtype)
	end
end

---@generic V
---@param func fun(player: EntityPlayer, index: integer): V? --With REPENTOGON enabled, `index` is specifically obtained from `EntityPlayer:GetPlayerIndex()` rather than the table's index
---@param variant? PlayerVariant @default: `-1`
---@param playerType? PlayerType @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Player(func, variant, playerType, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_PLAYER, variant, playerType, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(player: EntityPlayer, index: integer): V? --With REPENTOGON enabled, `index` is specifically obtained from `EntityPlayer:GetPlayerIndex()` rather than the table's index
---@param variant? PlayerVariant @default: `-1`
---@param playerType? PlayerType @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.PlayerInRadius(pos, radius, func, variant, playerType, inverse)
	return startForEachPartition(func, EntityPartition.PLAYER, pos, radius, variant, playerType, inverse)
end

---@generic V
---@param func fun(tear: EntityTear, index: integer): V?
---@param variant? TearVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Tear(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_TEAR, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(tear: EntityTear, index: integer): V?
---@param variant? TearVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.TearInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityPartition.TEAR, pos, radius, variant, subtype, inverse)
end

---@generic V
---@param func fun(familiar: EntityFamiliar, index: integer): V?
---@param variant? FamiliarVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Familiar(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_FAMILIAR, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(familiar: EntityFamiliar, index: integer): V?
---@param variant? FamiliarVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.FamiliarInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityPartition.FAMILIAR, pos, radius, variant, subtype, inverse)
end

---@generic V
---@param func fun(bomb: EntityBomb, index: integer): V?
---@param variant? BombVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Bomb(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_BOMB, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector | Entity @As Bombs lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(bomb: EntityBomb, index: integer): V?
---@param variant? BombVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.BombInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityType.ENTITY_BOMB, pos, radius, variant, subtype, inverse, true)
end

---@generic V
---@param func fun(pickup: EntityPickup, index: integer): V?
---@param variant? PickupVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Pickup(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_PICKUP, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(pickup: EntityPickup, index: integer): V?
---@param variant? PickupVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.PickupInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityPartition.PICKUP, pos, radius, variant, subtype, inverse)
end

---@generic V
---@param func fun(slot: EntitySlot, index: integer): V?
---@param variant? SlotVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Slot(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_SLOT, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector | Entity @As Slots lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(slot: EntitySlot, index: integer): V?
---@param variant? SlotVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.SlotInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityType.ENTITY_SLOT, pos, radius, variant, subtype, inverse, true)
end

---@generic V
---@param func fun(laser: EntityLaser, index: integer): V?
---@param variant? LaserVariant @default: `-1`
---@param subtype? LaserSubType @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Laser(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_LASER, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector | Entity @As Lasers lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(laser: EntityLaser, index: integer): V?
---@param variant? LaserVariant @default: `-1`
---@param subtype? LaserSubType @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.LaserInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityType.ENTITY_LASER, pos, radius, variant, subtype, inverse, true)
end

---@generic V
---@param func fun(knife: EntityKnife, index: integer): V?
---@param variant? KnifeVariant @default: `-1`
---@param subtype? KnifeSubType @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Knife(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_KNIFE, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector | Entity @As Knifes lack an EntityPartition, provide an entity to account for collision spheres intersecting
---@param radius number
---@param func fun(knife: EntityKnife, index: integer): V?
---@param variant? KnifeVariant @default: `-1`
---@param subtype? KnifeSubType @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.KnifeInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityType.ENTITY_KNIFE, pos, radius, variant, subtype, inverse, true)
end

---@generic V
---@param func fun(projectile: EntityProjectile, index: integer): V?
---@param variant? ProjectileVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Projectile(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_PROJECTILE, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(projectile: EntityProjectile, index: integer): V?
---@param variant? ProjectileVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.ProjectileInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityPartition.BULLET, pos, radius, variant, subtype, inverse)
end

---@generic V
---@param func fun(npc: EntityNPC, index: integer): V?
---@param entType EntityType
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.NPC(func, entType, variant, subtype, inverse, shouldCache)
	return startForEachType(func, entType, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(npc: EntityNPC, index: integer): V?
---@param variant? integer @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.NPCInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, EntityPartition.ENEMY, pos, radius, variant, subtype, inverse)
end

---@generic V
---@param func fun(projectile: EntityEffect, index: integer): V?
---@param variant? EffectVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@param shouldCache? boolean @default: `false`
---@return V?
function Foreach.Effect(func, variant, subtype, inverse, shouldCache)
	return startForEachType(func, EntityType.ENTITY_PROJECTILE, variant, subtype, inverse, shouldCache)
end

---@generic V
---@param pos Vector
---@param radius number
---@param func fun(projectile: EntityEffect, index: integer): V?
---@param variant? EffectVariant @default: `-1`
---@param subtype? integer @default: `-1`
---@param inverse? boolean @default: `false`
---@return V?
function Foreach.EffectInRadius(pos, radius, func, variant, subtype, inverse)
	return startForEachPartition(func, REPENTOGON and EntityPartition.EFFECT or EntityType.ENTITY_EFFECT, pos, radius, variant, subtype, inverse, not REPENTOGON)
end

return Foreach