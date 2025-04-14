local Mod = Furtherance

local POLYDIPSIA = {}

Furtherance.Item.POLYDIPSIA = POLYDIPSIA

POLYDIPSIA.ID = Isaac.GetItemIdByName("Polydipsia")

POLYDIPSIA.CREEP_TIMEOUT = 90

local floor = math.floor

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function POLYDIPSIA:Stats(player, cacheFlag)
	if not player:HasCollectible(POLYDIPSIA.ID) or player:HasWeaponType(WeaponType.WEAPON_BONE) then return end

	if cacheFlag == CacheFlag.CACHE_RANGE then
		player.TearFallingSpeed = player.TearFallingSpeed * 20
		player.TearFallingAcceleration = player.TearFallingAcceleration + 1
		player.TearRange = player.TearRange * 0.8
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY then
		player.MaxFireDelay = (player.MaxFireDelay * 2) + 8
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLYDIPSIA.Stats, CacheFlag.CACHE_FIREDELAY)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLYDIPSIA.Stats, CacheFlag.CACHE_RANGE)

function POLYDIPSIA:UpdateCreepSize(creep, newSize)
	local creepSize = math.sqrt(newSize / 10)
	creep.SpriteScale = Vector(creepSize, creepSize)
	creep.Size = (((creepSize * 12.5) ^ 1.75) / (newSize * 0.25))
end

---@param player EntityPlayer
---@param ent Entity
---@param enemyPos? Vector
function POLYDIPSIA:SpawnPolydipsiaCreep(player, ent, enemyPos)
	local pos = enemyPos or ent.Position
	if ent:ToLaser() then
		---@cast ent EntityLaser
		if ent.SubType == LaserSubType.LASER_SUBTYPE_LINEAR then
			pos = enemyPos or ent:GetEndPoint()
		elseif enemyPos and ent.SubType ~= LaserSubType.LASER_SUBTYPE_NO_IMPACT then
			pos = ent.Position + (enemyPos - ent.Position):Resized(ent.Radius)
		end
	end
	pos = Mod.Room():GetClampedPosition(pos, 25)
	--How Aquarius Creep is calculated by default according to rgon docs, with some adjustments
	local tearParams = player:GetTearHitParams(WeaponType.WEAPON_TEARS,
		(player:GetTearPoisonDamage() * 0.666) / player.Damage, 5, player)
	local creep = player:SpawnAquariusCreep(tearParams)
	local size = ent.Size
	--Epic Fetus
	if ent:ToEffect() then
		--They only exist for one frame and do change size with the explosion radius
		for _, eff in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.BOMB_CRATER)) do
			if eff.Position:DistanceSquared(pos) <= 0 then
				size = 15 * eff.SpriteScale.X
			end
		end
	elseif player:HasCollectible(CollectibleType.COLLECTIBLE_POLYPHEMUS) then
		size = size + 15
	end
	if ent:ToKnife() and ent.SubType ~= KnifeSubType.CLUB_HITBOX then
		creep:SetTimeout(Mod:RandomNum(floor(POLYDIPSIA.CREEP_TIMEOUT / 4), floor(POLYDIPSIA.CREEP_TIMEOUT / 2)))
	else
		POLYDIPSIA:UpdateCreepSize(creep, size)
		creep:SetTimeout(90)
		creep:GetSprite():Play("BigBlood0" .. Mod:RandomNum(6))
	end
	if ent:ToLaser() then
		if not Mod:AreColorsDifferent(player.LaserColor, Color.Default) then
			creep:GetSprite().Color = Color(1, 0, 0)
		end
	end
	creep.Position = pos
	for _, eff in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL)) do
		local existingCreep = eff:ToEffect()
		---@cast existingCreep EntityEffect
		if not Mod:IsSameEntity(eff, creep) and creep.Position:DistanceSquared(existingCreep.Position) <= (creep.Size + existingCreep.Size) ^ 2 and existingCreep.FrameCount > 1 then
			local data = Mod:GetData(existingCreep)
			data.PolydipsiaPenalty = (data.PolydipsiaPenalty or 0)
			existingCreep:SetTimeout(Mod:Clamp(existingCreep.Timeout + 30 - data.PolydipsiaPenalty, 0,
				POLYDIPSIA.CREEP_TIMEOUT))
			data.PolydipsiaPenalty = math.max(0, data.PolydipsiaPenalty + 5)
		end
	end
	return creep
end

---@param weaponEnt Entity
function POLYDIPSIA:OnWeaponEntityFire(weaponEnt)
	local player = Mod:TryGetPlayer(weaponEnt)
	if player and player:HasCollectible(POLYDIPSIA.ID) then
		Mod:GetData(weaponEnt).PolydipsiaShot = true
		if weaponEnt:ToTear() and not weaponEnt:ToTear():HasTearFlags(TearFlags.TEAR_LUDOVICO) then
			---@cast weaponEnt EntityTear
			weaponEnt.Scale = weaponEnt.Scale * 1.4
			weaponEnt:AddTearFlags(TearFlags.TEAR_KNOCKBACK)
			weaponEnt.Mass = weaponEnt.Mass * 1.5
			weaponEnt:SetKnockbackMultiplier(weaponEnt.KnockbackMultiplier * 5)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, POLYDIPSIA.OnWeaponEntityFire, EffectVariant.ROCKET)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_SWORD, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, POLYDIPSIA.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BONE_CLUB, POLYDIPSIA.OnWeaponEntityFire)

---@param tear EntityTear
function POLYDIPSIA:OnTearDeath(tear)
	local player = Mod:TryGetPlayer(tear)
	local data = Mod:TryGetData(tear)
	if player and data and data.PolydipsiaShot then
		POLYDIPSIA:SpawnPolydipsiaCreep(player, tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, POLYDIPSIA.OnTearDeath)

---@param tear EntityTear
function POLYDIPSIA:OnLudoTearUpdate(tear)
	if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
	local player = Mod:TryGetPlayer(tear)
	if not player then return end
	if player:HasCollectible(POLYDIPSIA.ID) and Mod:ShouldUpdateLudo(tear, player) then
		POLYDIPSIA:SpawnPolydipsiaCreep(player, tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, POLYDIPSIA.OnLudoTearUpdate)

---@param bomb EntityBomb
function POLYDIPSIA:OnBombExplode(bomb)
	local data = Mod:TryGetData(bomb)
	local player = Mod:TryGetPlayer(bomb)
	if player and data and data.PolydipsiaShot then
		POLYDIPSIA:SpawnPolydipsiaCreep(player, bomb)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, POLYDIPSIA.OnBombExplode)
Mod:AddCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, POLYDIPSIA.OnBombExplode)

---@param knife EntityKnife
function POLYDIPSIA:OnKnifeUpdate(knife)
	local player = Mod:TryGetPlayer(knife)
	if player and player:HasCollectible(POLYDIPSIA.ID) and knife:IsFlying() then
		local data = Mod:GetData(knife)
		if (data.NextPuddleSpawn or 0) == 0 then
			data.NextPuddleSpawn = Mod:RandomNum(2, 5)
		end
		if data.NextPuddleSpawn > 0 then
			data.NextPuddleSpawn = data.NextPuddleSpawn - 1
			if data.NextPuddleSpawn == 0 then
				POLYDIPSIA:SpawnPolydipsiaCreep(player, knife)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, POLYDIPSIA.OnKnifeUpdate)

---@param laser EntityLaser
function POLYDIPSIA:OnLaserUpdate(laser)
	local player = Mod:TryGetPlayer(laser)
	local data = Mod:TryGetData(laser)
	if player and (data and data.PolydipsiaShot or laser.SubType ~= LaserSubType.LASER_SUBTYPE_LINEAR) then
		data = Mod:GetData(laser)
		if (data.NextPuddleSpawn or 0) == 0 then
			data.NextPuddleSpawn = laser.Timeout == 0 and 6 or 3
		end
		if data.NextPuddleSpawn > 0 then
			data.NextPuddleSpawn = data.NextPuddleSpawn - 1
			if data.NextPuddleSpawn == 0 then
				local indexMap = Mod:Set(laser:GetHitList())
				for _, ent in ipairs(Isaac.GetRoomEntities()) do
					if indexMap[ent.Index] then
						POLYDIPSIA:SpawnPolydipsiaCreep(player, laser, ent.Position)
					end
				end
				if laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR then
					POLYDIPSIA:SpawnPolydipsiaCreep(player, laser)
				end
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, POLYDIPSIA.OnLaserUpdate)

--[[

local allPuddles = {}

local function makeMiriamPuddle(miriam, tear)
	local data = Mod:GetData(tear)
	local playerData = Mod:GetData(miriam)
	if playerData.MiriamAOE == nil then
		playerData.MiriamAOE = 1
	end
	if data.MiriamPullEnemies then
		local whirlpool = Isaac.Spawn(EntityType.ENTITY_EFFECT, WhirlpoolVariant, 0, tear.Position, Vector.Zero, miriam)
		:ToEffect()
		whirlpool.CollisionDamage = miriam.Damage * 0.33
		whirlpool.LifeSpan = 60
	else
		local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 1, tear
		.Position, Vector.Zero, miriam):ToEffect()
		---@cast puddle EntityEffect
		local puddleDamage = miriam.Damage * 0.33
		puddle.CollisionDamage = 0
		puddle.SpriteScale = Vector.One * playerData.MiriamAOE
		puddle.Scale = playerData.MiriamAOE
		if miriam:HasCollectible(CollectibleType.COLLECTIBLE_CHOCOLATE_MILK) then
			puddle.Color = Color(0.75, 0.25, 0.05, 1)
		end
		if miriam:HasCollectible(CollectibleType.COLLECTIBLE_TECHNOLOGY) or miriam:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
			puddle.Color = Color(1, 0, 0, 1)
			if miriam:HasCollectible(CollectibleType.COLLECTIBLE_BRIMSTONE) then
				puddleDamage = miriam.Damage * 0.4
			end
		end
		if miriam:HasCollectible(CollectibleType.COLLECTIBLE_SOY_MILK) then
			local color = Color(1, 1, 1, 1, 0, 0, 0)
			color:SetColorize(2, 2, 2, 1)
			puddle.Color = color
			puddle.SpriteScale = Vector.One * playerData.MiriamAOE / 2
			puddle.Scale = playerData.MiriamAOE / 2
		end
		allPuddles[GetPtrHash(puddle)] = {
			Entity = puddle,
			Damage = puddleDamage,
			CollisionRadius = 25 * playerData.MiriamAOE,
			DamageCooldown = 0,
			DamageRef = EntityRef(miriam)
		}
	end

	if hasItem(miriam) and tear.SubType == 0 then
		local PolyMiriam = miriam:FireTear(tear.Position, tear.Velocity, true, true, false, miriam, 1)
		PolyMiriam.SubType = 1
	end
end

function Mod:OnTearImpact(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if not hasItem(player) and not isMiriam(player) then return end

	if isMiriam(player) then
		makeMiriamPuddle(player, tear)
	else
		local puddle = Isaac.Spawn(EntityType.ENTITY_EFFECT, EffectVariant.PLAYER_CREEP_HOLYWATER_TRAIL, 1, tear
		.Position, Vector.Zero, player):ToEffect()
		---@cast puddle EntityEffect
		puddle.CollisionDamage = 0
		allPuddles[GetPtrHash(puddle)] = {
			Entity = puddle,
			Damage = player.Damage * 0.33,
			CollisionRadius = 25,
			DamageCooldown = 0,
			DamageRef = EntityRef(player)
		}
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, Mod.OnTearImpact, EntityType.ENTITY_TEAR)

function Mod:PolydipsiaPuddleUpdate()
	-- remove puddles that don't exist
	for k, puddleData in pairs(allPuddles) do
		if puddleData.Entity.Timeout <= 0 or not puddleData.Entity:Exists() then
			allPuddles[k] = nil
		end
	end

	-- update puddles
	for _, puddleData in pairs(allPuddles) do
		if puddleData.DamageCooldown <= 0 then
			local puddle = puddleData.Entity
			for _, enemy in ipairs(Isaac.FindInRadius(puddle.Position, puddleData.CollisionRadius, EntityPartition.ENEMY)) do
				if not enemy:IsFlying() then
					enemy:TakeDamage(puddleData.Damage, 0, puddleData.DamageRef, 0)
					puddleData.DamageCooldown = 4
				end
			end
		end
		puddleData.DamageCooldown = math.max(puddleData.DamageCooldown - 1, 0)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_UPDATE, Mod.PolydipsiaPuddleUpdate)

function Mod:MakePolydipsiaTear(tear)
	local player = tear.Parent:ToPlayer()
	if hasItem(player) or isMiriam(player) then
		tear.Scale = tear.Scale * 1.4
		tear:AddTearFlags(TearFlags.TEAR_KNOCKBACK)
		tear:SetKnockbackMultiplier(tear.KnockbackMultiplier * 2)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.MakePolydipsiaTear)

-- Dr. Fetus Synergy
function Mod:PolyBombUpdate(bomb)
	local player = Mod:GetPlayerFromTear(bomb)
	local data = Mod:GetData(bomb)
	if player then
		if bomb.FrameCount == 1 then
			if bomb.Type == EntityType.ENTITY_BOMB and bomb.Variant ~= BombVariant.BOMB_THROWABLE
				and (player:HasCollectible(CollectibleType.COLLECTIBLE_POLYDIPSIA) or isMiriam(player)) then
				if data.isPolyBomb == nil then
					data.isPolyBomb = true
				end
			end
		end
	end
	if data.isPolyBomb then
		local sprite = bomb:GetSprite()
		if sprite:IsPlaying("Explode") then
			makeMiriamPuddle(player, bomb)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_BOMB_UPDATE, Mod.PolyBombUpdate)

-- Brimstone & Tech "Synergy"
function Mod:PolyLasers(laser)
	local player = laser.SpawnerEntity and laser.SpawnerEntity:ToPlayer()
	if player ~= nil and (player:HasCollectible(CollectibleType.COLLECTIBLE_POLYDIPSIA) or isMiriam(player)) and laser.FrameCount == 1 then
		makeMiriamPuddle(player, laser)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, Mod.PolyLasers)
 ]]
