local Mod = Furtherance

local POLYDIPSIA = {}

Furtherance.Item.POLYDIPSIA = POLYDIPSIA

POLYDIPSIA.ID = Isaac.GetItemIdByName("Polydipsia")

---@param player EntityPlayer
---@param cacheFlag CacheFlag
function POLYDIPSIA:Stats(player, cacheFlag)
	if not player:HasCollectible(POLYDIPSIA.ID) then return end

	if cacheFlag == CacheFlag.CACHE_RANGE then
		player.TearFallingSpeed = player.TearFallingSpeed + 20
		player.TearFallingAcceleration = player.TearFallingAcceleration + 1
	elseif cacheFlag == CacheFlag.CACHE_FIREDELAY and not player:HasWeaponType(WeaponType.WEAPON_BONE) then
		player.MaxFireDelay = (player.MaxFireDelay * 2) + 10
	end
end

Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLYDIPSIA.Stats, CacheFlag.CACHE_FIREDELAY)
Mod:AddCallback(ModCallbacks.MC_EVALUATE_CACHE, POLYDIPSIA.Stats, CacheFlag.CACHE_RANGE)

---@param player EntityPlayer
---@param ent Entity
function POLYDIPSIA:SpawnPolydipsiaCreep(player, ent)
	local pos = Mod.Room():GetClampedPosition(ent:ToLaser() and ent:ToLaser():GetEndPoint() or ent.Position, 25)
	local weapon = player:GetWeapon(0)
	local weaponType = weapon and weapon:GetWeaponType() or WeaponType.WEAPON_TEARS
	--How Aquarius Creep is calculated by default according to rgon docs, with some adjustments
	local tearParams = player:GetTearHitParams(weaponType, (player:GetTearPoisonDamage() * 0.666) / player.Damage, -Mod:RandomNum(2) & 2 - 1, nil)
	local creep = player:SpawnAquariusCreep(tearParams)
	if ent:ToKnife() then
		creep:SetTimeout(Mod:RandomNum(15, 45))
	else
		creep:SetTimeout(90)
		creep.SpriteScale = creep.SpriteScale * 1.25
		creep:GetSprite():Play("BigBlood0" .. Mod:RandomNum(6))
	end
	creep.Position = pos
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
			weaponEnt:SetKnockbackMultiplier(weaponEnt.KnockbackMultiplier * 2)
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
	local data = Mod:GetData(player)
	if data.PolydipsiaShot and Mod:ShouldUpdateLudo(tear, player) then
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

---@param knife EntityKnife
function POLYDIPSIA:OnKnifeUpdate(knife)
	local player = Mod:TryGetPlayer(knife)
	if player and player:HasCollectible(POLYDIPSIA.ID) and knife:IsFlying() then
		local data = Mod:GetData(knife)
		if (data.NextPuddleSpawn or 0)  == 0 then
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
	if player and data and data.PolydipsiaShot then
		local indexMap = Mod:Set(laser:GetHitList())
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if indexMap[ent.Index] then
				POLYDIPSIA:SpawnPolydipsiaCreep(player, ent)
			end
		end
		POLYDIPSIA:SpawnPolydipsiaCreep(player, laser)
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