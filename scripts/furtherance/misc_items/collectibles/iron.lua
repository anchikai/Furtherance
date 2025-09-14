local Mod = Furtherance

local IRON = {}

Furtherance.Item.IRON = IRON

IRON.ID = Isaac.GetItemIdByName("Iron")
IRON.FAMILIAR = Isaac.GetEntityVariantByName("Iron")

IRON.TEAR_COLOR = Color(1, 1, 1, 1, 0.3, 0, 0, 1.8, 0.9, 0.3, 1)
IRON.LASER_COLOR = Color(1, 1, 1, 1, 0, 0, 0, 5, 3, 1, 1)
IRON.ORBIT_DISTANCE = Vector(128, 128)
IRON.ORBIT_SPEED = 0.01

---I love knives and lasers so much you have no idea (send help)

---@param weaponEnt Entity | EntityBomb
function IRON:ShouldBotherWithUpdate(weaponEnt)
	return #Isaac.FindByType(EntityType.ENTITY_FAMILIAR, IRON.FAMILIAR) > 0
		and Mod:TryGetPlayer(weaponEnt.SpawnerEntity)
		and (not weaponEnt:ToBomb() or weaponEnt.IsFetus)
end

---@param familiar EntityFamiliar
function IRON:IronInit(familiar)
	familiar:AddToOrbit(5)
	familiar.OrbitLayer = 5
	familiar.OrbitDistance = IRON.ORBIT_DISTANCE
	familiar.OrbitSpeed = IRON.ORBIT_SPEED
	familiar:RecalculateOrbitOffset(familiar.OrbitLayer, true)
	IRON:IronUpdate(familiar)
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_INIT, IRON.IronInit, IRON.FAMILIAR)

---@param tear EntityTear
function IRON:TearCollision(tear)
	if not IRON:ShouldBotherWithUpdate(tear) then return end
	Mod.Foreach.FamiliarInRadius(tear.Position, tear.Size, function (familiar, index)
		local data = Mod:GetData(tear)
		if not data.WentThruIron then
			tear.CollisionDamage = tear.CollisionDamage * 2
			tear:AddTearFlags(TearFlags.TEAR_BURN)
			tear:SetColor(IRON.TEAR_COLOR, -1, 1, false, true)
			tear.Scale = tear.Scale * 1.5
			tear:ResetSpriteScale(true)
			data.WentThruIron = true
		end
		if tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			data.CheckLeavingIron = true
		end
		return true
	end, IRON.FAMILIAR)
	local data = Mod:TryGetData(tear)
	if not data or not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
	local player = Mod:TryGetPlayer(tear.SpawnerEntity)
	---@cast player EntityPlayer
	if data.WentThruIron and Mod:ShouldUpdateLudo(tear, player) then
		if data.CheckLeavingIron then
			tear.CollisionDamage = tear.CollisionDamage * 2
		end
		tear:AddTearFlags(TearFlags.TEAR_BURN)
		tear:SetColor(IRON.TEAR_COLOR, -1, 1, false, true)
	end

	data.CheckLeavingIron = nil
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, IRON.TearCollision)

---@param bomb EntityBomb
function IRON:BombCollision(bomb)
	if not IRON:ShouldBotherWithUpdate(bomb) then return end
	Mod.Foreach.FamiliarInRadius(bomb.Position, bomb.Size, function (familiar, index)
		local data = Mod:GetData(bomb)
		if not data.WentThruIron then
			bomb:AddTearFlags(TearFlags.TEAR_BURN)
			bomb.ExplosionDamage = bomb.ExplosionDamage * 2
			bomb:SetScale(bomb.ExplosionDamage / 35)
			bomb:SetLoadCostumes(true)
			data.WentThruIron = true
			return true
		end
	end, IRON.FAMILIAR)
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, IRON.BombCollision)

---Knife collision damage is reset on update and doesn't care about if you update it during its POST_UPDATE function
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function IRON:KnifeDamage(ent, amount, flags, source, countdown)
	if ent:IsActiveEnemy(false)
		and source.Entity
		and source.Entity:ToKnife()
	then
		local data = Mod:TryGetData(source.Entity)
		if data and data.IronKnifeDistance then
			return {Damage = amount * 2}
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, IRON.KnifeDamage)

---@param knife EntityKnife
function IRON:KnifeCollision(knife)
	local data = Mod:TryGetData(knife)
	if knife:HasTearFlags(TearFlags.TEAR_LUDOVICO) then
		Mod.Foreach.FamiliarInRadius(knife.Position, knife.Size, function (familiar, index)
			data = Mod:GetData(knife)
			if not data.IronKnifeDistance then
				data.IronKnifeDistance = true
			end
			data.CheckLeavingIron = true
			return true
		end, IRON.FAMILIAR)
		if data and data.IronKnifeDistance then
			if not data.CheckLeavingIron then
				data.IronKnifeDistance = nil
			else
				knife:GetSprite().Color = IRON.TEAR_COLOR
				knife:AddTearFlags(TearFlags.TEAR_BURN)
			end
		end
		data.CheckLeavingIron = nil
		return
	end
	--Placed here because unlike the tear, it's still actually always the same knife and never respawns unless you exit/continue
	--So we should nil out the data ourselves if you happen to lose the familiar
	if not IRON:ShouldBotherWithUpdate(knife) then return end
	if knife:IsFlying() then
		Mod.Foreach.FamiliarInRadius(knife.Position, knife.Size, function (familiar, index)
			data = Mod:GetData(knife)
			if not data.IronKnifeDistance then
				data.IronKnifeDistance = knife:GetKnifeDistance()
			end
			return true
		end, IRON.FAMILIAR)
	end
	if data and data.IronKnifeDistance then
		knife:GetSprite().Color = IRON.TEAR_COLOR
		knife:AddTearFlags(TearFlags.TEAR_BURN)
		if knife:GetKnifeDistance() < data.IronKnifeDistance then
			data.IronKnifeDistance = nil
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, IRON.KnifeCollision)

---@param laser EntityLaser
function IRON:LaserCollision(laser)
	if not IRON:ShouldBotherWithUpdate(laser) then return end
	local samplePoints = laser:GetNonOptimizedSamples()

	for i=0, #samplePoints-1 do
		local pos = samplePoints:Get(i)
		Mod.Foreach.FamiliarInRadius(pos, laser.Size, function (familiar, index)
			local data = Mod:GetData(laser)
			if not data.IronFireActive then
				data.IronFireActive = true
				laser:GetSprite().Color = IRON.LASER_COLOR
			end
			data.IronLaserCollision = true
			return true
		end, IRON.FAMILIAR)
	end
	local data = Mod:TryGetData(laser)
	if not data then return end
	if not data.IronLaserCollision
		and data.IronFireActive
		and laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR
	then
		local player = Mod:TryGetPlayer(laser.SpawnerEntity)
		---@cast player EntityPlayer
		laser:GetSprite().Color = player.LaserColor
		if data.IronDamageMult then
			laser:SetDamageMultiplier(data.IronDamageMult)
		end
		data.IronFireActive = nil
		data.IronDamageMult = nil
	end
	if data.IronFireActive then
		laser:AddTearFlags(TearFlags.TEAR_BURN)
		if not data.IronDamageMult then
			data.IronDamageMult = laser:GetDamageMultiplier()
		end
		laser:SetDamageMultiplier(data.IronDamageMult * 2)
	end
	data.IronLaserCollision = nil
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, IRON.LaserCollision)

---@param familiar EntityFamiliar
function IRON:IronUpdate(familiar)
	local player = familiar.Player
	local targetPosition = familiar:GetOrbitPosition(player.Position + player.Velocity)
	familiar.OrbitLayer = 5
	familiar.OrbitDistance = IRON.ORBIT_DISTANCE
	familiar.OrbitSpeed = IRON.ORBIT_SPEED
	familiar.Velocity = targetPosition - familiar.Position
end

Mod:AddCallback(ModCallbacks.MC_FAMILIAR_UPDATE, IRON.IronUpdate, IRON.FAMILIAR)

---@param player EntityPlayer
function IRON:FamiliarCache(player)
	local effects = player:GetEffects()
	local numFamiliars = player:GetCollectibleNum(IRON.ID) + effects:GetCollectibleEffectNum(IRON.ID)
	local rng = player:GetCollectibleRNG(IRON.ID)
	rng:Next()
	player:CheckFamiliar(IRON.FAMILIAR, numFamiliars, rng, Mod.ItemConfig:GetCollectible(IRON.ID))
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, IRON.FamiliarCache, CacheFlag.CACHE_FAMILIARS)
