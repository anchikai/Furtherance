local Mod = Furtherance

local HAMMERHEAD_WORM = {}

Furtherance.Trinket.HAMMERHEAD_WORM = HAMMERHEAD_WORM

HAMMERHEAD_WORM.ID = Isaac.GetTrinketIdByName("Hammerhead Worm")

HAMMERHEAD_WORM.RNG_INFLUENCE = 0.2
function HAMMERHEAD_WORM:GetMultiplier(rng)
	return rng:RandomFloat() * HAMMERHEAD_WORM.RNG_INFLUENCE * 2 + 1 - HAMMERHEAD_WORM.RNG_INFLUENCE
end

---@param tear EntityTear
function HAMMERHEAD_WORM:FireHammerheadWormTear(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(HAMMERHEAD_WORM.ID) then
		local rng = player:GetTrinketRNG(HAMMERHEAD_WORM.ID)
		local damageMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng)
		local velocityMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng)

		tear.ContinueVelocity = tear.ContinueVelocity * velocityMultiplier
		tear.Velocity = tear.Velocity * velocityMultiplier
		tear.CollisionDamage = tear.CollisionDamage * damageMultiplier
		tear.Height = tear.Height * HAMMERHEAD_WORM:GetMultiplier(rng)
		tear.Scale = tear.Scale * (damageMultiplier * 0.5 + 0.5)
	end
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, HAMMERHEAD_WORM.FireHammerheadWormTear)

---@param bomb EntityBomb
function HAMMERHEAD_WORM:FireHammerheadWormBomb(bomb)
	local player = bomb.SpawnerEntity and bomb.SpawnerEntity:ToPlayer()
	if player and player:HasTrinket(HAMMERHEAD_WORM.ID) then
		local rng = player:GetTrinketRNG(HAMMERHEAD_WORM.ID)
		local damageMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng)
		local velocityMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng) * 1.5
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
		local sourceEnt = source.Entity
		local player = Mod:TryGetPlayer(sourceEnt, true)
		if player and player:HasTrinket(HAMMERHEAD_WORM.ID) then
			local rng = player:GetTrinketRNG(HAMMERHEAD_WORM.ID)
			local damageMultiplier = HAMMERHEAD_WORM:GetMultiplier(rng)
			return {Damage = amount * damageMultiplier}
		end
	end
end

Mod:AddCallback(ModCallbacks.MC_ENTITY_TAKE_DMG, HAMMERHEAD_WORM.HammerheadWormKnife)
