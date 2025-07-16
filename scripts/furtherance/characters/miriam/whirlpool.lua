--#region Variables

local floor = math.floor
local Mod = Furtherance
local MIRIAM = Mod.Character.MIRIAM

local WHIRLPOOL = {}

Furtherance.Character.MIRIAM.WHIRLPOOL = WHIRLPOOL

WHIRLPOOL.THRESHOLD = 12
WHIRLPOOL.ID = Isaac.GetEntityVariantByName("Miriam Whirlpool")
WHIRLPOOL.DAMAGE_COUNTDOWN = 3

--#endregion

--#region Spawning Whirlpool

---@param ent Entity @The source of the Whirlpool
---@param enemyPos? Vector
function WHIRLPOOL:SpawnWhirlpool(ent, enemyPos)
	local player = Mod:TryGetPlayer(ent)
	local pos = enemyPos or ent.Position
	if ent:ToLaser() then
		---@cast ent EntityLaser
		if ent.SubType == LaserSubType.LASER_SUBTYPE_LINEAR then
			pos = enemyPos or Mod:GetLaserEndPoint(ent) or ent.Position
		elseif enemyPos and ent.SubType ~= LaserSubType.LASER_SUBTYPE_NO_IMPACT then
			pos = ent.Position + (enemyPos - ent.Position):Resized(ent.Radius)
		end
	end
	pos = Mod.Room():GetClampedPosition(pos, 25)
	local whirlpool = Isaac.Spawn(EntityType.ENTITY_EFFECT, WHIRLPOOL.ID, 0, pos, Vector.Zero, ent.SpawnerEntity)
		:ToEffect()
	---@cast whirlpool EntityEffect
	whirlpool.CollisionDamage = (player and player.Damage or 3.5) * 0.33
	whirlpool.Timeout = 60
	Mod.SFXMan:Play(SoundEffect.SOUND_BOSS2_WATERTHRASHING, 0.25, 30, false, 0.8)
	if player then
		if ent:ToLaser()
			and not Mod:AreColorsDifferent(player.LaserColor, Color.Default)
		then
			whirlpool:GetSprite().Color = Color(1, 0, 0)
		else
			whirlpool:GetSprite().Color = ent:ToLaser() and player:GetTearHitParams(WeaponType.WEAPON_TEARS, 1, 0, player).TearColor or ent:GetSprite().Color
		end
	end
end

---@param dir Vector
---@param amount integer
---@param owner EntityPlayer | EntityFamiliar
---@param weapon Weapon
function WHIRLPOOL:WhirlpoolOnFire(dir, amount, owner, weapon)
	local player = Mod:TryGetPlayer(owner)
	if not player or not MIRIAM:IsMiriam(player) then return end
	local previousNum = weapon:GetNumFired() - amount
	local threshold = WHIRLPOOL.THRESHOLD
	if MIRIAM:MiriamHasBirthright(player) then
		threshold = threshold - floor(threshold / 3)
	end

	if (previousNum % threshold) + amount >= threshold then
		Mod:GetData(player).MiriamQueueWhirlpoolShot = true
		if weapon:GetWeaponType() ~= WeaponType.WEAPON_ROCKETS then
			Mod:DelayOneFrame(function() Mod:GetData(player).MiriamQueueWhirlpoolShot = nil end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TRIGGER_WEAPON_FIRED, WHIRLPOOL.WhirlpoolOnFire)

---@param weaponEnt Entity
function WHIRLPOOL:OnWeaponEntityFire(weaponEnt)
	local player = Mod:TryGetPlayer(weaponEnt)
	if not player then return end
	local data = Mod:GetData(player)
	if data.MiriamQueueWhirlpoolShot then
		Mod:GetData(weaponEnt).MiriamWhirlpoolShot = Mod.Game:GetFrameCount()
		if player:GetWeapon(1):GetWeaponType() == WeaponType.WEAPON_MONSTROS_LUNGS then
			data.MiriamQueueWhirlpoolShot = nil
		end
		if weaponEnt.Type == EntityType.ENTITY_EFFECT then
			Mod:DelayOneFrame(function() data.MiriamQueueWhirlpoolShot = nil end)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WHIRLPOOL.OnWeaponEntityFire, EffectVariant.ROCKET)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_SWORD, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_KNIFE, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BRIMSTONE_BALL, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_LASER, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TECH_X_LASER, WHIRLPOOL.OnWeaponEntityFire)
Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BONE_CLUB, WHIRLPOOL.OnWeaponEntityFire)

---@param tear EntityTear
function WHIRLPOOL:OnTearDeath(tear)
	local data = Mod:TryGetData(tear)
	if data and data.MiriamWhirlpoolShot then
		WHIRLPOOL:SpawnWhirlpool(tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_DEATH, WHIRLPOOL.OnTearDeath)

---@param tear EntityTear
function WHIRLPOOL:OnLudoTearUpdate(tear)
	if not tear:HasTearFlags(TearFlags.TEAR_LUDOVICO) then return end
	local player = Mod:TryGetPlayer(tear)
	if not player then return end
	local data = Mod:GetData(player)
	if data.MiriamQueueWhirlpoolShot then
		WHIRLPOOL:SpawnWhirlpool(tear)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_TEAR_UPDATE, WHIRLPOOL.OnLudoTearUpdate)

---@param bomb EntityBomb
function WHIRLPOOL:OnBombExplode(bomb)
	local data = Mod:TryGetData(bomb)
	if data and data.MiriamWhirlpoolShot then
		WHIRLPOOL:SpawnWhirlpool(bomb)
	end
end

Mod:AddCallback(Mod.ModCallbacks.POST_BOMB_EXPLODE, WHIRLPOOL.OnBombExplode)
Mod:AddCallback(Mod.ModCallbacks.POST_ROCKET_EXPLODE, WHIRLPOOL.OnBombExplode)

---@param knife EntityKnife
function WHIRLPOOL:SpawnWhirlpoolAtKnifePeak(knife)
	local player = Mod:TryGetPlayer(knife)
	if not player then return end
	local pData = Mod:GetData(player)
	if pData.MiriamQueueWhirlpoolShot then
		Mod:GetData(knife).MiriamWhirlpoolShot = true
	end
	local kData = Mod:TryGetData(knife)
	if kData and kData.MiriamWhirlpoolShot and knife:IsFlying() then
		if not kData.MiriamWhirlpoolHighestDistance
			or kData.MiriamWhirlpoolHighestDistance < knife:GetKnifeDistance()
		then
			kData.MiriamWhirlpoolHighestDistance = knife:GetKnifeDistance()
		else
			kData.MiriamWhirlpoolShot = nil
			kData.MiriamWhirlpoolHighestDistance = nil
			WHIRLPOOL:SpawnWhirlpool(knife)
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_KNIFE_UPDATE, WHIRLPOOL.SpawnWhirlpoolAtKnifePeak)

---@param laser EntityLaser
function WHIRLPOOL:WhirlpoolAtLaserPeak(laser)
	local player = Mod:TryGetPlayer(laser)
	if not player then return end
	local pData = Mod:GetData(player)
	local lData = Mod:TryGetData(laser)
	if ((laser.SubType == LaserSubType.LASER_SUBTYPE_LINEAR and lData and lData.MiriamWhirlpoolShot)
		or laser.SubType ~= LaserSubType.LASER_SUBTYPE_LINEAR and pData.MiriamQueueWhirlpoolShot == Mod.Game:GetFrameCount())
	then
		local indexMap = Mod:Set(laser:GetHitList())
		for _, ent in ipairs(Isaac.GetRoomEntities()) do
			if indexMap[ent.Index] then
				WHIRLPOOL:SpawnWhirlpool(laser, ent.Position)
				lData.MiriamWhirlpoolShot = nil
				return
			end
		end
		WHIRLPOOL:SpawnWhirlpool(laser)
		lData.MiriamWhirlpoolShot = nil
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_LASER_UPDATE, WHIRLPOOL.WhirlpoolAtLaserPeak)

--#endregion

--#region Whirlpool logic

function WHIRLPOOL:OnEffectInit(effect)
	effect.SortingLayer = SortingLayer.SORTING_BACKGROUND
	--Aqurius Creep is 2000
	effect.RenderZOffset = 2050
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_INIT, WHIRLPOOL.OnEffectInit, WHIRLPOOL.ID)

---@param effect EntityEffect
function WHIRLPOOL:OnEffectUpdate(effect)
	local capsule = effect:GetNullCapsule("hitcapsule")
	local sprite = effect:GetSprite()
	if sprite:IsFinished("Appear") then
		sprite:Play("Idle")
	elseif sprite:IsPlaying("Idle") then
		if effect.Timeout > 0 then
			effect.Timeout = effect.Timeout - 1
		else
			effect:Die()
			sprite:Play("Death", true)
		end
	elseif sprite:IsFinished("Death") then
		effect:Remove()
	end
	if capsule then
		local data = Mod:GetData(effect)
		data.SuccList = data.SuccList or {}
		for _, ent in ipairs(Isaac.FindInCapsule(capsule, EntityPartition.ENEMY)) do
			if ent:IsActiveEnemy(false) then
				if not data.SuccList[ent.Index] then
					local dist = (effect.Position - ent.Position):Resized(ent.Position:Distance(effect.Position))
					data.SuccList[ent.Index] = { Dist = dist, DamageCountdown = WHIRLPOOL.DAMAGE_COUNTDOWN }
				end
				local entData = data.SuccList[ent.Index]
				local newPos = entData.Dist
				ent.Velocity = effect.Position - ent.Position - Vector(newPos.X, newPos.Y / 2.5)
				entData.Dist = (newPos - newPos:Resized(0.4)):Rotated(-15)
				if entData.DamageCountdown > 0 then
					entData.DamageCountdown = entData.DamageCountdown - 1
				else
					ent:TakeDamage(effect.CollisionDamage, 0, EntityRef(effect), 0)
					entData.DamageCountdown = WHIRLPOOL.DAMAGE_COUNTDOWN
				end
				Mod:DelayOneFrame(function()
					if ent:IsDead() or not ent:Exists() or ent.EntityCollisionClass == EntityCollisionClass.ENTCOLL_NONE then
						data.SuccList[ent.Index] = nil
					end
				end)
			end
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_EFFECT_UPDATE, WHIRLPOOL.OnEffectUpdate, WHIRLPOOL.ID)

--#endregion
