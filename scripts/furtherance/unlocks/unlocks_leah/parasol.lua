local Mod = Furtherance

local PARASOL = {}

Furtherance.Trinket.PARASOL = PARASOL

PARASOL.ID = Isaac.GetTrinketIdByName("Parasol")

function PARASOL:BlockShots(proj, collider)
	local familiar = collider:ToFamiliar()
	if familiar
		and familiar.Player
		and familiar.Player:HasTrinket(PARASOL.ID)
	then
		proj:Die()
	end
end

Mod:AddCallback(ModCallbacks.MC_PRE_PROJECTILE_COLLISION, PARASOL.BlockShots)
