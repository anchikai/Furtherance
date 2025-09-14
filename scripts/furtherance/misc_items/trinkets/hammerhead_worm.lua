local Mod = Furtherance

local HAMMERHEAD_WORM = {}

Furtherance.Trinket.HAMMERHEAD_WORM = HAMMERHEAD_WORM

HAMMERHEAD_WORM.ID = Isaac.GetTrinketIdByName("Hammerhead Worm")

HAMMERHEAD_WORM.RNG_INFLUENCE = 0.2

---@param rng RNG
---@param mult integer
function HAMMERHEAD_WORM:GetMultiplier(rng, mult)
	local rngNum = HAMMERHEAD_WORM.RNG_INFLUENCE * mult
	return rng:RandomFloat() * rngNum * 2 + 1 - rngNum
end

---@param tear EntityTear
function HAMMERHEAD_WORM:FireHammerheadWormTear(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(HAMMERHEAD_WORM.ID) then
		local rng = player:GetTrinketRNG(HAMMERHEAD_WORM.ID)
		local mult = player:GetTrinketMultiplier(HAMMERHEAD_WORM.ID)
		local damageMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng, mult)
		local velocityMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng, mult)

		tear.ContinueVelocity = tear.ContinueVelocity * velocityMultiplier
		tear.Velocity = tear.Velocity * velocityMultiplier
		tear.CollisionDamage = tear.CollisionDamage * damageMultiplier
		tear.Height = tear.Height * HAMMERHEAD_WORM:GetMultiplier(rng, mult)
		tear.Scale = tear.Scale * (damageMultiplier * 0.5 + 0.5)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, HAMMERHEAD_WORM.FireHammerheadWormTear)

---@param bomb EntityBomb
function HAMMERHEAD_WORM:FireHammerheadWormBomb(bomb)
	local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(HAMMERHEAD_WORM.ID) then
		local rng = player:GetTrinketRNG(HAMMERHEAD_WORM.ID)
		local mult = player:GetTrinketMultiplier(HAMMERHEAD_WORM.ID)
		local damageMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng, mult)
		local velocityMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng, mult) * 1.5
		bomb.Velocity = bomb.Velocity * velocityMultiplier
		bomb.ExplosionDamage = bomb.ExplosionDamage * damageMultiplier
		bomb:SetScale(bomb.ExplosionDamage / 35)
		bomb:SetLoadCostumes(true)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_BOMB, HAMMERHEAD_WORM.FireHammerheadWormBomb)

---Knife collision damage is reset on update and doesn't care about if you update it during its POST_UPDATE function
---@param ent Entity
---@param amount number
---@param flags DamageFlag
---@param source EntityRef
---@param countdown integer
function HAMMERHEAD_WORM:HammerheadWormKnife(ent, amount, flags, source, countdown)
	if ent:IsActiveEnemy(false)
		and source.Entity
		and (source.Entity:ToKnife() or source.Entity:ToPlayer() and Mod:HasBitFlags(flags, DamageFlag.DAMAGE_LASER))
	then
		local player = Mod:TryGetPlayer(source, { WeaponOwner = true, LoopSpawnerEnt = true })
		if player and player:HasTrinket(HAMMERHEAD_WORM.ID) then
			local rng = player:GetTrinketRNG(HAMMERHEAD_WORM.ID)
			local mult = player:GetTrinketMultiplier(HAMMERHEAD_WORM.ID)
			local damageMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng, mult)
			return { Damage = amount * damageMultiplier }
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, HAMMERHEAD_WORM.HammerheadWormKnife)
