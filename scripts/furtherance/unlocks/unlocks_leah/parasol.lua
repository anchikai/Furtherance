local Mod = Furtherance

local PARASOL = {}

Furtherance.Trinket.PARASOL = PARASOL

PARASOL.ID = Isaac.GetTrinketIdByName("Parasol")

PARASOL.REFLECT_CHANCE = 0.5

---@param proj EntityProjectile
---@param collider Entity
function PARASOL:BlockShots(proj, collider)
	local familiar = collider:ToFamiliar()
	if familiar
		and familiar.Player
		and familiar.Player:HasTrinket(PARASOL.ID)
	then
		local player = familiar.Player
		local trinketMult = player:GetTrinketMultiplier(PARASOL.ID)
		if trinketMult >= 2 then
			local rng = player:GetTrinketRNG(PARASOL.ID)
			if rng:RandomFloat() <= PARASOL.REFLECT_CHANCE then
				proj:AddProjectileFlags(ProjectileFlags.HIT_ENEMIES | ProjectileFlags.CANT_HIT_PLAYER)
				proj:AddVelocity(proj.Velocity:Rotated(180) * 1.5)
			end
		end
		return true
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, PARASOL.BlockShots)
