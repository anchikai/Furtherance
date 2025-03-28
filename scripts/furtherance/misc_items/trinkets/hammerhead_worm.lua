local Mod = Furtherance

local RNG_INFLUENCE = 0.2
local function getMultiplier(rng)
	return rng:RandomFloat() * RNG_INFLUENCE * 2 + 1 - RNG_INFLUENCE
end

function Mod:FireHammerheadWormTear(tear)
	local player = tear.SpawnerEntity and tear.SpawnerEntity:ToPlayer()
	if player == nil then return end
	if not player:HasTrinket(TrinketType.TRINKET_HAMMERHEAD_WORM) then return end

	local rng = player:GetTrinketRNG(TrinketType.TRINKET_HAMMERHEAD_WORM)
	local damageMultiplier = getMultiplier(rng)
	local velocityMultiplier = getMultiplier(rng)

	tear.ContinueVelocity = tear.ContinueVelocity * velocityMultiplier
	tear.Velocity = tear.Velocity * velocityMultiplier
	tear.CollisionDamage = tear.CollisionDamage * damageMultiplier
	tear.Height = tear.Height * getMultiplier(rng)
	tear.Scale = tear.Scale * (damageMultiplier * 0.5 + 0.5)
end

Mod:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, Mod.FireHammerheadWormTear)
