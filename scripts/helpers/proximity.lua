---@param ent Entity?
function Furtherance:IsValidEnemyTarget(ent)
	return ent
	and ent:ToNPC()
	and ent:IsActiveEnemy(false)
	and ent:IsVulnerableEnemy()
	and not ent:HasEntityFlags(EntityFlag.FLAG_CHARM | EntityFlag.FLAG_FRIENDLY)
	and ent.EntityCollisionClass ~= EntityCollisionClass.ENTCOLL_NONE
end

--Thank you piber!
---@param pos Vector
---@param range? number
---@param filter? fun(npc: EntityNPC): boolean?
---@return EntityNPC | nil
function Furtherance:GetClosestEnemy(pos, range, filter)
	---@type EntityNPC | nil
	local closestEnemy
	local closestDistance
	local entities
	if range then
		entities = Isaac.FindInRadius(pos, range, EntityPartition.ENEMY)
	else
		entities = Isaac.GetRoomEntities()
	end

	for _, ent in ipairs(entities) do
		local npc = ent:ToNPC()
		if npc and (not filter and Furtherance:IsValidEnemyTarget(npc) or filter and filter(npc)) then goto continue end
		---@cast npc EntityNPC
		local npcDistance = npc.Position:DistanceSquared(pos)

		if not closestEnemy or npcDistance < closestDistance then
			closestEnemy = npc
			closestDistance = npcDistance
		end
		::continue::
	end
	return closestEnemy
end

---Direct your criticism to IAG
---@param pos Vector
---@param range number
---@param dir Vector
---@param fov number multiply by 2 for actual angle
---@param occludeObstacles boolean
---@param occludeWalls boolean
---@return EntityNPC | nil
function Furtherance:GetClosestEnemyInView(pos, range, dir, fov, occludeObstacles, occludeWalls)
	---@type EntityNPC | nil
	local closestEnemy
	local closestDistance

	for _, ent in pairs(Isaac.FindInRadius(pos, range, EntityPartition.ENEMY)) do
		local npc = ent:ToNPC()
		if not Furtherance:IsValidEnemyTarget(npc) then goto continue end
		---@cast npc EntityNPC

		local dirToEnemy = (npc.Position - pos)
		local dotProduct = dirToEnemy:Normalized():Dot(dir:Normalized()) -- equal to cos(angleDiff)
		if dotProduct < math.cos(math.rad(fov)) then goto continue end

		local threshold = occludeObstacles and 1000 or 5000
		local noOcclude = Furtherance.Room():CheckLine(pos, ent.Position, 3, threshold, occludeWalls)
		if (occludeObstacles or occludeWalls) and not noOcclude then goto continue end

		local npcDistance = npc.Position:DistanceSquared(pos)
		if not closestEnemy or npcDistance < closestDistance then
			closestEnemy = npc
			closestDistance = npcDistance
		end
		::continue::
	end
	return closestEnemy
end

---Thank you piber!
---@param pos Vector
---@param range number
---@return EntityProjectile | nil
function Furtherance:GetClosestProjectile(pos, range)
	---@type EntityProjectile | nil
	local closestEnemy
	local closestDistance

	for _, ent in pairs(Isaac.FindInRadius(pos, range, EntityPartition.BULLET)) do
		local proj = ent:ToProjectile()
		if not proj then goto continue end
		local projDistance = ent.Position:DistanceSquared(pos)

		if not closestEnemy or projDistance < closestDistance then
			closestEnemy = proj
			closestDistance = projDistance
		end
		::continue::
	end
	return closestEnemy
end

---@param func fun(npc: EntityNPC)
---@param validTarget boolean
---@param pos? Vector
---@param radius? integer
function Furtherance:ForEachEnemy(func, validTarget, pos, radius)
	local entities
	if radius and pos then
		entities = Isaac.FindInRadius(pos, radius, EntityPartition.ENEMY)
	else
		entities = Isaac.GetRoomEntities()
	end
	for _, ent in pairs(entities) do
		local npc = ent:ToNPC()
		if npc and (validTarget and Furtherance:IsValidEnemyTarget(npc) or npc:IsActiveEnemy(false)) then
			if func(npc) then
				return true
			end
		end
	end
end
