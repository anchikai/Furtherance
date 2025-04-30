--The design of Miriam on the original workshop version was a series of compromises from the original vision, and I failed to recognize that before I finished all this
--Though I'm too proud of the code to just delete it, so it'll remain here

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
		Mod.Foreach.EffectInRadius(pos, 0, function (effect, index)
			size = 15 * effect.SpriteScale.X
		end, EffectVariant.BOMB_CRATER)
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
	local player = Mod:TryGetPlayer(tear, true)
	local data = Mod:TryGetData(tear)
	if player and data and data.PolydipsiaShot then
		POLYDIPSIA:SpawnPolydipsiaCreep(player, tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, POLYDIPSIA.OnTearDeath)

---@param tear EntityTear
function POLYDIPSIA:OnLudoTearUpdate(tear)
	if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
	local player = Mod:TryGetPlayer(tear, true)
	if not player then return end
	if player:HasCollectible(POLYDIPSIA.ID) and Mod:ShouldUpdateLudo(tear, player) then
		POLYDIPSIA:SpawnPolydipsiaCreep(player, tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, POLYDIPSIA.OnLudoTearUpdate)

---@param bomb EntityBomb
function POLYDIPSIA:OnBombExplode(bomb)
	local data = Mod:TryGetData(bomb)
	local player = Mod:TryGetPlayer(bomb, true)
	if player and data and data.PolydipsiaShot then
		POLYDIPSIA:SpawnPolydipsiaCreep(player, bomb)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, POLYDIPSIA.OnBombExplode)
Mod:AddCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, POLYDIPSIA.OnBombExplode)

---@param knife EntityKnife
function POLYDIPSIA:OnKnifeUpdate(knife)
	local player = Mod:TryGetPlayer(knife, true)
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
	local player = Mod:TryGetPlayer(laser, true)
	local data = Mod:TryGetData(laser)
	if player and (data and data.PolydipsiaShot or (player:HasCollectible(POLYDIPSIA.ID) and laser.SubType ~= LaserSubType.LASER_SUBTYPE_LINEAR)) then
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
